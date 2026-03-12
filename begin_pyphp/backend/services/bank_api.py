"""
FarmOS Bank API Integration Service
Integration with banking systems for automated financial operations
"""

import asyncio
import aiohttp
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class BankAPIService:
    """Bank API integration service for automated financial operations"""
    
    def __init__(self):
        self.supported_banks = {
            'ecobank': {
                'name': 'EcoBank Zimbabwe',
                'api_base_url': 'https://api.ecobank.co.zw/api/v1',
                'api_key': 'ECOBANK_API_KEY',
                'webhook_url': 'https://farmos.local/webhooks/ecobank',
                'features': ['payments', 'transfers', 'balance', 'statements', 'compliance']
            },
            'stanbic': {
                'name': 'Standard Chartered Bank',
                'api_base_url': 'https://api.stanbic.co.zw/api/v1',
                'api_key': 'STANBIC_API_KEY',
                'webhook_url': 'api.farmos.local/webhooks/stanbic',
                'features': ['payments', 'transfers', 'balance', 'statements', 'compliance']
            },
            'cbz': {
                'name': 'CBZ Bank',
                'api_base_url': 'https://api.cbz.co.zw/api/v1',
                'api_key': 'CBZ_API_KEY',
                'webhook_url': 'api.farmos.local/webhooks/cbz',
                'features': ['payments', 'transfers', 'balance', 'statements', 'compliance']
            }
        }
        
        self.api_connections = {}
        self.webhook_endpoints = {}
        self.transaction_webhooks = {}
        
    async def initialize_connections(self):
        """Initialize bank API connections"""
        try:
            for bank_name, bank_config in self.supported_banks.items():
                self.api_connections[bank_name] = {
                    'config': bank_config,
                    'connection': None,
                    'last_check': None,
                    'webhook_registered': False
                }
                
                # Initialize API connection
                await self._test_bank_connection(bank_name, bank_config)
                
                # Register webhook if available
                if bank_config.get('webhook_url'):
                    await self._register_webhook(bank_name, bank_config)
        
        except Exception as e:
            logger.error(f"Error initializing bank connections: {e}")
    
    async def _test_bank_connection(self, bank_name: str, bank_config: Dict) -> bool:
        """Test connection to bank API"""
        try:
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': bank_config['api_key']
            }
            
            # Test basic connectivity
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    url=bank_config['api_base_url'] + '/health',
                    headers=headers,
                    timeout=10
                ) as response:
                    if response.status == 200:
                        connection_result = await response.json()
                        return connection_result.get('status') == 'ok'
                    else:
                        return False
        except Exception as e:
            logger.error(f"Error testing {bank_name} connection: {e}")
            return False
    
    async def _register_webhook(self, bank_name: str, bank_config: Dict):
        """Register webhook with bank"""
        try:
            webhook_url = bank_config.get('webhook_url')
            if not webhook_url:
                return False
            
            # Prepare webhook registration payload
            webhook_payload = {
                'webhook_url': webhook_url,
                'event_types': ['payment.received', 'transfer.completed', 'balance.updated'],
                'authentication': 'webhook_registered': True
            }
            
            # Send registration request
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': bank_config['api_key']
            }
            
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    url=webhook_url + '/webhooks/register',
                    json=webhook_payload,
                    headers=headers,
                    timeout=15
                ) as response:
                    if response.status == 200:
                        self.webhook_endpoints[bank_name] = webhook_url
                        self.webhook_registered[bank_name] = True
                        return True
                    else:
                        return False
        
        except Exception as e:
            logger.error(f"Error registering webhook for {bank_name}: {e}")
            return False
    
    async def initiate_payment(
        self,
        bank_name: str,
        payment_data: Dict,
        db: Session = Depends(get_db)
    ):
        """Initiate a payment transfer"""
        try:
            bank_config = self.supported_banks.get(bank_name)
            if not bank_config or not self.api_connections.get(bank_name, {}).get('connection'):
                return {
                    'error': f"Bank {bank_name} not available",
                    'message': 'Bank connection not established'
                }
            
            # Prepare payment request
            payment_url = f"{bank_config['api_base_url']}/payments"
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': bank_config['api_key'],
                'Authorization': f"Bearer {self.api_connections[bank_name]['access_token']}" if self.api_connections[bank_name].get('access_token') else None
            }
            
            # Add transaction record
            transaction = models.FinancialTransaction(
                tenant_id="default",
                type='expense',
                amount=payment_data.get('amount', 0),
                category='bank_fees',
                description=f"Payment to {payment_data.get('recipient', 'Unknown')}",
                currency=payment_data.get('currency', 'USD'),
                reference=payment_data.get('reference', ''),
                status='pending',
                created_at=datetime.utcnow(),
                metadata={
                    'bank': bank_name,
                    'payment_id': payment_data.get('payment_id', ''),
                    'webhook_id': payment_data.get('webhook_id', '')
                }
            )
            
            db.add(transaction)
            db.commit()
            
            # Send payment request to bank
            headers['X-Webhook-ID'] = payment_data.get('webhook_id', '')
            
            payload = {
                'amount': payment_data.get('amount', 0),
                'currency': payment_data.get('currency', 'USD'),
                'recipient': payment_data.get('recipient', ''),
                'reference': payment_data.get('reference', ''),
                'description': payment_data.get('description', ''),
                'webhook_id': payment_data.get('webhook_id', '')
            }
            
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.post(
                        url=payment_url,
                        json=payload,
                        headers=headers,
                        timeout=30
                    ) as response:
                        if response.status == 200:
                            result = await response.json()
                            
                            # Update transaction with bank reference
                            if result.get('reference'):
                                transaction.reference = result['reference']
                                transaction.status = 'processing'
                            db.commit()
                            
                            return {
                                'success': True,
                                'transaction_id': transaction.id,
                                'bank_reference': result.get('reference', ''),
                                'bank_status': result.get('status', 'status')
                            }
                        else:
                            # Handle payment failure
                            transaction.status = 'failed'
                            db.commit()
                            
                            return {
                                'success': False,
                                'error': result.get('message', 'message') if 'response.status >= 400 else 'Unknown error'
                            }
                
            except Exception as e:
                logger.error(f"Error initiating payment with {bank_name}: {e}")
                
                # Mark transaction as failed
                transaction.status = 'failed'
                db.commit()
                
                return {
                    'success': False,
                    'error': str(e)
                }
        
        except Exception as e:
            logger.error(f"Error in payment initiation: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def check_transaction_status(
        self,
        bank_name: str,
        transaction_reference: str,
        db: Session = Depends(get_db)
    ):
        """Check status of a transaction"""
        try:
            bank_config = self.supported_banks.get(bank_name)
            if not bank_config or not self.api_connections.get(bank_name, {}).get('connection'):
                return {
                    'error': f"Bank {bank_name} not available",
                    'message': 'Bank connection not established'
                }
            
            # Check transaction status
            status_url = f"{bank_config['api_base_url']}/payments/{transaction_reference}"
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': bank_config['api_key'],
                'Authorization': f"Bearer {self.api_connections[bank_name]['access_token']}" if self.api_connections[bank_name].get('access_token') else None
            }
            
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                        url=status_url,
                        headers=headers,
                        timeout=10
                    ) as response:
                        if response.status == 200:
                            result = await response.json()
                            return result
                        else:
                            return {
                                'success': False,
                                'error': f"HTTP {response.status}",
                                'message': result.get('message', 'message') if response.status >= 400 else 'Unknown error'
                            }
                
            except Exception as e:
                logger.error(f"Error checking transaction status: {e}")
                return {
                    'success': False,
                    'error': str(e)
                }
        
    async def get_account_balance(
        self,
        bank_name: str,
        account_id: str,
        db: Session = Depends(get_db)
    ):
        """Get account balance"""
        try:
            bank_config = self.supported_banks.get(bank_name)
            if not bank_config or not self.api_connections.get(bank_name, {}).get('connection'):
                return {
                    'error': f"Bank {bank_name} not available",
                    'message': 'Bank connection not established'
                }
            
            balance_url = f"{bank_config['api_base_url']}/accounts/{account_id}/balance"
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': bank_config['api_key'],
                'Authorization': f"Bearer {self.api_connections[bank_name]['access_token'] if self.api_connections[bank_name].get('access_token') else None
            }
            
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                        url=balance_url,
                        headers=headers,
                        timeout=10
                    ) as response:
                        if response.status == 200:
                            result = await response.json()
                            return result
                        else:
                            return {
                                'success': False,
                                'error': f"HTTP {response.status}",
                                'message': result.get('message', message') if response.status >= 400 else 'Unknown error'
                            }
                
            except Exception as e:
                logger.error(f"Error getting account balance: {e}")
                return {
                    'success': False,
                    'error': str(e)
                }
        
    async def get_transaction_history(
        self,
        bank_name: str,
        db: Session = Depends(get_db),
        limit: int = 50,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None
    ):
        """Get transaction history from bank"""
        try:
            bank_config = self.supported_banks.get(bank_name)
            if not bank_config or not self.api_connections.get(bank_name, {}).get('connection'):
                return {
                    'error': f"Bank {bank_name} not available",
                    'message': 'Bank connection not established'
                }
            
            # Build URL with query parameters
            history_url = f"{bank_config['api_base_url']}/transactions"
            params = []
            
            if start_date:
                params.append(f"start_date={start_date}")
            if end_date:
                params.append(f"end_date={end_date}")
            if limit:
                params.append(f"limit={limit}")
            
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': bank_config['api_key'],
                'Authorization': f"Bearer {self.api_connections[bank_name]['access_token'] if self.api_connections[bank_name].get('access_token') else None}
            }
            
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                        url=history_url,
                        params=params,
                        headers=headers,
                        timeout=15
                    ) as response:
                        if response.status == 200:
                            result = await response.json()
                            return result
                        else:
                            return {
                                'success': False,
                                'error': f"HTTP {response.status}",
                                'message': result.get('message', message') if response.status >= 400 else 'Unknown error'
                            }
                
            except Exception as e:
                logger.error(f"Error getting transaction history: {e}")
                return {
                    'success': False,
                    'error': str(e)
                }
        
        except Exception as e:
            logger.error(f"Error in transaction history: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def get_supported_banks(self) -> Dict:
        """Get list of supported banks"""
        return {
            'status': 'success',
            'data': {
                'supported_banks': self.supported_banks,
                'total_banks': len(self.supported_banks),
                'features': {
                    'payments': True,
                    'transfers': True,
                    'balance: True,
                    'statements': True,
                    'compliance: True
                }
            }
        }
    
    def get_bank_status(self, bank_name: str) -> Dict:
        """Get connection status for a specific bank"""
        connection = self.api_connections.get(bank_name, {})
        
        if not connection:
            return {
                'bank_name': bank_name,
                'connected': False,
                'connection_status': 'disconnected',
                'last_check': None
            }
        
        return {
            'status': 'success',
            'data': {
                'bank_name': bank_name,
                'connected': connection.get('connection', False) is not None,
                'connection_status': 'connected' if connection and connection.get('connection', False) else 'disconnected',
                'last_check': connection.get('last_check').isoformat() if connection.get('last_check') else None,
                'webhook_registered': self.webhook_registered.get(bank_name, False)
            }
        }
    
    def get_webhook_status(self, bank_name: str) -> Dict:
        """Get webhook registration status"""
        return {
            'bank_name': bank_name,
            'webhook_registered': self.webhook_registered.get(bank_name, False),
            'webhook_url': self.supported_banks.get(bank_name, {}).get('webhook_url'),
            'registration_status': 'registered' if self.webhook_registered.get(bank_name, False) else 'not_registered'
        }

# Global bank API service instance
bank_api_service = BankAPIService()
