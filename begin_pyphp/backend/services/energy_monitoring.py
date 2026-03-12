"""
Energy Monitoring Module - Phase 2 Feature
Handles solar power generation, biogas production, and energy consumption tracking
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class EnergyMonitoringService:
    """Energy monitoring service for solar and biogas systems"""
    
    def __init__(self):
        self.energy_systems = {}
        self.power_sources = {}
        self.consumption_data = {}
        self.battery_systems = {}
        self.is_running = False
        
        # Initialize energy systems
        self._initialize_solar_systems()
        self._initialize_biogas_systems()
        self._initialize_battery_systems()
        self._initialize_consumption_tracking()
        
    def _initialize_solar_systems(self):
        """Initialize solar power generation systems"""
        self.energy_systems['solar'] = {
            'name': 'Solar Power Generation',
            'description': 'Photovoltaic solar array with battery storage',
            'panels': [
                {
                    'id': 'array_001',
                    'name': 'Main Solar Array',
                    'capacity': 10000,  # Watts (10kW)
                    'type': 'monocrystalline',
                    'orientation': 'south',
                    'tilt_angle': 30,
                    'efficiency': 0.22,
                    'temperature_coefficient': -0.004,
                    'current_output': 0,
                    'daily_energy': 0,
                    'status': 'active',
                    'last_maintenance': datetime.utcnow() - timedelta(days=45)
                },
                {
                    'id': 'array_002',
                    'name': 'Backup Solar Array',
                    'capacity': 5000,  # Watts (5kW)
                    'type': 'polycrystalline',
                    'orientation': 'south-east',
                    'tilt_angle': 25,
                    'efficiency': 0.18,
                    'temperature_coefficient': -0.005,
                    'current_output': 0,
                    'daily_energy': 0,
                    'status': 'active',
                    'last_maintenance': datetime.utcnow() - timedelta(days=30)
                }
            ],
            'total_capacity': 15000,  # 15kW total
            'inverter': {
                'id': 'inverter_001',
                'name': 'Hybrid Inverter',
                'capacity': 20000,  # 20kW
                'efficiency': 0.96,
                'input_voltage': '48V DC',
                'output_voltage': '230V AC',
                'status': 'active',
                'grid_tie_enabled': False,
                'battery_integration': True
            }
        }
    
    def _initialize_biogas_systems(self):
        """Initialize biogas production and utilization"""
        self.energy_systems['biogas'] = {
            'name': 'Biogas Production System',
            'description': 'Anaerobic digestion for waste-to-energy conversion',
            'digester': {
                'id': 'digester_001',
                'name': 'Main Biogas Digester',
                'capacity': 5000,  # Liters
                'current_level': 3500,
                'temperature': 38.5,  # Optimal mesophilic range
                'ph_level': 7.2,
                'pressure': 0.8,  # Bar
                'gas_production_rate': 2.5,  # m³/day
                'feedstock_input': 150,  # kg/day
                'status': 'active',
                'heating_power': 500,  # Watts
                'mixing_power': 200  # Watts
            },
            'gas_storage': {
                'id': 'storage_001',
                'name': 'Biogas Storage Bag',
                'capacity': 100,  # m³
                'current_volume': 75,
                'pressure': 0.5,
                'methane_content': 65,  # Percentage
                'temperature': 25,
                'safety_valve_status': 'normal'
            },
            'utilization': [
                {
                    'id': 'cooking_001',
                    'name': 'Kitchen Cooking Stove',
                    'consumption_rate': 0.8,  # m³/hour
                    'daily_usage': 2.4,
                    'status': 'active',
                    'efficiency': 0.85
                },
                {
                    'id': 'generator_001',
                    'name': 'Backup Generator',
                    'consumption_rate': 2.0,  # m³/hour
                    'power_output': 5000,  # Watts
                    'status': 'standby',
                    'efficiency': 0.35,
                    'runtime_today': 0
                }
            ]
        }
    
    def _initialize_battery_systems(self):
        """Initialize battery storage systems"""
        self.battery_systems = {
            'main_battery_bank': {
                'id': 'battery_001',
                'name': 'Main Battery Bank',
                'type': 'lithium_iron_phosphate',
                'capacity': 20000,  # Wh (20kWh)
                'current_charge': 15000,  # Wh
                'charge_percentage': 75,
                'voltage': 48.2,
                'current': 0,
                'temperature': 25,
                'cycle_count': 1250,
                'max_cycles': 5000,
                'health_percentage': 95,
                'charge_controller': {
                    'id': 'controller_001',
                    'name': 'MPPT Charge Controller',
                    'max_current': 100,  # Amps
                    'efficiency': 0.98,
                    'status': 'active'
                }
            },
            'backup_battery_bank': {
                'id': 'battery_002',
                'name': 'Backup Battery Bank',
                'type': 'lead_acid',
                'capacity': 10000,  # Wh (10kWh)
                'current_charge': 6000,  # Wh
                'charge_percentage': 60,
                'voltage': 47.8,
                'current': 0,
                'temperature': 28,
                'cycle_count': 800,
                'max_cycles': 1500,
                'health_percentage': 85,
                'charge_controller': {
                    'id': 'controller_002',
                    'name': 'PWM Charge Controller',
                    'max_current': 50,
                    'efficiency': 0.92,
                    'status': 'active'
                }
            }
        }
    
    def _initialize_consumption_tracking(self):
        """Initialize energy consumption monitoring"""
        self.consumption_data = {
            'loads': [
                {
                    'id': 'load_001',
                    'name': 'Water Pumps',
                    'category': 'irrigation',
                    'rated_power': 3000,  # Watts
                    'current_power': 0,
                    'daily_consumption': 0,
                    'status': 'automatic',
                    'priority': 'high'
                },
                {
                    'id': 'load_002',
                    'name': 'Aquaculture Aerators',
                    'category': 'aquaculture',
                    'rated_power': 2000,  # Watts
                    'current_power': 1800,
                    'daily_consumption': 43.2,  # kWh
                    'status': 'continuous',
                    'priority': 'high'
                },
                {
                    'id': 'load_003',
                    'name': 'Feed Mill',
                    'category': 'processing',
                    'rated_power': 5000,  # Watts
                    'current_power': 0,
                    'daily_consumption': 0,
                    'status': 'manual',
                    'priority': 'medium'
                },
                {
                    'id': 'load_004',
                    'name': 'Lighting Systems',
                    'category': 'infrastructure',
                    'rated_power': 1000,  # Watts
                    'current_power': 800,
                    'daily_consumption': 19.2,
                    'status': 'automatic',
                    'priority': 'medium'
                },
                {
                    'id': 'load_005',
                    'name': 'Cold Storage',
                    'category': 'storage',
                    'rated_power': 4000,  # Watts
                    'current_power': 3500,
                    'daily_consumption': 84.0,
                    'status': 'continuous',
                    'priority': 'high'
                }
            ],
            'total_consumption': 0,
            'peak_demand': 0,
            'power_factor': 0.95
        }
    
    async def start_energy_monitoring(self):
        """Start energy monitoring service"""
        try:
            if self.is_running:
                logger.warning("Energy monitoring service is already running")
                return
            
            self.is_running = True
            logger.info("Starting energy monitoring service")
            
            # Start solar monitoring
            await self._start_solar_monitoring()
            
            # Start biogas monitoring
            await self._start_biogas_monitoring()
            
            # Start consumption monitoring
            await self._start_consumption_monitoring()
            
            # Start battery monitoring
            await self._start_battery_monitoring()
            
            return {
                "status": "success",
                "message": "Energy monitoring service started",
                "started_at": datetime.utcnow().isoformat(),
                "solar_capacity": self.energy_systems['solar']['total_capacity'],
                "biogas_production": self.energy_systems['biogas']['digester']['gas_production_rate'],
                "battery_capacity": sum(b['capacity'] for b in self.battery_systems.values())
            }
        
        except Exception as e:
            logger.error(f"Error starting energy monitoring service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _start_solar_monitoring(self):
        """Monitor solar power generation"""
        while self.is_running:
            try:
                # Simulate solar generation based on time of day
                current_hour = datetime.utcnow().hour
                solar_irradiance = self._calculate_solar_irradiance(current_hour)
                
                for panel in self.energy_systems['solar']['panels']:
                    if panel['status'] == 'active':
                        # Calculate power output considering efficiency and temperature
                        temperature = 25 + (current_hour - 12) * 2  # Simulated temperature
                        temp_factor = 1 + (temperature - 25) * panel['temperature_coefficient']
                        
                        panel['current_output'] = (
                            panel['capacity'] * 
                            solar_irradiance * 
                            panel['efficiency'] * 
                            temp_factor
                        )
                        
                        # Update daily energy
                        panel['daily_energy'] += panel['current_output'] / 1000  # Convert to kWh
                
                await asyncio.sleep(300)  # Update every 5 minutes
                
            except Exception as e:
                logger.error(f"Error in solar monitoring: {e}")
                await asyncio.sleep(300)
    
    def _calculate_solar_irradiance(self, hour: int) -> float:
        """Calculate solar irradiance based on time of day"""
        # Simple bell curve for daylight hours (6:00-18:00)
        if 6 <= hour <= 18:
            # Peak at noon (hour 12)
            peak_irradiance = 1.0
            width = 6.0  # Standard deviation
            center = 12.0
            
            irradiance = peak_irradiance * math.exp(-((hour - center) ** 2) / (2 * width ** 2))
            return max(0, min(1, irradiance))
        return 0
    
    async def _start_biogas_monitoring(self):
        """Monitor biogas production and utilization"""
        while self.is_running:
            try:
                digester = self.energy_systems['biogas']['digester']
                storage = self.energy_systems['biogas']['gas_storage']
                
                # Update gas production
                production_rate = digester['gas_production_rate']
                new_gas = production_rate / (24 * 60)  # m³ per minute
                
                storage['current_volume'] = min(
                    storage['capacity'],
                    storage['current_volume'] + new_gas
                )
                
                # Update utilization
                for utilization in self.energy_systems['biogas']['utilization']:
                    if utilization['status'] == 'active':
                        consumption = utilization['consumption_rate'] / 60  # m³ per minute
                        storage['current_volume'] = max(0, storage['current_volume'] - consumption)
                
                # Update digester metrics
                digester['current_level'] = 3500 + (hash(str(datetime.utcnow())) % 500) - 250
                digester['temperature'] = 38.5 + (hash(str(datetime.utcnow())) % 3) - 1.5
                digester['ph_level'] = 7.2 + (hash(str(datetime.utcnow())) % 40) / 100 - 0.2
                
                await asyncio.sleep(60)  # Update every minute
                
            except Exception as e:
                logger.error(f"Error in biogas monitoring: {e}")
                await asyncio.sleep(60)
    
    async def _start_consumption_monitoring(self):
        """Monitor energy consumption by loads"""
        while self.is_running:
            try:
                total_consumption = 0
                peak_demand = 0
                
                for load in self.consumption_data['loads']:
                    if load['status'] in ['active', 'continuous']:
                        # Simulate power consumption
                        if load['id'] == 'load_001':  # Water pumps
                            load['current_power'] = 3000 if datetime.utcnow().hour in [6, 18] else 0
                        elif load['id'] == 'load_002':  # Aerators
                            load['current_power'] = 1800  # Continuous
                        elif load['id'] == 'load_003':  # Feed mill
                            load['current_power'] = 5000 if datetime.utcnow().hour in [8, 14, 20] else 0
                        elif load['id'] == 'load_004':  # Lighting
                            load['current_power'] = 1000 if 18 <= datetime.utcnow().hour <= 6 else 0
                        elif load['id'] == 'load_005':  # Cold storage
                            load['current_power'] = 3500  # Continuous
                        
                        total_consumption += load['current_power']
                        peak_demand = max(peak_demand, load['current_power'])
                        
                        # Update daily consumption
                        load['daily_consumption'] += load['current_power'] / 1000  # Convert to kWh
                
                self.consumption_data['total_consumption'] = total_consumption
                self.consumption_data['peak_demand'] = peak_demand
                
                await asyncio.sleep(300)  # Update every 5 minutes
                
            except Exception as e:
                logger.error(f"Error in consumption monitoring: {e}")
                await asyncio.sleep(300)
    
    async def _start_battery_monitoring(self):
        """Monitor battery charge and health"""
        while self.is_running:
            try:
                # Calculate net power (generation - consumption)
                solar_generation = sum(p['current_output'] for p in self.energy_systems['solar']['panels'])
                total_consumption = self.consumption_data['total_consumption']
                net_power = solar_generation - total_consumption
                
                # Update main battery
                main_battery = self.battery_systems['main_battery_bank']
                if net_power > 0:  # Charging
                    main_battery['current'] = min(100, net_power / main_battery['voltage'])
                    main_battery['current_charge'] = min(
                        main_battery['capacity'],
                        main_battery['current_charge'] + net_power / 12  # 5-minute interval
                    )
                else:  # Discharging
                    main_battery['current'] = max(-100, net_power / main_battery['voltage'])
                    main_battery['current_charge'] = max(
                        0,
                        main_battery['current_charge'] + net_power / 12
                    )
                
                main_battery['charge_percentage'] = (
                    main_battery['current_charge'] / main_battery['capacity'] * 100
                )
                
                # Update backup battery (simpler logic)
                backup_battery = self.battery_systems['backup_battery_bank']
                if main_battery['charge_percentage'] > 90:
                    # Transfer to backup
                    backup_battery['current_charge'] = min(
                        backup_battery['capacity'],
                        backup_battery['current_charge'] + 100
                    )
                elif main_battery['charge_percentage'] < 30 and backup_battery['charge_percentage'] > 20:
                    # Transfer from backup
                    transfer_amount = min(100, backup_battery['current_charge'])
                    backup_battery['current_charge'] -= transfer_amount
                    main_battery['current_charge'] += transfer_amount
                
                backup_battery['charge_percentage'] = (
                    backup_battery['current_charge'] / backup_battery['capacity'] * 100
                )
                
                await asyncio.sleep(300)  # Update every 5 minutes
                
            except Exception as e:
                logger.error(f"Error in battery monitoring: {e}")
                await asyncio.sleep(300)
    
    async def get_energy_status(self) -> Dict:
        """Get current energy system status"""
        try:
            return {
                'solar_systems': self.energy_systems['solar'],
                'biogas_systems': self.energy_systems['biogas'],
                'battery_systems': self.battery_systems,
                'consumption_data': self.consumption_data,
                'energy_balance': {
                    'generation': sum(p['current_output'] for p in self.energy_systems['solar']['panels']),
                    'consumption': self.consumption_data['total_consumption'],
                    'net_power': sum(p['current_output'] for p in self.energy_systems['solar']['panels']) - self.consumption_data['total_consumption'],
                    'battery_level': self.battery_systems['main_battery_bank']['charge_percentage']
                },
                'system_status': 'operational' if self.is_running else 'stopped',
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting energy status: {e}")
            return {
                'error': str(e),
                'system_status': 'error'
            }
    
    async def get_energy_reports(self, period: str = 'daily') -> Dict:
        """Generate energy monitoring reports"""
        try:
            # Generate mock report data
            reports = {
                'daily': {
                    'period': 'Last 24 hours',
                    'solar_generation': 85.5,  # kWh
                    'biogas_production': 60.0,  # m³
                    'total_consumption': 146.4,  # kWh
                    'peak_demand': 8.5,  # kW
                    'battery_efficiency': 92.5,
                    'energy_independence': 58.4,  # Percentage
                    'cost_savings': 28.75,  # USD
                    'co2_offset': 45.2,  # kg
                    'breakdown': {
                        'solar_contribution': 58.4,
                        'biogas_contribution': 15.2,
                        'grid_import': 26.4
                    }
                },
                'weekly': {
                    'period': 'Last 7 days',
                    'solar_generation': 598.5,
                    'biogas_production': 420.0,
                    'total_consumption': 1024.8,
                    'peak_demand': 12.3,
                    'battery_efficiency': 91.2,
                    'energy_independence': 58.4,
                    'cost_savings': 201.25,
                    'co2_offset': 316.4,
                    'trend': '+3.2%',
                    'best_day': 'Wednesday',
                    'worst_day': 'Sunday'
                },
                'monthly': {
                    'period': 'Last 30 days',
                    'solar_generation': 2565.0,
                    'biogas_production': 1800.0,
                    'total_consumption': 4392.0,
                    'peak_demand': 15.8,
                    'battery_efficiency': 90.5,
                    'energy_independence': 58.4,
                    'cost_savings': 862.50,
                    'co2_offset': 1356.0,
                    'trend': '+8.7%',
                    'comparison_to_target': '+5.2%',
                    'recommendations': [
                        'Optimize load scheduling during peak solar hours',
                        'Consider expanding battery storage capacity',
                        'Schedule regular solar panel cleaning'
                    ]
                }
            }
            
            return {
                'success': True,
                'report': reports.get(period, reports['daily']),
                'generated_at': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error generating energy reports: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def control_load(self, load_id: str, action: str, parameters: Dict = None) -> Dict:
        """Control energy loads"""
        try:
            for load in self.consumption_data['loads']:
                if load['id'] == load_id:
                    if action == 'turn_on':
                        load['status'] = 'active'
                        logger.info(f"Turned on load {load_id}")
                    
                    elif action == 'turn_off':
                        load['status'] = 'manual_off'
                        load['current_power'] = 0
                        logger.info(f"Turned off load {load_id}")
                    
                    elif action == 'set_power':
                        if parameters and 'power' in parameters:
                            load['current_power'] = parameters['power']
                            logger.info(f"Set load {load_id} power to {parameters['power']}W")
                    
                    return {
                        'success': True,
                        'load_id': load_id,
                        'action': action,
                        'load_status': load['status'],
                        'current_power': load['current_power']
                    }
            
            return {
                'success': False,
                'error': f'Load {load_id} not found'
            }
        
        except Exception as e:
            logger.error(f"Error controlling load {load_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def stop_energy_monitoring(self):
        """Stop energy monitoring service"""
        try:
            self.is_running = False
            
            logger.info("Energy monitoring service stopped")
            
            return {
                "status": "success",
                "message": "Energy monitoring service stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping energy monitoring service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }

# Import math for calculations
import math

# Global energy monitoring service instance
energy_monitoring_service = EnergyMonitoringService()
