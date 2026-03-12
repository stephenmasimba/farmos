"""
FarmOS Load Testing Framework
Load testing and performance benchmarking for FarmOS system
"""

import asyncio
import aiohttp
import time
import statistics
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from concurrent.futures import ThreadPoolExecutor
import json

logger = logging.getLogger(__name__)

class LoadTestingFramework:
    """Load testing framework for FarmOS system"""
    
    def __init__(self):
        self.test_scenarios = {}
        self.test_results = {}
        self.performance_metrics = {}
        self.is_running = False
        
        # Initialize test scenarios
        self._initialize_test_scenarios()
        
    def _initialize_test_scenarios(self):
        """Initialize load testing scenarios"""
        self.test_scenarios = {
            'api_load_test': {
                'name': 'API Load Test',
                'description': 'Test API endpoints under load',
                'target_url': 'http://127.0.0.1:8000',
                'endpoints': [
                    '/api/dashboard/summary',
                    '/api/livestock/',
                    '/api/inventory/',
                    '/api/financial/transactions',
                    '/api/auth/login'
                ],
                'concurrent_users': [10, 50, 100, 200],
                'duration_seconds': 60,
                'ramp_up_seconds': 10
            },
            'database_load_test': {
                'name': 'Database Load Test',
                'description': 'Test database performance under load',
                'queries': [
                    'SELECT COUNT(*) FROM livestock_batches',
                    'SELECT * FROM financial_transactions WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)',
                    'SELECT * FROM livestock_events WHERE date >= DATE_SUB(NOW(), INTERVAL 7 DAY)',
                    'SELECT l.*, COUNT(e.id) as event_count FROM livestock_batches l LEFT JOIN livestock_events e ON l.id = e.batch_id GROUP BY l.id'
                ],
                'concurrent_connections': [5, 10, 20],
                'duration_seconds': 120
            },
            'websocket_load_test': {
                'name': 'WebSocket Load Test',
                'description': 'Test WebSocket connections under load',
                'target_url': 'ws://127.0.0.1:8001/ws/test_user',
                'concurrent_connections': [50, 100, 200],
                'duration_seconds': 60,
                'message_frequency': 10  # messages per second per connection
            },
            'file_upload_test': {
                'name': 'File Upload Load Test',
                'description': 'Test file upload performance',
                'target_url': 'http://127.0.0.1:8000/api/upload',
                'file_sizes_mb': [1, 5, 10, 25],
                'concurrent_uploads': [5, 10, 20],
                'file_types': ['image/jpeg', 'application/pdf', 'text/csv']
            },
            'stress_test': {
                'name': 'Stress Test',
                'description': 'Stress test to find breaking point',
                'target_url': 'http://127.0.0.1:8000',
                'concurrent_users': [500, 1000],
                'duration_seconds': 300,
                'ramp_up_strategy': 'exponential'
            }
        }
    
    async def start_load_test(self, scenario_id: str, config_override: Optional[Dict] = None) -> Dict:
        """Start a specific load test"""
        try:
            scenario = self.test_scenarios.get(scenario_id)
            if not scenario:
                return {
                    'success': False,
                    'error': f"Unknown test scenario: {scenario_id}"
                }
            
            # Apply config overrides
            if config_override:
                scenario.update(config_override)
            
            logger.info(f"Starting load test: {scenario_id}")
            
            # Initialize test results
            test_id = f"load_test_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
            self.test_results[test_id] = {
                'scenario_id': scenario_id,
                'scenario_name': scenario.get('name'),
                'started_at': datetime.utcnow(),
                'status': 'running',
                'config': scenario,
                'metrics': {}
            }
            
            # Execute test based on scenario type
            if scenario_id == 'api_load_test':
                result = await self._execute_api_load_test(scenario, test_id)
            elif scenario_id == 'database_load_test':
                result = await self._execute_database_load_test(scenario, test_id)
            elif scenario_id == 'websocket_load_test':
                result = await self._execute_websocket_load_test(scenario, test_id)
            elif scenario_id == 'file_upload_test':
                result = await self._execute_file_upload_test(scenario, test_id)
            elif scenario_id == 'stress_test':
                result = await self._execute_stress_test(scenario, test_id)
            else:
                result = {'success': False, 'error': f"Unsupported test scenario: {scenario_id}"}
            
            # Update test results
            self.test_results[test_id].update(result)
            
            return {
                'success': True,
                'test_id': test_id,
                'scenario': scenario_id,
                'started_at': self.test_results[test_id]['started_at'].isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error starting load test {scenario_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _execute_api_load_test(self, scenario: Dict, test_id: str) -> Dict:
        """Execute API load test"""
        try:
            concurrent_users = scenario.get('concurrent_users', [10])
            duration = scenario.get('duration_seconds', 60)
            ramp_up = scenario.get('ramp_up_seconds', 10)
            endpoints = scenario.get('endpoints', [])
            
            # Initialize metrics
            metrics = {
                'total_requests': 0,
                'successful_requests': 0,
                'failed_requests': 0,
                'response_times': [],
                'errors': [],
                'throughput': 0,
                'error_rate': 0
            }
            
            # Create session factory
            async def create_session():
                return aiohttp.ClientSession(
                    timeout=aiohttp.ClientTimeout(total=30),
                    connector=aiohttp.TCPConnector(limit=100)
                )
            
            # Execute load test
            start_time = time.time()
            
            async with create_session() as session:
                tasks = []
                
                # Create tasks for concurrent users
                for user_id in range(concurrent_users):
                    for endpoint in endpoints:
                        # Ramp up delay
                        delay = (user_id * ramp_up) / concurrent_users
                        await asyncio.sleep(delay)
                        
                        # Create user task
                        task = asyncio.create_task(
                            self._simulate_api_user(session, endpoint, duration, user_id, metrics)
                        )
                        tasks.append(task)
                
                # Wait for all tasks to complete
                await asyncio.gather(*tasks)
            
            end_time = time.time()
            actual_duration = end_time - start_time
            
            # Calculate final metrics
            if metrics['response_times']:
                metrics['avg_response_time'] = statistics.mean(metrics['response_times'])
                metrics['min_response_time'] = min(metrics['response_times'])
                metrics['max_response_time'] = max(metrics['response_times'])
                metrics['p95_response_time'] = statistics.quantiles(metrics['response_times'], 0.95)
            
            metrics['throughput'] = metrics['total_requests'] / actual_duration
            metrics['error_rate'] = (metrics['failed_requests'] / metrics['total_requests']) * 100 if metrics['total_requests'] > 0 else 0
            
            return {
                'success': True,
                'metrics': metrics,
                'duration': actual_duration,
                'concurrent_users': concurrent_users,
                'endpoints_tested': endpoints
            }
        
        except Exception as e:
            logger.error(f"Error in API load test: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _simulate_api_user(self, session: aiohttp.ClientSession, endpoint: str, duration: int, user_id: int, metrics: Dict):
        """Simulate a single API user"""
        try:
            end_time = time.time() + duration
            
            while time.time() < end_time:
                request_start = time.time()
                
                try:
                    # Make API request
                    async with session.get(
                        url=f"{session._base_url}{endpoint}",
                        headers={
                            'Content-Type': 'application/json',
                            'X-API-Key': 'local-dev-key',
                            'User-Agent': f'LoadTest-User-{user_id}'
                        }
                    ) as response:
                        response_time = time.time() - request_start
                        
                        if response.status == 200:
                            metrics['successful_requests'] += 1
                        else:
                            metrics['failed_requests'] += 1
                            metrics['errors'].append({
                                'user_id': user_id,
                                'endpoint': endpoint,
                                'status': response.status,
                                'error': await response.text(),
                                'timestamp': datetime.utcnow().isoformat()
                            })
                        
                        metrics['total_requests'] += 1
                        metrics['response_times'].append(response_time)
                
                except Exception as e:
                    metrics['failed_requests'] += 1
                    metrics['errors'].append({
                        'user_id': user_id,
                        'endpoint': endpoint,
                        'error': str(e),
                        'timestamp': datetime.utcnow().isoformat()
                    })
                    metrics['total_requests'] += 1
                
                # Small delay between requests
                await asyncio.sleep(0.1)
        
        except Exception as e:
            logger.error(f"Error simulating user {user_id}: {e}")
    
    async def _execute_database_load_test(self, scenario: Dict, test_id: str) -> Dict:
        """Execute database load test"""
        try:
            concurrent_connections = scenario.get('concurrent_connections', [5])
            duration = scenario.get('duration_seconds', 120)
            queries = scenario.get('queries', [])
            
            # Initialize metrics
            metrics = {
                'total_queries': 0,
                'successful_queries': 0,
                'failed_queries': 0,
                'query_times': [],
                'errors': []
                'throughput': 0
            }
            
            # Execute database load test
            start_time = time.time()
            
            with ThreadPoolExecutor(max_workers=concurrent_connections) as executor:
                # Create tasks for concurrent connections
                tasks = []
                
                for conn_id in range(concurrent_connections):
                    for query in queries:
                        task = asyncio.get_event_loop().run_in_executor(
                            executor,
                            self._execute_database_query,
                            query,
                            conn_id,
                            metrics
                        )
                        tasks.append(task)
                
                # Wait for all tasks to complete
                results = await asyncio.gather(*tasks)
            
            end_time = time.time()
            actual_duration = end_time - start_time
            
            # Calculate final metrics
            if metrics['query_times']:
                metrics['avg_query_time'] = statistics.mean(metrics['query_times'])
                metrics['min_query_time'] = min(metrics['query_times'])
                metrics['max_query_time'] = max(metrics['query_times'])
                metrics['p95_query_time'] = statistics.quantiles(metrics['query_times'], 0.95)
            
            metrics['throughput'] = metrics['total_queries'] / actual_duration
            metrics['error_rate'] = (metrics['failed_queries'] / metrics['total_queries']) * 100 if metrics['total_queries'] > 0 else 0
            
            return {
                'success': True,
                'metrics': metrics,
                'duration': actual_duration,
                'concurrent_connections': concurrent_connections,
                'queries_tested': len(queries)
            }
        
        except Exception as e:
            logger.error(f"Error in database load test: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _execute_database_query(self, query: str, conn_id: int, metrics: Dict) -> Dict:
        """Execute a single database query"""
        try:
            from ..common.database import get_db
            from sqlalchemy import text
            
            db = next(get_db())
            
            query_start = time.time()
            
            try:
                # Execute query
                result = db.execute(text(query))
                
                query_time = time.time() - query_start
                metrics['total_queries'] += 1
                metrics['successful_queries'] += 1
                metrics['query_times'].append(query_time)
                
                return {
                    'conn_id': conn_id,
                    'query': query,
                    'execution_time': query_time,
                    'success': True,
                    'result_count': result.rowcount if result else 0
                }
            
            except Exception as e:
                query_time = time.time() - query_start
                metrics['total_queries'] += 1
                metrics['failed_queries'] += 1
                metrics['query_times'].append(query_time)
                metrics['errors'].append({
                    'conn_id': conn_id,
                    'query': query,
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                })
                
                return {
                    'conn_id': conn_id,
                    'query': query,
                    'execution_time': query_time,
                    'success': False,
                    'error': str(e)
                }
            
            finally:
                db.close()
        
        except Exception as e:
            return {
                'conn_id': conn_id,
                'query': query,
                'execution_time': 0,
                'success': False,
                'error': str(e)
            }
    
    async def _execute_websocket_load_test(self, scenario: Dict, test_id: str) -> Dict:
        """Execute WebSocket load test"""
        try:
            concurrent_connections = scenario.get('concurrent_connections', [50])
            duration = scenario.get('duration_seconds', 60)
            message_frequency = scenario.get('message_frequency', 10)
            
            # Initialize metrics
            metrics = {
                'total_connections': concurrent_connections,
                'successful_connections': 0,
                'failed_connections': 0,
                'messages_sent': 0,
                'messages_received': 0,
                'latency_times': [],
                'errors': []
            }
            
            # Execute WebSocket load test
            start_time = time.time()
            
            # Create WebSocket connections
            tasks = []
            for conn_id in range(concurrent_connections):
                task = asyncio.create_task(
                    self._simulate_websocket_connection(scenario, conn_id, duration, message_frequency, metrics)
                )
                tasks.append(task)
            
            # Wait for all connections to complete
            await asyncio.gather(*tasks)
            
            end_time = time.time()
            actual_duration = end_time - start_time
            
            # Calculate final metrics
            if metrics['latency_times']:
                metrics['avg_latency'] = statistics.mean(metrics['latency_times'])
                metrics['min_latency'] = min(metrics['latency_times'])
                metrics['max_latency'] = max(metrics['latency_times'])
                metrics['p95_latency'] = statistics.quantiles(metrics['latency_times'], 0.95)
            
            metrics['message_rate'] = metrics['messages_sent'] / actual_duration
            
            return {
                'success': True,
                'metrics': metrics,
                'duration': actual_duration,
                'concurrent_connections': concurrent_connections
            }
        
        except Exception as e:
            logger.error(f"Error in WebSocket load test: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _simulate_websocket_connection(self, scenario: Dict, conn_id: int, duration: int, message_frequency: int, metrics: Dict):
        """Simulate a single WebSocket connection"""
        try:
            import websockets
            
            target_url = scenario.get('target_url', 'ws://127.0.0.1:8001/ws/test_user')
            
            connection_start = time.time()
            
            try:
                async with websockets.connect(target_url) as websocket:
                    metrics['successful_connections'] += 1
                    
                    # Send messages for duration
                    end_time = connection_start + duration
                    
                    message_count = 0
                    while time.time() < end_time:
                        message_start = time.time()
                        
                        try:
                            await websocket.send(json.dumps({
                                'type': 'test_message',
                                'conn_id': conn_id,
                                'message_id': message_count,
                                'timestamp': datetime.utcnow().isoformat()
                            }))
                            
                            latency = time.time() - message_start
                            metrics['messages_sent'] += 1
                            metrics['latency_times'].append(latency)
                            
                            message_count += 1
                            
                        except Exception as e:
                            metrics['errors'].append({
                                'conn_id': conn_id,
                                'error': str(e),
                                'timestamp': datetime.utcnow().isoformat()
                            })
                        
                        # Wait for next message
                        await asyncio.sleep(1.0 / message_frequency)
                
            except Exception as e:
                metrics['failed_connections'] += 1
                metrics['errors'].append({
                    'conn_id': conn_id,
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                })
            
            return {
                'conn_id': conn_id,
                'messages_sent': metrics['messages_sent'],
                'success': True
            }
        
        except Exception as e:
            metrics['failed_connections'] += 1
            metrics['errors'].append({
                'conn_id': conn_id,
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            })
            
            return {
                'conn_id': conn_id,
                'messages_sent': 0,
                'success': False
            }
    
    async def _execute_file_upload_test(self, scenario: Dict, test_id: str) -> Dict:
        """Execute file upload load test"""
        try:
            concurrent_uploads = scenario.get('concurrent_uploads', [5])
            file_sizes = scenario.get('file_sizes_mb', [1])
            file_types = scenario.get('file_types', ['image/jpeg'])
            
            # Initialize metrics
            metrics = {
                'total_uploads': 0,
                'successful_uploads': 0,
                'failed_uploads': 0,
                'upload_times': [],
                'total_bytes': 0,
                'throughput_mbps': 0,
                'errors': []
            }
            
            # Execute file upload test
            start_time = time.time()
            
            tasks = []
            for upload_id in range(concurrent_uploads):
                for file_size in file_sizes:
                    for file_type in file_types:
                        task = asyncio.create_task(
                            self._simulate_file_upload(scenario, upload_id, file_size, file_type, metrics)
                        )
                        tasks.append(task)
            
            # Wait for all uploads to complete
            results = await asyncio.gather(*tasks)
            
            end_time = time.time()
            actual_duration = end_time - start_time
            
            # Calculate final metrics
            if metrics['upload_times']:
                metrics['avg_upload_time'] = statistics.mean(metrics['upload_times'])
                metrics['min_upload_time'] = min(metrics['upload_times'])
                metrics['max_upload_time'] = max(metrics['upload_times'])
                metrics['p95_upload_time'] = statistics.quantiles(metrics['upload_times'], 0.95)
            
            metrics['throughput_mbps'] = (metrics['total_bytes'] / (actual_duration * 1024 * 1024)) if actual_duration > 0 else 0
            metrics['error_rate'] = (metrics['failed_uploads'] / metrics['total_uploads']) * 100 if metrics['total_uploads'] > 0 else 0
            
            return {
                'success': True,
                'metrics': metrics,
                'duration': actual_duration,
                'concurrent_uploads': concurrent_uploads,
                'file_sizes_tested': file_sizes,
                'file_types_tested': file_types
            }
        
        except Exception as e:
            logger.error(f"Error in file upload load test: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _simulate_file_upload(self, scenario: Dict, upload_id: int, file_size_mb: int, file_type: str, metrics: Dict):
        """Simulate a single file upload"""
        try:
            target_url = scenario.get('target_url', 'http://127.0.0.1:8000/api/upload')
            
            upload_start = time.time()
            
            # Generate test file data
            file_data = b'x' * (file_size_mb * 1024 * 1024)  # Create file of specified size
            
            # Create multipart form data
            from aiohttp import FormData
            data = FormData()
            data.add_field('file', f'test_file_{upload_id}_{file_size_mb}mb.{file_type.split("/")[-1]}', 
                         file_data, 
                         f'application/octet-stream', 
                         filename=f'test_file_{upload_id}_{file_size_mb}mb.{file_type.split("/")[-1]}')
            
            try:
                async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=300)) as session:
                    upload_start = time.time()
                    
                    async with session.post(target_url, data=data) as response:
                        upload_time = time.time() - upload_start
                        
                        if response.status == 200:
                            metrics['successful_uploads'] += 1
                        else:
                            metrics['failed_uploads'] += 1
                            metrics['errors'].append({
                                'upload_id': upload_id,
                                'file_size_mb': file_size_mb,
                                'file_type': file_type,
                                'status': response.status,
                                'error': await response.text(),
                                'timestamp': datetime.utcnow().isoformat()
                            })
                        
                        metrics['total_uploads'] += 1
                        metrics['upload_times'].append(upload_time)
                        metrics['total_bytes'] += file_size_mb * 1024 * 1024
                
            except Exception as e:
                metrics['failed_uploads'] += 1
                metrics['errors'].append({
                    'upload_id': upload_id,
                    'file_size_mb': file_size_mb,
                    'file_type': file_type,
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                })
                
                metrics['total_uploads'] += 1
                metrics['total_bytes'] += file_size_mb * 1024 * 1024
            
            return {
                'upload_id': upload_id,
                'file_size_mb': file_size_mb,
                'file_type': file_type,
                'upload_time': time.time() - upload_start,
                'success': True
            }
        
        except Exception as e:
            metrics['failed_uploads'] += 1
            metrics['errors'].append({
                'upload_id': upload_id,
                'file_size_mb': file_size_mb,
                'file_type': file_type,
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            })
            
            return {
                'upload_id': upload_id,
                'file_size_mb': file_size_mb,
                'file_type': file_type,
                'upload_time': 0,
                'success': False
            }
    
    async def _execute_stress_test(self, scenario: Dict, test_id: str) -> Dict:
        """Execute stress test to find breaking point"""
        try:
            # Use exponential ramp-up strategy
            concurrent_users = scenario.get('concurrent_users', [500])
            duration = scenario.get('duration_seconds', 300)
            ramp_up_strategy = scenario.get('ramp_up_strategy', 'exponential')
            
            # Initialize metrics
            metrics = {
                'total_requests': 0,
                'successful_requests': 0,
                'failed_requests': 0,
                'response_times': [],
                'errors': [],
                'system_errors': [],
                'breaking_point': None
            }
            
            # Execute stress test
            start_time = time.time()
            
            # Exponential ramp-up
            current_users = 10
            while time.time() - start_time < duration:
                try:
                    # Create session for current user level
                    async with aiohttp.ClientSession(
                        timeout=aiohttp.ClientTimeout(total=10),
                        connector=aiohttp.TCPConnector(limit=current_users)
                    ) as session:
                        
                        # Create tasks for current users
                        tasks = []
                        for user_id in range(current_users):
                            for endpoint in ['/api/dashboard/summary']:  # Test critical endpoint
                                task = asyncio.create_task(
                                    self._stress_test_user(session, endpoint, duration, user_id, metrics)
                                )
                                tasks.append(task)
                        
                        # Wait for current batch
                        await asyncio.gather(*tasks)
                        
                        # Ramp up users
                        if ramp_up_strategy == 'exponential' and current_users < concurrent_users:
                            current_users = min(current_users * 2, concurrent_users)
                            logger.info(f"Ramping up to {current_users} users")
                
                except Exception as e:
                    metrics['system_errors'].append({
                        'error': str(e),
                        'timestamp': datetime.utcnow().isoformat(),
                        'users': current_users
                    })
                    
                    # If too many errors, stop test
                    if len(metrics['system_errors']) > 10:
                        metrics['breaking_point'] = f"Too many system errors at {current_users} users"
                        break
                
                # Small delay between batches
                await asyncio.sleep(5)
            
            end_time = time.time()
            actual_duration = end_time - start_time
            
            # Calculate final metrics
            if metrics['response_times']:
                metrics['avg_response_time'] = statistics.mean(metrics['response_times'])
                metrics['min_response_time'] = min(metrics['response_times'])
                metrics['max_response_time'] = max(metrics['response_times'])
                metrics['p95_response_time'] = statistics.quantiles(metrics['response_times'], 0.95)
            
            metrics['throughput'] = metrics['total_requests'] / actual_duration
            metrics['error_rate'] = (metrics['failed_requests'] / metrics['total_requests']) * 100 if metrics['total_requests'] > 0 else 0
            
            return {
                'success': True,
                'metrics': metrics,
                'duration': actual_duration,
                'max_concurrent_users': concurrent_users,
                'ramp_up_strategy': ramp_up_strategy,
                'breaking_point': metrics['breaking_point']
            }
        
        except Exception as e:
            logger.error(f"Error in stress test: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _stress_test_user(self, session: aiohttp.ClientSession, endpoint: str, duration: int, user_id: int, metrics: Dict):
        """Stress test a single user"""
        try:
            end_time = time.time() + duration
            
            while time.time() < end_time:
                request_start = time.time()
                
                try:
                    async with session.get(
                        url=f"{session._base_url}{endpoint}",
                        headers={
                            'Content-Type': 'application/json',
                            'X-API-Key': 'local-dev-key',
                            'User-Agent': f'StressTest-User-{user_id}'
                        }
                    ) as response:
                        response_time = time.time() - request_start
                        
                        if response.status == 200:
                            metrics['successful_requests'] += 1
                        else:
                            metrics['failed_requests'] += 1
                            metrics['errors'].append({
                                'user_id': user_id,
                                'endpoint': endpoint,
                                'status': response.status,
                                'error': await response.text(),
                                'timestamp': datetime.utcnow().isoformat()
                            })
                        
                        metrics['total_requests'] += 1
                        metrics['response_times'].append(response_time)
                
                except Exception as e:
                    metrics['failed_requests'] += 1
                    metrics['errors'].append({
                        'user_id': user_id,
                        'endpoint': endpoint,
                        'error': str(e),
                        'timestamp': datetime.utcnow().isoformat()
                    })
                    metrics['total_requests'] += 1
                
                # Very short delay for stress test
                await asyncio.sleep(0.01)
        
        except Exception as e:
            return {
                'user_id': user_id,
                'error': str(e)
            }
    
    def get_test_results(self, test_id: str) -> Dict:
        """Get results of a specific test"""
        return self.test_results.get(test_id, {})
    
    def get_all_test_results(self) -> Dict:
        """Get all test results"""
        return {
            'total_tests': len(self.test_results),
            'test_results': self.test_results,
            'last_updated': datetime.utcnow().isoformat()
        }
    
    def get_test_scenarios(self) -> Dict:
        """Get available test scenarios"""
        return {
            'total_scenarios': len(self.test_scenarios),
            'scenarios': self.test_scenarios
        }
    
    def generate_performance_report(self, test_id: str) -> Dict:
        """Generate performance report from test results"""
        try:
            test_result = self.test_results.get(test_id)
            if not test_result:
                return {'error': f"Test not found: {test_id}"}
            
            metrics = test_result.get('metrics', {})
            
            # Generate performance analysis
            report = {
                'test_id': test_id,
                'scenario_name': test_result.get('scenario_name'),
                'test_date': test_result.get('started_at'),
                'performance_analysis': {
                    'overall_score': self._calculate_performance_score(metrics),
                    'bottlenecks': self._identify_bottlenecks(metrics),
                    'recommendations': self._generate_performance_recommendations(metrics)
                },
                'detailed_metrics': metrics
            }
            
            return report
        
        except Exception as e:
            logger.error(f"Error generating performance report: {e}")
            return {'error': str(e)}
    
    def _calculate_performance_score(self, metrics: Dict) -> float:
        """Calculate overall performance score"""
        try:
            scores = []
            
            # Response time score (lower is better)
            if 'avg_response_time' in metrics:
                response_time_score = max(0, 100 - (metrics['avg_response_time'] * 10))  # 100ms = 0, 0ms = 100
                scores.append(response_time_score)
            
            # Throughput score (higher is better)
            if 'throughput' in metrics:
                throughput_score = min(100, metrics['throughput'] / 10)  # 1000 req/s = 100
                scores.append(throughput_score)
            
            # Error rate score (lower is better)
            if 'error_rate' in metrics:
                error_rate_score = max(0, 100 - metrics['error_rate'])
                scores.append(error_rate_score)
            
            return sum(scores) / len(scores) if scores else 0
        
        except Exception as e:
            logger.error(f"Error calculating performance score: {e}")
            return 0.0
    
    def _identify_bottlenecks(self, metrics: Dict) -> List[str]:
        """Identify performance bottlenecks"""
        try:
            bottlenecks = []
            
            # Check response time
            if 'avg_response_time' in metrics and metrics['avg_response_time'] > 1.0:
                bottlenecks.append("High response time detected")
            
            # Check error rate
            if 'error_rate' in metrics and metrics['error_rate'] > 5.0:
                bottlenecks.append("High error rate detected")
            
            # Check throughput
            if 'throughput' in metrics and metrics['throughput'] < 100:
                bottlenecks.append("Low throughput detected")
            
            return bottlenecks
        
        except Exception as e:
            logger.error(f"Error identifying bottlenecks: {e}")
            return ["Error identifying bottlenecks"]
    
    def _generate_performance_recommendations(self, metrics: Dict) -> List[str]:
        """Generate performance recommendations"""
        try:
            recommendations = []
            
            # Response time recommendations
            if 'avg_response_time' in metrics and metrics['avg_response_time'] > 0.5:
                recommendations.append("Optimize database queries")
                recommendations.append("Implement caching")
                recommendations.append("Add database indexes")
            
            # Error rate recommendations
            if 'error_rate' in metrics and metrics['error_rate'] > 2.0:
                recommendations.append("Improve error handling")
                recommendations.append("Add load balancing")
                recommendations.append("Increase server resources")
            
            # Throughput recommendations
            if 'throughput' in metrics and metrics['throughput'] < 200:
                recommendations.append("Scale horizontally")
                recommendations.append("Optimize application code")
                recommendations.append("Use connection pooling")
            
            return recommendations
        
        except Exception as e:
            logger.error(f"Error generating performance recommendations: {e}")
            return ["Error generating recommendations"]

# Global load testing framework instance
load_testing_framework = LoadTestingFramework()
