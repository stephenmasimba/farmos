"""
FarmOS Multi-Currency Support Service
Handles multiple currencies, exchange rates, and international financial operations
"""

import asyncio
import aiohttp
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

class MultiCurrencyService:
    """Multi-currency support service for international operations"""
    
    def __init__(self):
        self.supported_currencies = {
            'USD': {'name': 'US Dollar', 'symbol': '$', 'code': 'USD'},
            'EUR': {'name': 'Euro', 'symbol': '€', 'code': 'EUR'},
            'GBP': {'name': 'British Pound', 'symbol': '£', 'code': 'GBP'},
            'ZWL': {'name': 'Zimbabwe Dollar', 'symbol': 'ZWL', 'code': 'ZWL'},
            'ZAR': {'name': 'South African Rand', 'symbol': 'R', 'code': 'ZAR'},
            'BWP': {'name': 'Botswana Pula', 'symbol': 'P', 'code': 'BWP'},
            'MWK': {'name': 'Malawian Kwacha', 'symbol': 'MK', 'code': 'MWK'},
            'JPY': {'name': 'Japanese Yen', 'symbol': '¥', 'code': 'JPY'},
            'CNY': {'name': 'Chinese Yuan', 'symbol': '¥', 'code': 'CNY'}
        }
        
        self.exchange_rates = {}
        self.last_update = None
        self.update_interval = 3600  # 1 hour
        
    async def update_exchange_rates(self):
        """Update exchange rates from external API"""
        try:
            # Using a free exchange rate API (you would typically use a paid service)
            # For demo purposes, we'll use mock rates
            base_currency = 'USD'
            
            # Mock exchange rates (in production, these would come from API)
            mock_rates = {
                'EUR': 0.92,      # 1 EUR = 0.92 USD
                'GBP': 1.27,      # 1 GBP = 1.27 USD
                'ZWL': 0.0031,    # 1 ZWL = 0.0031 USD
                'ZAR': 0.053,     # 1 ZAR = 0.053 USD
                'BWP': 0.074,      # 1 BWP = 0.074 USD
                'MWK': 0.00061,    # 1 MWK = 0.00061 USD
                'JPY': 0.0067,     # 1 JPY = 0.0067 USD
                'CNY': 0.14        # 1 CNY = 0.14 USD
            }
            
            # Add USD base rate
            mock_rates['USD'] = 1.0
            
            self.exchange_rates = mock_rates
            self.last_update = datetime.utcnow()
            
            logger.info(f"Exchange rates updated at {self.last_update}")
            
        except Exception as e:
            logger.error(f"Error updating exchange rates: {e}")
    
    def convert_currency(self, amount: float, from_currency: str, to_currency: str) -> Dict:
        """Convert amount from one currency to another"""
        try:
            if from_currency not in self.exchange_rates or to_currency not in self.exchange_rates:
                return {
                    'error': 'Currency not supported',
                    'amount': amount,
                    'from_currency': from_currency,
                    'to_currency': to_currency
                }
            
            # Convert via USD as base
            if from_currency == 'USD':
                usd_amount = amount
            else:
                usd_amount = amount / self.exchange_rates[from_currency]
            
            if to_currency == 'USD':
                converted_amount = usd_amount
            else:
                converted_amount = usd_amount * self.exchange_rates[to_currency]
            
            return {
                'original_amount': amount,
                'converted_amount': round(converted_amount, 4),
                'from_currency': from_currency,
                'to_currency': to_currency,
                'exchange_rate': self.exchange_rates[to_currency],
                'conversion_date': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error converting currency: {e}")
            return {
                'error': 'Conversion failed',
                'message': str(e)
            }
    
    def format_currency(self, amount: float, currency: str, include_symbol: bool = True) -> str:
        """Format currency amount with proper symbol"""
        try:
            currency_info = self.supported_currencies.get(currency, {})
            
            if include_symbol and currency_info:
                return f"{currency_info['symbol']}{amount:,.2f} {currency}"
            else:
                return f"{amount:,.2f} {currency}"
                
        except Exception as e:
            logger.error(f"Error formatting currency: {e}")
            return f"{amount} {currency}"
    
    def get_currency_info(self, currency: str) -> Dict:
        """Get currency information"""
        return self.supported_currencies.get(currency, {})
    
    def calculate_multi_currency_summary(self, transactions: List[Dict], base_currency: str = 'USD') -> Dict:
        """Calculate financial summary in multiple currencies"""
        try:
            summary = {
                'base_currency': base_currency,
                'total_by_currency': {},
                'exchange_rates_used': self.exchange_rates,
                'calculation_date': datetime.utcnow().isoformat()
            }
            
            # Calculate totals by original currency
            currency_totals = {}
            for transaction in transactions:
                currency = transaction.get('currency', base_currency)
                amount = transaction.get('amount', 0)
                
                if currency not in currency_totals:
                    currency_totals[currency] = {
                        'income': 0,
                        'expenses': 0,
                        'net': 0
                    }
                
                if transaction.get('type') == 'income':
                    currency_totals[currency]['income'] += amount
                else:
                    currency_totals[currency]['expenses'] += amount
                
                currency_totals[currency]['net'] = (
                    currency_totals[currency]['income'] - 
                    currency_totals[currency]['expenses']
                )
            
            # Convert all totals to base currency
            for currency, totals in currency_totals.items():
                if currency != base_currency:
                    if currency in self.exchange_rates:
                        conversion_rate = self.exchange_rates[currency]
                        summary['total_by_currency'][currency] = {
                            'original': totals,
                            'converted': {
                                'income': round(totals['income'] * conversion_rate, 2),
                                'expenses': round(totals['expenses'] * conversion_rate, 2),
                                'net': round(totals['net'] * conversion_rate, 2)
                            },
                            'exchange_rate': conversion_rate
                        }
                    else:
                        summary['total_by_currency'][currency] = {
                            'original': totals,
                            'converted': totals,  # No conversion if no rate
                            'exchange_rate': None
                        }
                else:
                    summary['total_by_currency'][currency] = {
                        'original': totals,
                        'converted': totals,
                        'exchange_rate': 1.0
                    }
            
            # Calculate grand totals in base currency
            grand_total = {
                'income': 0,
                'expenses': 0,
                'net': 0
            }
            
            for currency, totals in summary['total_by_currency'].items():
                converted = totals.get('converted', totals)
                grand_total['income'] += converted.get('income', 0)
                grand_total['expenses'] += converted.get('expenses', 0)
                grand_total['net'] += converted.get('net', 0)
            
            summary['grand_totals'] = grand_total
            
            return summary
            
        except Exception as e:
            logger.error(f"Error calculating multi-currency summary: {e}")
            return {
                'error': 'Calculation failed',
                'message': str(e)
            }
    
    async def start_rate_updates(self):
        """Start automatic exchange rate updates"""
        while True:
            await self.update_exchange_rates()
            await asyncio.sleep(self.update_interval)
    
    def get_supported_currencies(self) -> Dict:
        """Get list of supported currencies"""
        return self.supported_currencies
    
    def validate_currency_code(self, currency_code: str) -> bool:
        """Validate if currency code is supported"""
        return currency_code in self.supported_currencies

# Global multi-currency service instance
multi_currency_service = MultiCurrencyService()
