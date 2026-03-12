"""
Enhanced Load Testing - Phase 4 Feature
Advanced load testing with performance benchmarking, stress testing, and automated testing
Derived from Begin Reference System
"""

import logging
import asyncio
import json
import aiohttp
import time
import statistics
from typing import Dict, List, Optional, Any, Tuple, Callable
from datetime import datetime, timedelta
from collections import defaultdict, deque
from dataclasses import dataclass
from enum import Enum
import uuid
import concurrent.futures
import psutil

logger = logging.getLogger(__name__)

class TestType(Enum):
    LOAD_TEST = "load_test"
    STRESS_TEST = "stress_test"
    SPIKE_TEST = "spike_test"
    ENDURANCE_TEST = "endurance_test"
    VOLUME_TEST = "volume_test"

class TestStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

@dataclass
class TestScenario:
    scenario_id: str
    name: str
    description: str
    test_type: TestType
    target_url: str
    method: str
    headers: Dict[str, str]
    body: Optional[Dict[str, Any]]
    concurrent_users: int
    duration_seconds: int
    ramp_up_seconds: int
    think_time_ms: int

@dataclass
class TestResult:
    test_id: str
    scenario_id: str
    status: TestStatus
    start_time: datetime
    end_time: Optional[datetime]
    total_requests: int
    successful_requests: int
    failed_requests: int
    average_response_time: float
    min_response_time: float
    max_response_time: float
    p50_response_time: float
    p95_response_time: float
    p99_response_time: float
    throughput: float
    error_rate: float
    cpu_usage: float
    memory_usage: float

