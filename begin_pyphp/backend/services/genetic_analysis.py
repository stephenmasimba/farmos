"""
FarmOS Genetic Analysis Service
Advanced breeding recommendations and genetic analysis for livestock
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

class GeneticAnalysis:
    """Genetic analysis service for livestock breeding optimization"""
    
    def __init__(self):
        self.genetic_database = {
            'poultry': {
                'broiler': {
                    'growth_rate': 0.035,      # kg per day
                    'feed_conversion': 1.8,      # feed:weight ratio
                    'mortality_rate': 0.02,     # 2% mortality
                    'market_weight': 2.5,        # kg at 6 weeks
                    'breeding_efficiency': 0.85
                },
                'layer': {
                    'growth_rate': 0.025,
                    'feed_conversion': 2.2,
                    'mortality_rate': 0.015,
                    'egg_production': 300,      # eggs per year
                    'breeding_efficiency': 0.80
                },
                'indigenous': {
                    'growth_rate': 0.020,
                    'feed_conversion': 3.0,
                    'mortality_rate': 0.035,
                    'disease_resistance': 0.90,
                    'breeding_efficiency': 0.75
                }
            },
            'pig': {
                'large_white': {
                    'growth_rate': 0.8,          # kg per day
                    'feed_conversion': 2.8,          # feed:weight ratio
                    'mortality_rate': 0.01,         # 1% mortality
                    'litter_size': 10,               # piglets per litter
                    'weaning_weight': 15.0,           # kg at 8 weeks
                    'breeding_efficiency': 0.85
                },
                'landrace': {
                    'growth_rate': 0.6,
                    'feed_conversion': 3.2,
                    'mortality_rate': 0.015,
                    'litter_size': 8,
                    'weaning_weight': 12.0,
                    'breeding_efficiency': 0.80
                },
                'crossbred': {
                    'growth_rate': 0.7,
                    'feed_conversion': 2.5,
                    'mortality_rate': 0.012,
                    'litter_size': 9,
                    'weaning_weight': 13.5,
                    'breeding_efficiency': 0.82
                }
            },
            'cattle': {
                'holstein': {
                    'growth_rate': 1.2,              # kg per day
                    'feed_conversion': 6.0,              # feed:weight ratio
                    'mortality_rate': 0.005,           # 0.5% mortality
                    'milk_production': 8000,           # liters per year
                    'calving_interval': 365,              # days
                    'breeding_efficiency': 0.90
                },
                'angus': {
                    'growth_rate': 0.9,
                    'feed_conversion': 7.0,
                    'mortality_rate': 0.003,
                    'milk_production': 4000,
                    'calving_interval': 365,
                    'breeding_efficiency': 0.85
                },
                'indigenous': {
                    'growth_rate': 0.5,
                    'feed_conversion': 8.0,
                    'mortality_rate': 0.008,
                    'disease_resistance': 0.95,
                    'heat_tolerance': 0.90,
                    'breeding_efficiency': 0.75
                }
            }
        }
        
        self.performance_weights = {
            'growth_rate': 0.25,
            'feed_conversion': 0.20,
            'mortality_rate': 0.25,
            'reproduction': 0.20,
            'disease_resistance': 0.10
        }
    
    def analyze_breeding_compatibility(self, sire_breed: str, dam_breed: str, species: str) -> Dict:
        """Analyze breeding compatibility between two breeds"""
        try:
            species_data = self.genetic_database.get(species.lower(), {})
            
            sire_data = species_data.get(sire_breed.lower(), {})
            dam_data = species_data.get(dam_breed.lower(), {})
            
            if not sire_data or not dam_data:
                return {
                    'compatibility_score': 0.0,
                    'recommendation': 'Unknown breeds',
                    'risks': ['Unknown genetic background']
                }
            
            # Calculate compatibility score
            compatibility_factors = []
            
            # Growth rate compatibility
            sire_growth = sire_data.get('growth_rate', 0)
            dam_growth = dam_data.get('growth_rate', 0)
            growth_diff = abs(sire_growth - dam_growth) / max(sire_growth, dam_growth)
            compatibility_factors.append(max(0, 1 - growth_diff * 2))
            
            # Feed conversion compatibility
            sire_fcr = sire_data.get('feed_conversion', 0)
            dam_fcr = dam_data.get('feed_conversion', 0)
            fcr_diff = abs(sire_fcr - dam_fcr) / max(sire_fcr, dam_fcr)
            compatibility_factors.append(max(0, 1 - fcr_diff))
            
            # Mortality rate compatibility
            sire_mort = sire_data.get('mortality_rate', 0)
            dam_mort = dam_data.get('mortality_rate', 0)
            mort_diff = abs(sire_mort - dam_mort) / max(sire_mort, dam_mort)
            compatibility_factors.append(max(0, 1 - mort_diff * 5))
            
            # Breeding efficiency compatibility
            sire_eff = sire_data.get('breeding_efficiency', 0)
            dam_eff = dam_data.get('breeding_efficiency', 0)
            eff_diff = abs(sire_eff - dam_eff) / max(sire_eff, dam_eff)
            compatibility_factors.append(max(0, 1 - eff_diff))
            
            # Calculate overall compatibility score
            compatibility_score = np.mean(compatibility_factors)
            
            # Generate recommendations
            if compatibility_score >= 0.8:
                recommendation = "Excellent compatibility"
                risks = []
            elif compatibility_score >= 0.6:
                recommendation = "Good compatibility"
                risks = ["Monitor offspring performance closely"]
            elif compatibility_score >= 0.4:
                recommendation = "Moderate compatibility"
                risks = ["Potential performance variation", "Consider crossbreeding benefits"]
            else:
                recommendation = "Poor compatibility"
                risks = ["High performance variation expected", "Consider alternative breeding pairs"]
            
            # Hybrid vigor prediction
            hybrid_vigor = self._predict_hybrid_vigor(sire_breed, dam_breed, species)
            
            return {
                'sire_breed': sire_breed,
                'dam_breed': dam_breed,
                'species': species,
                'compatibility_score': round(compatibility_score, 3),
                'recommendation': recommendation,
                'risks': risks,
                'hybrid_vigor_prediction': hybrid_vigor,
                'expected_offspring_performance': self._predict_offspring_performance(sire_data, dam_data),
                'analysis_date': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error analyzing breeding compatibility: {e}")
            return {
                'compatibility_score': 0.0,
                'recommendation': 'Analysis failed',
                'risks': [str(e)]
            }
    
    def _predict_hybrid_vigor(self, sire_breed: str, dam_breed: str, species: str) -> Dict:
        """Predict hybrid vigor from crossbreeding"""
        species_data = self.genetic_database.get(species.lower(), {})
        
        sire_data = species_data.get(sire_breed.lower(), {})
        dam_data = species_data.get(dam_breed.lower(), {})
        
        # Check if this is a crossbreed
        if sire_breed.lower() != dam_breed.lower():
            # Calculate heterosis (hybrid vigor)
            base_performance = (sire_data.get('growth_rate', 0) + dam_data.get('growth_rate', 0)) / 2
            
            # Estimate heterosis benefit (typically 10-20% improvement)
            heterosis_benefit = 0.15  # 15% improvement
            
            predicted_performance = base_performance * (1 + heterosis_benefit)
            
            return {
                'is_crossbred': True,
                'heterosis_benefit': round(heterosis_benefit * 100, 1),
                'predicted_performance_improvement': f"+{round(heterosis_benefit * 100, 1)}%",
                'base_performance': round(base_performance, 3),
                'predicted_performance': round(predicted_performance, 3)
            }
        else:
            return {
                'is_crossbred': False,
                'heterosis_benefit': 0,
                'predicted_performance_improvement': "0%",
                'base_performance': sire_data.get('growth_rate', 0),
                'predicted_performance': sire_data.get('growth_rate', 0)
            }
    
    def _predict_offspring_performance(self, sire_data: Dict, dam_data: Dict) -> Dict:
        """Predict offspring performance metrics"""
        # Average parent performance
        predicted_growth_rate = (sire_data.get('growth_rate', 0) + dam_data.get('growth_rate', 0)) / 2
        predicted_feed_conversion = (sire_data.get('feed_conversion', 0) + dam_data.get('feed_conversion', 0)) / 2
        predicted_mortality_rate = (sire_data.get('mortality_rate', 0) + dam_data.get('mortality_rate', 0)) / 2
        predicted_breeding_efficiency = (sire_data.get('breeding_efficiency', 0) + dam_data.get('breeding_efficiency', 0)) / 2
        
        return {
            'growth_rate': round(predicted_growth_rate, 3),
            'feed_conversion': round(predicted_feed_conversion, 2),
            'mortality_rate': round(predicted_mortality_rate, 4),
            'breeding_efficiency': round(predicted_breeding_efficiency, 3)
        }
    
    def recommend_optimal_breeding_pairs(self, herd_data: List[Dict], breeding_goals: Dict) -> List[Dict]:
        """Recommend optimal breeding pairs based on herd data and goals"""
        try:
            if not herd_data:
                return []
            
            df = pd.DataFrame(herd_data)
            
            # Group by breed
            breed_groups = df.groupby('breed').agg({
                'quantity': 'sum',
                'avg_performance': lambda x: x.get('performance_score', 0).mean()
            }).reset_index()
            
            recommendations = []
            
            # Sort by quantity and performance
            breed_groups = breed_groups.sort_values(['quantity', 'avg_performance'], ascending=[False, False])
            
            if len(breed_groups) >= 2:
                # Top performing breeds
                top_breeds = breed_groups.head(2)
                
                for i, breed1 in enumerate(top_breeds.itertuples()):
                    for j, breed2 in enumerate(top_breeds.itertuples()):
                        if i < j:  # Avoid duplicate pairs
                            sire_breed = breed1.breed
                            dam_breed = breed2.breed
                            
                            # Analyze compatibility
                            compatibility = self.analyze_breeding_compatibility(
                                sire_breed, dam_breed, breeding_goals.get('species', 'poultry')
                            )
                            
                            recommendations.append({
                                'sire_breed': sire_breed,
                                'dam_breed': dam_breed,
                                'sire_quantity': breed1.quantity,
                                'dam_quantity': breed2.quantity,
                                'compatibility_score': compatibility['compatibility_score'],
                                'recommendation': compatibility['recommendation'],
                                'expected_offspring': compatibility['expected_offspring_performance'],
                                'ranking_score': self._calculate_ranking_score(compatibility, breed1, breed2)
                            })
            
            # Sort by ranking score
            recommendations.sort(key=lambda x: x['ranking_score'], reverse=True)
            
            return recommendations[:10]  # Top 10 recommendations
            
        except Exception as e:
            logger.error(f"Error recommending breeding pairs: {e}")
            return []
    
    def _calculate_ranking_score(self, compatibility: Dict, sire_data: Dict, dam_data: Dict) -> float:
        """Calculate overall ranking score for breeding pair"""
        # Base compatibility score
        base_score = compatibility['compatibility_score']
        
        # Hybrid vigor bonus
        hybrid_bonus = 0
        if compatibility.get('hybrid_vigor_prediction', {}).get('is_crossbred', False):
            hybrid_bonus = 0.1  # 10% bonus for crossbreds
        
        # Performance weighting
        sire_performance = sire_data.get('growth_rate', 0)
        dam_performance = dam_data.get('growth_rate', 0)
        avg_performance = (sire_performance + dam_performance) / 2
        
        performance_weight = min(1.2, avg_performance / 0.8)  # Cap at 1.2
        
        # Calculate final score
        final_score = base_score * (1 + hybrid_bonus) * performance_weight
        
        return round(final_score, 3)
    
    def analyze_genetic_diversity(self, herd_data: List[Dict]) -> Dict:
        """Analyze genetic diversity in the herd"""
        try:
            if not herd_data:
                return {}
            
            df = pd.DataFrame(herd_data)
            
            # Calculate diversity metrics
            total_animals = df['quantity'].sum()
            breed_counts = df.groupby('breed')['quantity'].to_dict()
            
            # Calculate genetic diversity indices
            breed_diversity = len(breed_counts)
            simpson_index = sum((count / total_animals) ** 2 for count in breed_counts.values())
            
            # Effective population size (genetic diversity)
            effective_population = 1 / simpson_index if simpson_index > 0 else 0
            
            # Inbreeding coefficient estimation
            inbreeding_coefficient = (simpson_index - 1) / (len(breed_counts) - 1) if len(breed_counts) > 1 else 0
            
            # Diversity recommendations
            if simpson_index > 0.7:
                diversity_status = "Low"
                recommendations = [
                    "Consider introducing new genetic lines",
                    "Implement structured breeding program",
                    "Avoid mating closely related animals"
                ]
            elif simpson_index > 0.5:
                diversity_status = "Moderate"
                recommendations = [
                    "Monitor genetic diversity closely",
                    "Consider rotational breeding",
                    "Introduce new breeds periodically"
                ]
            else:
                diversity_status = "Good"
                recommendations = [
                    "Maintain current breeding strategy",
                    "Continue monitoring genetic diversity",
                    "Consider performance-based selection"
                ]
            
            return {
                'total_animals': total_animals,
                'breed_count': breed_diversity,
                'breed_distribution': breed_counts,
                'simpson_diversity_index': round(simpson_index, 4),
                'effective_population_size': round(effective_population, 1),
                'inbreeding_coefficient': round(inbreeding_coefficient, 4),
                'diversity_status': diversity_status,
                'recommendations': recommendations,
                'analysis_date': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error analyzing genetic diversity: {e}")
            return {}
    
    def generate_breeding_plan(self, breeding_pairs: List[Dict], timeline_months: int = 12) -> Dict:
        """Generate optimized breeding plan"""
        try:
            if not breeding_pairs:
                return {}
            
            plan = {
                'timeline': [],
                'resource_requirements': {},
                'success_metrics': {},
                'total_pairs': len(breeding_pairs)
            }
            
            # Generate monthly timeline
            for month in range(1, timeline_months + 1):
                month_plan = {
                    'month': month,
                    'activities': [],
                    'expected_outcomes': []
                }
                
                # Assign breeding pairs to months (simplified)
                pairs_per_month = max(1, len(breeding_pairs) // timeline_months)
                start_idx = (month - 1) * pairs_per_month
                end_idx = min(start_idx + pairs_per_month, len(breeding_pairs))
                
                month_pairs = breeding_pairs[start_idx:end_idx]
                
                for pair in month_pairs:
                    activity = {
                        'type': 'breeding',
                        'sire_breed': pair['sire_breed'],
                        'dam_breed': pair['dam_breed'],
                        'expected_litter_size': self._get_expected_litter_size(pair['sire_breed'], pair['dam_breed']),
                        'gestation_period': self._get_gestation_period(pair['sire_breed']),
                        'expected_birth_date': self._calculate_birth_date(month, self._get_gestation_period(pair['sire_breed']))
                    }
                    
                    month_plan['activities'].append(activity)
                    
                    # Expected outcomes
                    expected_offspring = activity['expected_litter_size'] * 0.9  # 90% survival rate
                    month_plan['expected_outcomes'].append({
                        'breed_type': f"{pair['sire_breed']} x {pair['dam_breed']}",
                        'expected_quantity': round(expected_offspring, 1),
                        'expected_performance': pair['expected_offspring_performance']
                    })
                
                plan['timeline'].append(month_plan)
            
            # Calculate resource requirements
            plan['resource_requirements'] = self._calculate_breeding_resources(breeding_pairs)
            
            # Success metrics
            plan['success_metrics'] = {
                'expected_total_offspring': sum(month['expected_outcomes'][0]['expected_quantity'] for month in plan['timeline']),
                'genetic_improvement': self._calculate_genetic_improvement(breeding_pairs),
                'estimated_cost_benefit': self._calculate_cost_benefit(breeding_pairs)
            }
            
            return plan
            
        except Exception as e:
            logger.error(f"Error generating breeding plan: {e}")
            return {}
    
    def _get_expected_litter_size(self, sire_breed: str, dam_breed: str) -> int:
        """Get expected litter size based on breed"""
        species = 'poultry'  # Default, can be extended
        
        breed_data = self.genetic_database.get(species, {})
        sire_data = breed_data.get(sire_breed.lower(), {})
        dam_data = breed_data.get(dam_breed.lower(), {})
        
        # Average litter sizes
        sire_litter = sire_data.get('litter_size', 8)
        dam_litter = dam_data.get('litter_size', 8)
        
        return max(1, round((sire_litter + dam_litter) / 2))
    
    def _get_gestation_period(self, breed: str) -> int:
        """Get gestation period in days"""
        species = 'pig'  # Default, can be extended
        
        breed_data = self.genetic_database.get(species, {})
        breed_info = breed_data.get(breed.lower(), {})
        
        # Default gestation periods
        gestation_periods = {
            'poultry': 21,    # 21 days incubation
            'pig': 115,       # 115 days gestation
            'cattle': 283      # 283 days gestation
        }
        
        return gestation_periods.get(species, 115)
    
    def _calculate_birth_date(self, month: int, gestation_period: int) -> str:
        """Calculate expected birth date"""
        from datetime import datetime, timedelta
        start_date = datetime(2025, month, 1)
        birth_date = start_date + timedelta(days=gestation_period)
        return birth_date.isoformat()
    
    def _calculate_breeding_resources(self, breeding_pairs: List[Dict]) -> Dict:
        """Calculate resource requirements for breeding program"""
        total_pairs = len(breeding_pairs)
        
        return {
            'breeding_spaces_needed': total_pairs,
            'feed_requirements': {
                'gestation_feed': total_pairs * 150,  # kg per breeding cycle
                'starter_feed': total_pairs * 50,    # kg for offspring
            },
            'labor_requirements': {
                'breeding_technician_hours': total_pairs * 2,  # hours per breeding
                'monitoring_hours_daily': total_pairs * 0.5
            },
            'facility_requirements': {
                'isolation_pens': total_pairs,
                'nursery_space': total_pairs * 10  # square meters
            },
            'equipment_needs': [
                'Breeding records system',
                'Health monitoring equipment',
                'Temperature control systems',
                'Genetic testing kits'
            ]
        }
    
    def _calculate_genetic_improvement(self, breeding_pairs: List[Dict]) -> Dict:
        """Calculate expected genetic improvement"""
        total_pairs = len(breeding_pairs)
        crossbred_pairs = len([p for p in breeding_pairs if p.get('hybrid_vigor_prediction', {}).get('is_crossbred', False)])
        
        return {
            'hybrid_vigor_pairs': crossbred_pairs,
            'expected_improvement': round((crossbred_pairs / total_pairs) * 15, 1),  # 15% improvement
            'genetic_diversity_increase': round((crossbred_pairs / total_pairs) * 25, 1)  # 25% diversity increase
            'performance_gain': round((crossbred_pairs / total_pairs) * 0.12, 2)  # 12% performance gain
        }
    
    def _calculate_cost_benefit(self, breeding_pairs: List[Dict]) -> Dict:
        """Calculate cost-benefit analysis"""
        total_pairs = len(breeding_pairs)
        
        # Costs
        breeding_costs = {
            'feed_costs': total_pairs * 50,      # $50 per breeding cycle
            'labor_costs': total_pairs * 25,       # $25 per breeding
            'facility_costs': total_pairs * 15,      # $15 per breeding
            'total_costs': total_pairs * 90
        }
        
        # Benefits
        avg_performance_gain = 0.10  # 10% performance improvement
        additional_revenue = total_pairs * 100  # $100 additional revenue per improved animal
        
        benefits = {
            'performance_improvement_value': total_pairs * 100 * avg_performance_gain,
            'additional_revenue': additional_revenue,
            'total_benefits': additional_revenue + (total_pairs * 100 * avg_performance_gain)
        }
        
        return {
            'costs': breeding_costs,
            'benefits': benefits,
            'net_benefit': benefits['total_benefits'] - breeding_costs['total_costs'],
            'return_on_investment': round((benefits['total_benefits'] / breeding_costs['total_costs']) * 100, 1) if breeding_costs['total_costs'] > 0 else 0,
            'payback_period_months': round(breeding_costs['total_costs'] / (additional_revenue / 12), 1) if additional_revenue > 0 else 0
        }

# Global genetic analysis instance
genetic_analysis = GeneticAnalysis()