class VirtualUser:
    """Virtual user for load testing"""
    
    def __init__(self, user_id: int, scenario: TestScenario):
        self.user_id = user_id
        self.scenario = scenario
        self.session = None
        self.request_count = 0
        self.error_count = 0
        self.response_times = []
        self.status = "ready"
        
    async def initialize(self):
        """Initialize virtual user session"""
        try:
            self.session = aiohttp.ClientSession()
            self.status = "initialized"
        except Exception as e:
            logger.error(f"Error initializing virtual user {self.user_id}: {e}")
            self.status = "error"
    
    async def execute_request(self) -> Dict[str, Any]:
        """Execute a single request"""
        try:
            if not self.session:
                await self.initialize()
            
            start_time = time.time()
            
            # Prepare request
            url = self.scenario.target_url
            method = self.scenario.method.upper()
            headers = self.scenario.headers
            body = self.scenario.body
            
            # Execute request
            if method == 'GET':
                async with self.session.get(url, headers=headers) as response:
                    await response.read()
                    status_code = response.status
            elif method == 'POST':
                async with self.session.post(url, headers=headers, json=body) as response:
                    await response.read()
                    status_code = response.status
            elif method == 'PUT':
                async with self.session.put(url, headers=headers, json=body) as response:
                    await response.read()
                    status_code = response.status
            elif method == 'DELETE':
                async with self.session.delete(url, headers=headers) as response:
                    await response.read()
                    status_code = response.status
            else:
                return {"error": f"Unsupported method: {method}"}
            
            end_time = time.time()
            response_time = (end_time - start_time) * 1000  # Convert to ms
            
            self.request_count += 1
            self.response_times.append(response_time)
            
            if status_code >= 400:
                self.error_count += 1
            
            return {
                "user_id": self.user_id,
                "status_code": status_code,
                "response_time": response_time,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            self.error_count += 1
            return {
                "user_id": self.user_id,
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat()
            }
    
    async def cleanup(self):
        """Cleanup virtual user resources"""
        try:
            if self.session:
                await self.session.close()
            self.status = "completed"
        except Exception as e:
            logger.error(f"Error cleaning up virtual user {self.user_id}: {e}")

class LoadTestEngine:
    """Load testing engine"""
    
    def __init__(self):
        self.active_tests: Dict[str, Dict] = {}
        self.test_results: List[TestResult] = []
        self.system_monitor = SystemMonitor()
        
    async def create_test_scenario(self, scenario_config: Dict[str, Any]) -> Dict[str, Any]:
        """Create a test scenario"""
        try:
            scenario = TestScenario(
                scenario_id=str(uuid.uuid4()),
                name=scenario_config['name'],
                description=scenario_config.get('description', ''),
                test_type=TestType(scenario_config['test_type']),
                target_url=scenario_config['target_url'],
                method=scenario_config.get('method', 'GET'),
                headers=scenario_config.get('headers', {}),
                body=scenario_config.get('body'),
                concurrent_users=scenario_config['concurrent_users'],
                duration_seconds=scenario_config['duration_seconds'],
                ramp_up_seconds=scenario_config.get('ramp_up_seconds', 30),
                think_time_ms=scenario_config.get('think_time_ms', 1000)
            )
            
            return {
                "success": True,
                "scenario_id": scenario.scenario_id,
                "scenario": {
                    "id": scenario.scenario_id,
                    "name": scenario.name,
                    "test_type": scenario.test_type.value,
                    "target_url": scenario.target_url,
                    "concurrent_users": scenario.concurrent_users,
                    "duration_seconds": scenario.duration_seconds
                },
                "created_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error creating test scenario: {e}")
            return {"error": "Scenario creation failed"}
    
    async def execute_load_test(self, scenario_id: str, scenario_config: Dict[str, Any]) -> Dict[str, Any]:
        """Execute load test"""
        try:
            test_id = str(uuid.uuid4())
            
            # Create scenario
            scenario_result = await self.create_test_scenario(scenario_config)
            if not scenario_result.get('success'):
                return scenario_result
            
            scenario = TestScenario(
                scenario_id=scenario_result['scenario']['id'],
                name=scenario_result['scenario']['name'],
                description='',
                test_type=TestType(scenario_result['scenario']['test_type']),
                target_url=scenario_result['scenario']['target_url'],
                method=scenario_config.get('method', 'GET'),
                headers=scenario_config.get('headers', {}),
                body=scenario_config.get('body'),
                concurrent_users=scenario_result['scenario']['concurrent_users'],
                duration_seconds=scenario_result['scenario']['duration_seconds'],
                ramp_up_seconds=scenario_config.get('ramp_up_seconds', 30),
                think_time_ms=scenario_config.get('think_time_ms', 1000)
            )
            
            # Initialize test
            test_info = {
                "test_id": test_id,
                "scenario": scenario,
                "status": TestStatus.RUNNING,
                "start_time": datetime.utcnow(),
                "virtual_users": [],
                "results": [],
                "system_metrics": []
            }
            
            self.active_tests[test_id] = test_info
            
            # Start system monitoring
            await self.system_monitor.start_monitoring(test_id)
            
            # Execute test based on type
            if scenario.test_type == TestType.LOAD_TEST:
                result = await self._execute_load_test_scenario(test_id, scenario)
            elif scenario.test_type == TestType.STRESS_TEST:
                result = await self._execute_stress_test_scenario(test_id, scenario)
            elif scenario.test_type == TestType.SPIKE_TEST:
                result = await self._execute_spike_test_scenario(test_id, scenario)
            elif scenario.test_type == TestType.ENDURANCE_TEST:
                result = await self._execute_endurance_test_scenario(test_id, scenario)
            elif scenario.test_type == TestType.VOLUME_TEST:
                result = await self._execute_volume_test_scenario(test_id, scenario)
            else:
                result = {"error": f"Unsupported test type: {scenario.test_type}"}
            
            # Stop system monitoring
            system_metrics = await self.system_monitor.stop_monitoring(test_id)
            
            # Calculate final results
            if result.get('success'):
                final_result = await self._calculate_test_results(test_id, system_metrics)
                self.test_results.append(final_result)
            
            # Update test status
            self.active_tests[test_id]['status'] = TestStatus.COMPLETED if result.get('success') else TestStatus.FAILED
            self.active_tests[test_id]['end_time'] = datetime.utcnow()
            
            return {
                "success": result.get('success', False),
                "test_id": test_id,
                "scenario_id": scenario_id,
                "test_results": final_result if result.get('success') else None,
                "system_metrics": system_metrics,
                "execution_time": (datetime.utcnow() - test_info['start_time']).total_seconds(),
                "completed_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error executing load test: {e}")
            return {"error": "Load test execution failed"}
    
    async def _execute_load_test_scenario(self, test_id: str, scenario: TestScenario) -> Dict[str, Any]:
        """Execute standard load test scenario"""
        try:
            test_info = self.active_tests[test_id]
            virtual_users = []
            
            # Create virtual users
            for i in range(scenario.concurrent_users):
                user = VirtualUser(i, scenario)
                virtual_users.append(user)
                test_info['virtual_users'].append(user)
            
            # Ramp up users
            ramp_interval = scenario.ramp_up_seconds / scenario.concurrent_users
            
            # Start users gradually
            tasks = []
            for i, user in enumerate(virtual_users):
                await asyncio.sleep(ramp_interval)
                task = asyncio.create_task(self._run_user_session(user, scenario.duration_seconds))
                tasks.append(task)
            
            # Wait for all users to complete
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Collect results
            all_results = []
            for result in results:
                if isinstance(result, list):
                    all_results.extend(result)
            
            test_info['results'] = all_results
            
            # Cleanup users
            for user in virtual_users:
                await user.cleanup()
            
            return {"success": True, "total_requests": len(all_results)}
            
        except Exception as e:
            logger.error(f"Error in load test scenario: {e}")
            return {"error": "Load test scenario failed"}
    
    async def _execute_stress_test_scenario(self, test_id: str, scenario: TestScenario) -> Dict[str, Any]:
        """Execute stress test scenario"""
        try:
            # Stress test: gradually increase load beyond capacity
            max_users = scenario.concurrent_users * 2  # Double the load
            
            for phase in range(3):  # 3 phases of increasing load
                phase_users = scenario.concurrent_users + (phase * scenario.concurrent_users // 2)
                
                # Execute load phase
                phase_scenario = TestScenario(
                    scenario.scenario_id,
                    f"{scenario.name}_phase_{phase + 1}",
                    f"Stress test phase {phase + 1}",
                    scenario.test_type,
                    scenario.target_url,
                    scenario.method,
                    scenario.headers,
                    scenario.body,
                    phase_users,
                    60,  # 1 minute per phase
                    30,
                    scenario.think_time_ms
                )
                
                result = await self._execute_load_test_scenario(test_id, phase_scenario)
                if not result.get('success'):
                    return result
            
            return {"success": True, "message": "Stress test completed"}
            
        except Exception as e:
            logger.error(f"Error in stress test scenario: {e}")
            return {"error": "Stress test scenario failed"}
    
    async def _execute_spike_test_scenario(self, test_id: str, scenario: TestScenario) -> Dict[str, Any]:
        """Execute spike test scenario"""
        try:
            # Spike test: sudden burst of traffic
            spike_users = scenario.concurrent_users * 3  # Triple the load
            
            # Normal load phase
            await self._execute_load_test_scenario(test_id, scenario)
            
            # Spike phase
            spike_scenario = TestScenario(
                scenario.scenario_id,
                f"{scenario.name}_spike",
                "Spike test phase",
                scenario.test_type,
                scenario.target_url,
                scenario.method,
                scenario.headers,
                scenario.body,
                spike_users,
                30,  # 30 second spike
                5,   # Quick ramp-up
                scenario.think_time_ms
            )
            
            result = await self._execute_load_test_scenario(test_id, spike_scenario)
            
            # Recovery phase
            await asyncio.sleep(30)  # Wait for recovery
            
            return result
            
        except Exception as e:
            logger.error(f"Error in spike test scenario: {e}")
            return {"error": "Spike test scenario failed"}
    
    async def _execute_endurance_test_scenario(self, test_id: str, scenario: TestScenario) -> Dict[str, Any]:
        """Execute endurance test scenario"""
        try:
            # Endurance test: sustained load over long period
            endurance_duration = min(scenario.duration_seconds, 3600)  # Max 1 hour
            
            endurance_scenario = TestScenario(
                scenario.scenario_id,
                f"{scenario.name}_endurance",
                "Endurance test",
                scenario.test_type,
                scenario.target_url,
                scenario.method,
                scenario.headers,
                scenario.body,
                scenario.concurrent_users,
                endurance_duration,
                scenario.ramp_up_seconds,
                scenario.think_time_ms
            )
            
            return await self._execute_load_test_scenario(test_id, endurance_scenario)
            
        except Exception as e:
            logger.error(f"Error in endurance test scenario: {e}")
            return {"error": "Endurance test scenario failed"}
    
    async def _execute_volume_test_scenario(self, test_id: str, scenario: TestScenario) -> Dict[str, Any]:
        """Execute volume test scenario"""
        try:
            # Volume test: large amount of data
            volume_users = scenario.concurrent_users
            large_body = {"data": "x" * 10000}  # 10KB payload
            
            volume_scenario = TestScenario(
                scenario.scenario_id,
                f"{scenario.name}_volume",
                "Volume test",
                scenario.test_type,
                scenario.target_url,
                "POST",  # Use POST for data volume
                scenario.headers,
                large_body,
                volume_users,
                scenario.duration_seconds,
                scenario.ramp_up_seconds,
                scenario.think_time_ms
            )
            
            return await self._execute_load_test_scenario(test_id, volume_scenario)
            
        except Exception as e:
            logger.error(f"Error in volume test scenario: {e}")
            return {"error": "Volume test scenario failed"}
    
    async def _run_user_session(self, user: VirtualUser, duration_seconds: int) -> List[Dict]:
        """Run virtual user session"""
        try:
            results = []
            end_time = time.time() + duration_seconds
            
            await user.initialize()
            
            while time.time() < end_time:
                # Execute request
                result = await user.execute_request()
                results.append(result)
                
                # Think time
                if user.scenario.think_time_ms > 0:
                    await asyncio.sleep(user.scenario.think_time_ms / 1000)
            
            return results
            
        except Exception as e:
            logger.error(f"Error in user session: {e}")
            return [{"error": str(e), "user_id": user.user_id}]
    
    async def _calculate_test_results(self, test_id: str, system_metrics: List[Dict]) -> TestResult:
        """Calculate comprehensive test results"""
        try:
            test_info = self.active_tests[test_id]
            all_results = test_info['results']
            
            # Filter successful requests
            successful_results = [r for r in all_results if 'error' not in r and r.get('status_code', 200) < 400]
            failed_results = [r for r in all_results if 'error' in r or r.get('status_code', 200) >= 400]
            
            # Calculate response times
            response_times = [r['response_time'] for r in successful_results if 'response_time' in r]
            
            if response_times:
                avg_response_time = statistics.mean(response_times)
                min_response_time = min(response_times)
                max_response_time = max(response_times)
                p50_response_time = statistics.median(response_times)
                p95_response_time = self._percentile(response_times, 95)
                p99_response_time = self._percentile(response_times, 99)
            else:
                avg_response_time = min_response_time = max_response_time = 0
                p50_response_time = p95_response_time = p99_response_time = 0
            
            # Calculate throughput
            test_duration = (test_info['end_time'] - test_info['start_time']).total_seconds()
            throughput = len(successful_results) / test_duration if test_duration > 0 else 0
            
            # Calculate error rate
            error_rate = (len(failed_results) / len(all_results)) * 100 if all_results else 0
            
            # Get system metrics
            avg_cpu = statistics.mean([m['cpu_usage'] for m in system_metrics]) if system_metrics else 0
            avg_memory = statistics.mean([m['memory_usage'] for m in system_metrics]) if system_metrics else 0
            
            result = TestResult(
                test_id=test_id,
                scenario_id=test_info['scenario'].scenario_id,
                status=TestStatus.COMPLETED,
                start_time=test_info['start_time'],
                end_time=test_info['end_time'],
                total_requests=len(all_results),
                successful_requests=len(successful_results),
                failed_requests=len(failed_results),
                average_response_time=avg_response_time,
                min_response_time=min_response_time,
                max_response_time=max_response_time,
                p50_response_time=p50_response_time,
                p95_response_time=p95_response_time,
                p99_response_time=p99_response_time,
                throughput=throughput,
                error_rate=error_rate,
                cpu_usage=avg_cpu,
                memory_usage=avg_memory
            )
            
            return result
            
        except Exception as e:
            logger.error(f"Error calculating test results: {e}")
            # Return minimal result
            return TestResult(
                test_id=test_id,
                scenario_id="",
                status=TestStatus.FAILED,
                start_time=datetime.utcnow(),
                end_time=datetime.utcnow(),
                total_requests=0,
                successful_requests=0,
                failed_requests=0,
                average_response_time=0,
                min_response_time=0,
                max_response_time=0,
                p50_response_time=0,
                p95_response_time=0,
                p99_response_time=0,
                throughput=0,
                error_rate=100,
                cpu_usage=0,
                memory_usage=0
            )
    
    def _percentile(self, data: List[float], percentile: int) -> float:
        """Calculate percentile of data"""
        try:
            if not data:
                return 0
            sorted_data = sorted(data)
            index = (percentile / 100) * (len(sorted_data) - 1)
            if index.is_integer():
                return sorted_data[int(index)]
            else:
                lower = sorted_data[int(index)]
                upper = sorted_data[int(index) + 1]
                return lower + (upper - lower) * (index - int(index))
        except:
            return 0

class SystemMonitor:
    """System resource monitoring"""
    
    def __init__(self):
        self.monitoring_tasks: Dict[str, asyncio.Task] = {}
        self.metrics_buffers: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
        
    async def start_monitoring(self, test_id: str):
        """Start system monitoring for test"""
        try:
            task = asyncio.create_task(self._monitor_system(test_id))
            self.monitoring_tasks[test_id] = task
        except Exception as e:
            logger.error(f"Error starting system monitoring: {e}")
    
    async def stop_monitoring(self, test_id: str) -> List[Dict]:
        """Stop system monitoring and return metrics"""
        try:
            if test_id in self.monitoring_tasks:
                self.monitoring_tasks[test_id].cancel()
                del self.monitoring_tasks[test_id]
            
            metrics = list(self.metrics_buffers[test_id])
            del self.metrics_buffers[test_id]
            
            return metrics
            
        except Exception as e:
            logger.error(f"Error stopping system monitoring: {e}")
            return []
    
    async def _monitor_system(self, test_id: str):
        """Monitor system resources"""
        try:
            while True:
                # Get CPU usage
                cpu_usage = psutil.cpu_percent(interval=1)
                
                # Get memory usage
                memory = psutil.virtual_memory()
                memory_usage = memory.percent
                
                # Get network I/O
                network = psutil.net_io_counters()
                
                # Get disk I/O
                disk = psutil.disk_io_counters()
                
                metric = {
                    "timestamp": datetime.utcnow().isoformat(),
                    "cpu_usage": cpu_usage,
                    "memory_usage": memory_usage,
                    "memory_total_gb": memory.total / (1024**3),
                    "memory_used_gb": memory.used / (1024**3),
                    "network_bytes_sent": network.bytes_sent,
                    "network_bytes_recv": network.bytes_recv,
                    "disk_read_bytes": disk.read_bytes,
                    "disk_write_bytes": disk.write_bytes
                }
                
                self.metrics_buffers[test_id].append(metric)
                
                await asyncio.sleep(1)  # Sample every second
                
        except asyncio.CancelledError:
            logger.info(f"System monitoring cancelled for test {test_id}")
        except Exception as e:
            logger.error(f"Error in system monitoring: {e}")

class EnhancedLoadTestingService:
    """Enhanced load testing service"""
    
    def __init__(self):
        self.test_engine = LoadTestEngine()
        self.test_templates: Dict[str, Dict] = {}
        self.benchmark_results: Dict[str, Any] = {}
        
    async def create_test_template(self, template_config: Dict[str, Any]) -> Dict[str, Any]:
        """Create reusable test template"""
        try:
            template_id = str(uuid.uuid4())
            
            template = {
                "template_id": template_id,
                "name": template_config['name'],
                "description": template_config.get('description', ''),
                "test_type": template_config['test_type'],
                "target_url": template_config['target_url'],
                "method": template_config.get('method', 'GET'),
                "headers": template_config.get('headers', {}),
                "body": template_config.get('body'),
                "concurrent_users": template_config.get('concurrent_users', 10),
                "duration_seconds": template_config.get('duration_seconds', 60),
                "ramp_up_seconds": template_config.get('ramp_up_seconds', 30),
                "think_time_ms": template_config.get('think_time_ms', 1000),
                "created_at": datetime.utcnow().isoformat()
            }
            
            self.test_templates[template_id] = template
            
            return {
                "success": True,
                "template_id": template_id,
                "template": template,
                "message": "Test template created successfully"
            }
            
        except Exception as e:
            logger.error(f"Error creating test template: {e}")
            return {"error": "Template creation failed"}
    
    async def run_test_from_template(self, template_id: str, overrides: Optional[Dict] = None) -> Dict[str, Any]:
        """Run test using template"""
        try:
            template = self.test_templates.get(template_id)
            if not template:
                return {"error": "Template not found"}
            
            # Apply overrides
            test_config = template.copy()
            if overrides:
                test_config.update(overrides)
            
            # Remove template-specific fields
            test_config.pop('template_id', None)
            test_config.pop('created_at', None)
            
            # Execute test
            result = await self.test_engine.execute_load_test(template_id, test_config)
            
            return result
            
        except Exception as e:
            logger.error(f"Error running test from template: {e}")
            return {"error": "Test execution failed"}
    
    async def get_test_results(self, test_id: Optional[str] = None) -> Dict[str, Any]:
        """Get test results"""
        try:
            if test_id:
                # Get specific test result
                for result in self.test_engine.test_results:
                    if result.test_id == test_id:
                        return {
                            "success": True,
                            "test_result": {
                                "test_id": result.test_id,
                                "scenario_id": result.scenario_id,
                                "status": result.status.value,
                                "start_time": result.start_time.isoformat(),
                                "end_time": result.end_time.isoformat() if result.end_time else None,
                                "total_requests": result.total_requests,
                                "successful_requests": result.successful_requests,
                                "failed_requests": result.failed_requests,
                                "average_response_time": result.average_response_time,
                                "p95_response_time": result.p95_response_time,
                                "p99_response_time": result.p99_response_time,
                                "throughput": result.throughput,
                                "error_rate": result.error_rate,
                                "cpu_usage": result.cpu_usage,
                                "memory_usage": result.memory_usage
                            }
                        }
                
                return {"error": "Test result not found"}
            else:
                # Get all test results
                all_results = []
                for result in self.test_engine.test_results:
                    all_results.append({
                        "test_id": result.test_id,
                        "scenario_id": result.scenario_id,
                        "status": result.status.value,
                        "start_time": result.start_time.isoformat(),
                        "total_requests": result.total_requests,
                        "average_response_time": result.average_response_time,
                        "throughput": result.throughput,
                        "error_rate": result.error_rate
                    })
                
                return {
                    "success": True,
                    "test_results": all_results,
                    "total_tests": len(all_results)
                }
                
        except Exception as e:
            logger.error(f"Error getting test results: {e}")
            return {"error": "Results retrieval failed"}
    
    async def generate_performance_report(self, test_id: str) -> Dict[str, Any]:
        """Generate comprehensive performance report"""
        try:
            # Get test result
            result_data = await self.get_test_results(test_id)
            if not result_data.get('success'):
                return result_data
            
            result = result_data['test_result']
            
            # Generate report
            report = {
                "test_id": test_id,
                "report_generated_at": datetime.utcnow().isoformat(),
                "executive_summary": {
                    "overall_performance": "good" if result['error_rate'] < 5 else "poor",
                    "recommendation": "System performs well under normal load" if result['error_rate'] < 5 else "System needs optimization",
                    "key_metrics": {
                        "requests_per_second": result['throughput'],
                        "average_response_time": result['average_response_time'],
                        "error_rate": result['error_rate']
                    }
                },
                "performance_analysis": {
                    "response_time_analysis": {
                        "min": result['min_response_time'],
                        "max": result['max_response_time'],
                        "average": result['average_response_time'],
                        "p50": result['p50_response_time'],
                        "p95": result['p95_response_time'],
                        "p99": result['p99_response_time']
                    },
                    "throughput_analysis": {
                        "requests_per_second": result['throughput'],
                        "total_requests": result['total_requests'],
                        "successful_requests": result['successful_requests'],
                        "failed_requests": result['failed_requests']
                    },
                    "error_analysis": {
                        "error_rate": result['error_rate'],
                        "total_errors": result['failed_requests'],
                        "error_categories": self._categorize_errors(test_id)
                    }
                },
                "system_performance": {
                    "cpu_usage": result['cpu_usage'],
                    "memory_usage": result['memory_usage'],
                    "resource_efficiency": "good" if result['cpu_usage'] < 80 and result['memory_usage'] < 80 else "poor"
                },
                "recommendations": self._generate_recommendations(result)
            }
            
            return {
                "success": True,
                "performance_report": report
            }
            
        except Exception as e:
            logger.error(f"Error generating performance report: {e}")
            return {"error": "Report generation failed"}
    
    def _categorize_errors(self, test_id: str) -> Dict[str, int]:
        """Categorize errors by type"""
        try:
            test_info = self.test_engine.active_tests.get(test_id, {})
            all_results = test_info.get('results', [])
            
            error_categories = defaultdict(int)
            
            for result in all_results:
                if 'error' in result:
                    error_categories['connection_error'] += 1
                elif result.get('status_code', 200) >= 500:
                    error_categories['server_error'] += 1
                elif result.get('status_code', 200) >= 400:
                    error_categories['client_error'] += 1
            
            return dict(error_categories)
            
        except Exception as e:
            logger.error(f"Error categorizing errors: {e}")
            return {}
    
    def _generate_recommendations(self, result: Dict[str, Any]) -> List[str]:
        """Generate performance recommendations"""
        try:
            recommendations = []
            
            # Response time recommendations
            if result['average_response_time'] > 1000:
                recommendations.append("Consider optimizing database queries and adding caching")
            
            if result['p95_response_time'] > 2000:
                recommendations.append("Investigate slow outliers and optimize critical paths")
            
            # Error rate recommendations
            if result['error_rate'] > 5:
                recommendations.append("High error rate detected - check application logs and fix bugs")
            
            # Throughput recommendations
            if result['throughput'] < 100:
                recommendations.append("Low throughput - consider scaling up or optimizing performance")
            
            # System resource recommendations
            if result['cpu_usage'] > 80:
                recommendations.append("High CPU usage - consider scaling or optimizing CPU-intensive operations")
            
            if result['memory_usage'] > 80:
                recommendations.append("High memory usage - check for memory leaks and optimize memory usage")
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating recommendations: {e}")
            return []

# Global load testing service instance
load_testing_service = EnhancedLoadTestingService()
