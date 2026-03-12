"""
FarmOS Database Query Optimization Service
Database query optimization for improved performance
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import text, func, Index, and_
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class DatabaseOptimizationService:
    """Database query optimization service"""
    
    def __init__(self):
        self.query_performance = {}
        self.slow_queries = []
        self.optimization_suggestions = []
        self.index_recommendations = []
        self.is_running = False
        
        # Initialize optimization settings
        self.optimization_settings = {
            'slow_query_threshold': 1.0,  # seconds
            'frequent_query_threshold': 100,  # executions per hour
            'index_usage_threshold': 0.8,  # 80% usage
            'connection_pool_max_size': 20,
            'query_cache_ttl': 300,  # 5 minutes
            'batch_size_limit': 1000
            'join_optimization': True,
            'statistics_update_interval': 3600  # 1 hour
        }
        
        # Initialize query patterns
        self.query_patterns = {
            'n_plus_1': {
                'description': 'SELECT N+1 query without WHERE clause',
                'examples': [
                    'SELECT * FROM users WHERE id = ?',
                    'SELECT * FROM livestock_batches WHERE status = ? ORDER BY created_at DESC',
                    'SELECT * FROM financial_transactions WHERE amount > ? ORDER BY created_at DESC'
                ],
                'risk_level': 'high',
                'optimization': 'Add WHERE clause or index'
            },
            'full_table_scan': {
                'SELECT * FROM large_table',
                'risk_level': 'high',
                'optimization': 'Add specific WHERE clause or use pagination'
            },
            'missing_index': {
                'SELECT * FROM table WHERE column = ?',
                'risk_level': 'medium',
                'optimization': 'Add index on column'
            },
            'cartesian_explosion': {
                'SELECT * FROM table1 t1 JOIN table2 t2 ON t1.id = t2.id',
                'risk_level': 'high',
                'optimization': 'Avoid cartesian joins or limit result set'
            },
            'subquery_in_select': {
                'SELECT * FROM table WHERE id IN (SELECT id FROM other_table WHERE condition = ?)',
                'risk_level': 'medium',
                'optimization': 'Use JOIN or EXISTS instead'
            },
            'string_concatenation': {
                'SELECT * FROM table WHERE name LIKE ?',
                'risk_level': 'medium',
                'optimization': 'Use full-text search or proper indexing'
            },
            'order_by_random': {
                'SELECT * FROM table ORDER BY RAND() LIMIT ?',
                'risk_level': 'low',
                'optimization': 'Add ORDER BY with specific column'
            }
        }
    
    def start_optimization_service(self):
        """Start database optimization service"""
        try:
            if self.is_running:
                logger.warning("Database optimization service is already running")
                return
            
            self.is_running = True
            logger.info("Starting database optimization service")
            
            # Start optimization loop
            self.optimization_task = asyncio.create_task(self._optimization_loop())
            
            return {
                "status": "success",
                "message": "Database optimization service started",
                "started_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error starting database optimization: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_optimization_service(self):
        """Stop database optimization service"""
        try:
            self.is_running = False
            
            if self.optimization_task:
                self.optimization_task.cancel()
                self.optimization_task = None
            
            logger.info("Database optimization service stopped")
            
            return {
                "status": "success",
                "message": "Database optimization service stopped",
                "stoped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping database optimization: {e}")
            return {
                "status": "error",
                'message': str(e)
            }
    
    async def _optimization_loop(self):
        """Main optimization loop"""
        while self.is_running:
            try:
                # Analyze query performance
                await self._analyze_query_performance()
                
                # Check for optimization opportunities
                await self._check_optimization_opportunities()
                
                # Update statistics
                await self._update_query_statistics()
                
                # Generate optimization recommendations
                await self._generate_optimization_recommendations()
                
                # Wait for next check (10 minutes)
                await asyncio.sleep(600)
        
        except Exception as e:
            logger.error(f"Error in optimization loop: {e}")
            await asyncio.sleep(600)
    
    async def _analyze_query_performance(self):
        """Analyze query performance"""
        try:
            # Get recent slow queries from database
            db = next(get_db())
            
            # Get slow query log entries
            slow_queries = db.query(models.QueryLog).filter(
                models.QueryLog.execution_time > self.optimization_settings['slow_query_threshold']
            ).order_by(models.QueryLog.execution_time.desc()).limit(50).all()
            
            # Analyze query patterns
            for query_log in slow_queries:
                pattern = self._analyze_query_pattern(query_log.query)
                risk_level = self._assess_query_risk(query_log.query, query_log.execution_time)
                
                self.slow_queries.append({
                    'query': query_log.query,
                    'execution_time': query_log.execution_time,
                    'risk_level': risk_level,
                    'frequency': query_log.frequency,
                    'table': query_log.table,
                    'timestamp': query_log.timestamp
                })
            
            # Identify common slow query patterns
            await self._identify_slow_query_patterns()
            
            logger.info(f"Analyzed {len(slow_queries)} slow queries")
        
        except Exception as e:
            logger.error(f"Error analyzing query performance: {e}")
    
    def _analyze_query_pattern(self, query: str) -> Dict:
        """Analyze individual query pattern"""
        try:
            pattern_analysis = {
                'query': query,
                'complexity': self._calculate_query_complexity(query),
                'table_scans': self._detect_table_scans(query),
                'joins': self._detect_joins(query),
                'subqueries': self._detect_subqueries(query),
                'aggregations': self._detect_aggregations(query),
                'where_clauses': self._detect_where_clauses(query),
                'order_by': self._detect_order_by(query),
                'functions': self._detect_functions(query)
            }
            
            return pattern_analysis
        
        except Exception as e:
            logger.error(f"Error analyzing query pattern: {e}")
            return {'query': query, 'complexity': 'low', 'error': str(e)}
    
    def _calculate_query_complexity(self, query: str) -> str:
        """Calculate query complexity score"""
        try:
            complexity_score = 0
            
            # Base complexity
            complexity_score += len(query.split()) * 0.1
            
            # Add complexity for different operations
            if 'SELECT' in query.upper():
                complexity_score += 1
            if 'JOIN' in query.upper():
                complexity_score += 2
            if 'GROUP BY' in query.upper():
                complexity_score += 1
            if 'ORDER BY' in query.upper():
                complexity_score += 0.5
            if 'HAVING' in query.upper():
                complexity_score += 2
            if 'UNION' in query.upper():
                    complexity_score += 2
            if 'SUBQUERY' in query.upper():
                    complexity_score += 2
            if 'CASE' in query.upper():
                    complexity_score += 1
            
            # Add complexity for functions
            if 'COUNT(' in query.upper():
                complexity_score += 0.5
            if 'SUM(' in query.upper():
                complexity_score += 0.5
            if 'AVG(' in query.upper():
                complexity_score += 1
            
            # Add complexity for string operations
            if 'LIKE' in query.upper():
                complexity_score += 0.5
            if 'IN (' in query.upper():
                    complexity_score += 1
            
            # Add complexity for numeric operations
            if any(op in query.upper() for op in ['+', '-', '*', '/', '%']):
                complexity_score += 0.2
            
            # Cap complexity score
            complexity_score = min(complexity_score, 10)
            
            if complexity_score <= 2:
                return 'low'
            elif complexity_score <= 5:
                return 'medium'
            elif complexity_score <= 8:
                return 'high'
            else:
                return 'very_high'
        
        except Exception as e:
            logger.error(f"Error calculating query complexity: {e}")
            return 'low'
    
    def _detect_table_scans(self, query: str) -> List[str]:
        """Detect table scans in query"""
        try:
            table_scans = []
            
            # Look for SELECT * patterns
            if 'SELECT * FROM' in query.upper():
                table_scans.append('full_table_scan')
            
            # Look for missing WHERE clauses
            if 'WHERE' not in query.upper():
                table_scans.append('missing_where_clause')
            
            # Look for ORDER BY without LIMIT
            if 'ORDER BY' in query.upper() and 'LIMIT' not in query.upper():
                table_scans.append('no_limit_clause')
            
            return table_scans
        
        except Exception as e:
            logger.error(f"Error detecting table scans: {e}")
            return []
    
    def _detect_joins(self, query: str) -> List[str]:
        """Detect JOIN operations in query"""
        try:
            joins = []
            
            # Count JOIN occurrences
            join_count = query.upper().count('JOIN')
            
            # Check for nested joins
            if 'JOIN' in query.upper():
                if join_count > 2:
                    joins.append('nested_joins')
                if 'JOIN' in query.upper() and 'JOIN' in query.upper():
                    joins.append('self-joins')
            
            # Check for CROSS JOINs
            if 'CROSS JOIN' in query.upper():
                joins.append('cross_joins')
            
            return joins
        
        except Exception as e:
            logger.error(f"Error detecting joins: {e}")
            return []
    
    def _detect_subqueries(self, query: str) -> List[str]:
        """Detect subqueries in query"""
        try:
            subqueries = []
            
            # Count subquery occurrences
            subquery_count = query.count('(SELECT')
            subquery_count += query.count('(SELECT')
            
            # Check for correlated subqueries
            if 'EXISTS' in query.upper():
                subqueries.append('correlated_subqueries')
            
            # Check for IN clauses with many values
            if 'IN (' in query.upper() and query.count('(') > 3:
                subqueries.append('large_in_list')
            
            return subqueries
        
        except Exception as e:
            logger.error(f"Error detecting subqueries: {e}")
            return []
    
    def _detect_aggregations(self, query: str) -> List[str]:
        """Detect aggregations in query"""
        try:
            aggregations = []
            
            # Count aggregation functions
            agg_count = query.upper().count('SUM(')
            agg_count += query.upper().count('AVG(')
            agg_count += query.upper().count('COUNT(')
            agg_count += query.upper().count('MIN(')
            agg_count += query.upper().count('MAX(')
            
            # Check for multiple aggregations
            if agg_count > 3:
                aggregations.append('multiple_aggregations')
            
            return aggregations
        
        except Exception as e:
            logger.error(f"Error detecting aggregations: {e}")
            return []
    
    def _detect_where_clauses(self, query: str) -> List[str]:
        """Detect WHERE clause complexity"""
        try:
            where_clauses = []
            
            # Count WHERE conditions
            where_count = query.upper().count('WHERE')
            
            # Check for complex conditions
            if where_count > 5:
                where_clauses.append('complex_where')
            
            # Check for OR conditions
            or_count = query.upper().count('OR')
            if or_count > 3:
                where_clauses.append('many_or_conditions')
            
            # Check for LIKE patterns
            like_count = query.upper().count('LIKE')
            if like_count > 2:
                where_clauses.append('many_like_patterns')
            
            # Check for IN clauses with many values
            in_count = query.upper().count('IN (') + query.count(')') > 5:
                where_clauses.append('large_in_list')
            
            return where_clauses
        
        except Exception as e:
            logger.error(f"Error detecting WHERE clauses: {e}")
            return []
    
    def _detect_order_by(self, query: str) -> List[str]:
        """Detect ORDER BY clauses"""
        try:
            order_bys = []
            
            # Check for ORDER BY with expressions
            if 'ORDER BY' in query.upper():
                if 'ORDER BY' in query.upper() and 'RANDOM()' not in query.upper():
                    order_bys.append('expression_in_order_by')
            
            # Check for multiple ORDER BY columns
            order_by_count = query.upper().count(',')
                if order_by_count > 3:
                    order_bys.append('multiple_order_by')
            
            return order_bys
        
        except Exception as e:
            logger.error(f"Error detecting ORDER BY clauses: {e}")
            return []
    
    def _detect_functions(self, query: str) -> List[str]:
        """Detect function usage in query"""
        try:
            functions = []
            
            # Count function calls
            func_count = query.upper().count('(')
            
            # Check for aggregate functions
            agg_functions = ['COUNT(', 'SUM(', 'AVG(', 'MIN(', 'MAX(']
            for func in agg_functions:
                if func in query.upper():
                    functions.append(func)
            
            # Check for string functions
            str_functions = ['UPPER(', 'LOWER(', 'SUBSTR(', 'CONCAT(']
            for func in str_functions:
                if func in query.upper():
                    functions.append(func)
            
            return functions
        
        except Exception as e:
            logger.error(f"Error detecting functions: {e}")
            return []
    
    def _assess_query_risk(self, query: str, execution_time: float, risk_level: str) -> str:
        """Assess query risk level"""
        try:
            base_risk = 'low'
            
            # Adjust risk based on complexity
            if risk_level == 'very_high':
                base_risk = 'critical'
            elif risk_level == 'high':
                base_risk = 'high'
            elif risk_level == 'medium':
                base_risk = 'medium'
            
            # Adjust risk based on execution time
            if execution_time > 5.0:
                base_risk = 'high'
            elif execution_time > 2.0:
                base_risk = 'medium'
            
            # Adjust risk based on table scans
            pattern_analysis = self._analyze_query_pattern(query)
            if 'table_scans' in pattern_analysis:
                base_risk = 'high'
            
            # Adjust risk based on joins
            joins = pattern_analysis.get('joins', [])
            if len(joins) > 1:
                base_risk = 'high'
            if 'cross_joins' in joins:
                    base_risk = 'critical'
            
            # Adjust risk based on subqueries
            subqueries = pattern_analysis.get('subqueries', [])
            if len(subqueries) > 2:
                base_risk = 'high'
            
            return base_risk
        
        except Exception as e:
            logger.error(f"Error assessing query risk: {e}")
            return 'medium'
    
    async def _identify_slow_query_patterns(self):
        """Identify common slow query patterns"""
        try:
            pattern_counts = {}
            
            for query_log in self.slow_queries:
                pattern = query_log['query']
                pattern_hash = hashlib.md5(query)
                
                if pattern_hash not in pattern_counts:
                    pattern_counts[pattern_hash] = {
                        'count': 1,
                        'total_time': query_log['execution_time'],
                        'tables': query_log['table'],
                        'frequency': query_log.get('frequency', 1)
                    }
                else:
                    pattern_counts[pattern_hash]['count'] += 1
                    pattern_counts[pattern_hash]['total_time'] += query_log['execution_time']
            
            # Sort patterns by frequency and total time
            sorted_patterns = sorted(
                pattern_counts.items(),
                key=lambda x: (
                    pattern_counts[x][1]['total_time'] / pattern_counts[x][1]['count'],
                    reverse=True
                )
            )
            
            # Generate recommendations
            for pattern_hash, data in sorted_patterns[:10]: 10]:
                pattern = data['pattern']
                count = data['count']
                avg_time = data['total_time'] / count if count > 0 else 0
                tables = data['tables']
                
                recommendations = []
                
                if avg_time > self.optimization_settings['slow_query_threshold']:
                    recommendations.append(f"Optimize query: {pattern}")
                
                if count > 10:
                    recommendations.append("Consider pagination for query: {pattern}")
                
                if tables:
                    recommendations.append("Add indexes for tables: {', ', '.join(tables)}")
                
                if 'table_scans' in self._analyze_query_pattern(pattern):
                    recommendations.append("Add WHERE clause for query: {pattern}")
                
                if 'missing_where_clause' in self._analyze_query_pattern(pattern):
                    recommendations.append("Add WHERE clause to query: {pattern}")
                
                if 'no_limit_clause' in self._analyze_query_pattern(pattern):
                    recommendations.append("Add LIMIT clause to query: {pattern}")
            
            self.optimization_suggestions.append({
                'pattern': pattern,
                'count': count,
                'avg_time': avg_time,
                'tables': tables,
                'recommendations': recommendations
            })
            
            logger.info(f"Identified {len(sorted_patterns)} slow query patterns")
        
        except Exception as e:
            logger.error(f"Error identifying slow query patterns: {e}")
    
    async def _check_optimization_opportunities(self):
        """Check for optimization opportunities"""
        try:
            opportunities = []
            
            # Check for missing indexes
            missing_indexes = await self._check_missing_indexes()
            if missing_indexes:
                opportunities.append({
                    'type': 'missing_indexes',
                    'description': 'Tables without indexes',
                    'tables': missing_indexes,
                    'priority': 'high',
                    'estimated_impact': 'high'
                })
            
            # Check for unoptimized queries
            unoptimized_queries = await self._check_unoptimized_queries()
            if unoptimized_queries:
                opportunities.append({
                    'type': 'unoptimized_queries',
                    'description': 'Queries without proper optimization',
                    'queries': unoptimized_queries,
                    'priority': 'medium',
                    'estimated_impact': 'medium'
                })
            
            # Check for connection pool issues
            pool_issues = await self._check_connection_pool_issues()
            if pool_issues:
                opportunities.append({
                    'type': 'connection_pool_issues',
                    'description': 'Database connection pool issues',
                    'issues': pool_issues,
                    'priority': 'high',
                    'estimated_impact': 'high'
                })
            
            # Check for statistics update needs
            stats_needs = await self._check_statistics_update_needs()
            if stats_needs:
                opportunities.append({
                    'type': 'statistics_update_needs',
                    'description': 'Database statistics not updated',
                    'priority': 'medium',
                    'estimated_impact': 'medium'
                })
            
            logger.info(f"Found {len(opportunities)} optimization opportunities")
        
        except Exception as e:
            logger.error(f"Error checking optimization opportunities: {e}")
    
    async def _check_missing_indexes(self) -> List[Dict]:
        """Check for missing database indexes"""
        try:
            db = next(get_db())
            
            # Get all tables
            tables = db.execute(text("SHOW TABLES")).fetchall()
            
            missing_indexes = []
            
            for table_info in tables:
                table_name = table_info[0]
                
                # Get indexes for table
                indexes = db.execute(f"SHOW INDEX FROM {table_name}").fetchall()
                
                # Check for primary key index
                primary_key = self._get_primary_key(table_name)
                if not primary_key:
                    missing_indexes.append({
                        'table': table_name,
                        'missing_index': 'primary_key',
                        'column': 'Unknown',
                        'priority': 'high'
                    })
                
                # Check for foreign key indexes
                foreign_keys = self._get_foreign_keys(table_name)
                for fk in foreign_keys:
                    if not fk.get('index'):
                        missing_indexes.append({
                            'table': table_name,
                            'missing_index': f"Foreign key: {fk['column']} -> {fk['references_table']}.{fk['references_column']}",
                            'priority': 'medium'
                        })
                
                # Check for covering indexes
                covering_indexes = self._get_covering_indexes(table_name)
                for col in ['created_at', 'updated_at', 'status']:
                    if not self._has_index(table_name, col):
                        missing_indexes.append({
                            'table': table_name,
                            'missing_index': f"Column {col} needs index",
                            'priority': 'medium'
                        })
            
                # Check for frequently queried columns
                frequently_queried = self._get_frequently_queried_columns(table_name)
                for col in frequently_queried:
                    if not self._has_index(table_name, col):
                        missing_indexes.append({
                            'table': table_name,
                            'missing_index': f"Column {col} needs index (frequently queried)",
                            'priority': 'medium'
                        })
            
            return missing_indexes
        
        except Exception as e:
            logger.error(f"Error checking missing indexes: {e}")
            return []
    
    def _get_primary_key(self, table_name: str) -> Optional[str]:
        """Get primary key for table"""
        try:
            db = next(get_db())
            
            # Get table structure
            table_structure = db.execute(f"DESCRIBE {table_name}").fetchall()
            
            # Find primary key
            for column in table_structure:
                if column[3].upper() == 'PRI':
                    return column[0]
            
            return None
        
        except Exception as e:
            logger.error(f"Error getting primary key for {table_name}: {e}")
            return None
    
    def _get_foreign_keys(self, table_name: str) -> List[Dict]:
        """Get foreign keys for table"""
        try:
            db = next(get_db())
            
            # Get table structure
            table_structure = db.execute(f"SHOW CREATE TABLE {table_name}").fetchall()
            
            foreign_keys = []
            
            for column in table_structure:
                if column[6] and 'REFERENCES' in column[6]:
                    ref_table, ref_column = column[6].split('(')[1].strip().split(')')[1].strip()
                    foreign_keys.append({
                        'column': column[0],
                        'references_table': ref_table,
                        'references_column': ref_column
                    })
            
            return foreign_keys
        
        except Exception as e:
            logger.error(f"Error getting foreign keys for {table_name}: {e}")
            return []
    
    def _get_covering_indexes(self, table_name: str) -> List[Dict]:
        """Get covering indexes for table"""
        try:
            db = next(get_db())
            
            # Get table structure
            table_structure = db.execute(f"SHOW CREATE TABLE {table_name}").fetchall()
            
            covering_indexes = []
            
            for column in table_structure:
                if column[6] and 'INDEX' in column[6]:
                    index_columns = column[6].split('(')[1].strip().split(',')].map(str.strip)
                    
                    for col in index_columns:
                        if col in ['id', 'created_at', 'updated_at', 'status']:
                            covering_indexes.append({
                                'table': table_name,
                                'column': col,
                                'index_type': 'covering',
                                'priority': 'medium'
                            })
            
            return covering_indexes
        
        except Exception as e:
            logger.error(f"Error getting covering indexes for {table_name}: {e}")
            return []
    
    def _has_index(self, table_name: str, column: str) -> bool:
        """Check if column has index"""
        try:
            db = next(get_db())
            
            # Get table structure
            table_structure = db.execute(f"SHOW INDEX FROM {table_name}").fetchall()
            
            for column in table_structure:
                if column[6] and 'INDEX' in column[6]:
                    index_columns = column[6].split('(')[1].strip().split(',').map(str.strip)
                    if column in index_columns:
                        return True
            
            return False
        
        except Exception as e:
            logger.error(f"Error checking index for {table_name}.{column}: {e}")
            return False
    
    def _get_frequently_queried_columns(self, table_name: str) -> List[str]:
        """Get frequently queried columns for table"""
        try:
            # This would analyze query logs
            # For now, return common frequently queried columns
            return ['id', 'name', 'created_at', 'updated_at', 'status']
        
        except Exception as e:
            logger.error(f"Error getting frequently queried columns for {table_name}: {e}")
            return []
    
    async def _check_unoptimized_queries(self) -> List[Dict]:
        """Check for unoptimized queries"""
        try:
            unoptimized_queries = []
            
            # Get recent query logs
            db = next(get_db())
            recent_queries = db.query(models.QueryLog).filter(
                models.QueryLog.execution_time > self.optimization_settings['slow_query_threshold']
            ).order_by(models.QueryLog.execution_time.desc()).limit(20).all()
            
            for query_log in recent_queries:
                # Check for optimization opportunities
                pattern_analysis = self._analyze_query_pattern(query_log.query)
                
                # Check if query can be optimized
                if pattern_analysis.get('complexity') in ['medium', 'high', 'very_high']:
                    unoptimized_queries.append({
                        'query': query_log.query,
                        'reason': 'high complexity',
                        'optimization': 'Add proper WHERE clause or indexes',
                        'estimated_impact': 'high'
                    })
                elif pattern_analysis.get('table_scans') or pattern_analysis.get('missing_where_clause'):
                    unoptimized_queries.append({
                        'query': query_log.query,
                        'reason': 'table scan detected',
                        'optimization': 'Add WHERE clause or indexes',
                        'estimated_impact': 'high'
                    })
                elif pattern_analysis.get('joins') and len(pattern_analysis.get('joins')) > 1:
                    unoptimized_queries.append({
                        'query': query_log.query,
                        'reason': 'multiple joins detected',
                        'optimization 'Consider query restructuring',
                        'estimated_impact': 'high'
                    })
                elif pattern_analysis.get('large_in_list'):
                    unoptimized_queries.append({
                        'query': query_log.query,
                        'reason': 'large IN list detected',
                        'optimization 'Use EXISTS or LIMIT',
                        'estimated_impact': 'high'
                    })
            
            self.unoptimized_queries = unoptimized_queries
            
            return unoptimized_queries
        
        except Exception as e:
            logger.error(f"Error checking unoptimized queries: {e}")
            return []
    
    async def _check_connection_pool_issues(self) -> List[Dict]:
        """Check database connection pool issues"""
        try:
            pool_issues = []
            
            # Check pool usage
            current_usage = self.current_metrics.get('database', {}).get('pool_usage', 0)
            
            if current_usage > self.optimization_settings['connection_pool_max_size'] * 0.8:
                pool_issues.append({
                    'issue': 'high_pool_usage',
                    'description': f"Connection pool at {current_usage:.1%} of capacity",
                    'current_usage': current_usage,
                    'max_capacity': self.optimization_settings['connection_pool_max_size'],
                    'estimated_impact': 'high'
                })
            
            # Check for connection errors
            connection_errors = self.current_metrics.get('database', {}).get('connection_errors', [])
            
            if connection_errors > 5:
                pool_issues.append({
                    'issue': 'high_connection_errors',
                    'description': f"High connection error rate: {connection_errors} per hour",
                    'connection_errors': connection_errors,
                    'estimated_impact': 'high'
                })
            
            return pool_issues
        
        except Exception as e:
            logger.error(f"Error checking connection pool issues: {e}")
            return []
    
    async def _check_statistics_update_needs(self) -> List[Dict]:
        """Check if statistics need updates"""
        try:
            stats_needs = []
            
            # Check last statistics update time
            last_update = self.current_metrics.get('database', {}).get('last_statistics_update')
            
            if last_update:
                time_since_update = (datetime.utcnow() - last_update).total_seconds()
                
                if time_since_update > self.optimization_settings['statistics_update_interval']:
                    stats_needs.append({
                        'issue': 'statistics_update_needed',
                        'description': f"Statistics not updated in {time_since_update} seconds",
                        'last_update': last_update.isoformat(),
                        'estimated_impact': 'medium'
                    })
            
            return stats_needs
        
        except Exception as e:
            logger.error(f"Error checking statistics update needs: {e}")
            return []
    
    def get_optimization_status(self) -> Dict:
        """Get current optimization status"""
        try:
            return {
                'is_running': self.is_running,
                'current_metrics': self.current_metrics,
                'optimization_settings': self.optimization_settings,
                'slow_queries': len(self.slow_queries),
                'optimization_suggestions': len(self.optimization_suggestions),
                'index_recommendations': len(self.index_recommendations),
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting optimization status: {e}")
            return {
                'is_running': False,
                'current_metrics': {},
                'optimization_settings': self.optimization_settings,
                'slow_queries': 0,
                'optimization_suggestions': [],
                'index_recommendations': [],
                'last_updated': datetime.utcnow().isoformat()
            }
    
    def get_optimization_recommendations(self) -> List[str]:
        """Get optimization recommendations"""
        try:
            recommendations = []
            
            # Index recommendations
            for rec in self.index_recommendations:
                recommendations.append(f"Add index to {rec['table'] on {rec['column']} for {rec['reason']}")
            
            # Query optimization recommendations
            for rec in self.optimization_suggestions:
                recommendations.append(f"Optimize query: {rec['pattern']}")
            
            # General recommendations
            recommendations.extend([
                "Use prepared statements for complex queries",
                "Consider query result caching",
                "Implement connection pooling",
                "Use read replicas for reporting queries",
                "Optimize database configuration"
            ])
            
            return recommendations
        
        except Exception as e:
            logger.error(f"Error getting optimization recommendations: {e}")
            return ["Error generating recommendations"]
    
    async def _update_query_statistics(self):
        """Update database query statistics"""
        try:
            # Update query performance statistics
            db = next(get_db())
            
            # Get recent query logs
            recent_queries = db.query(models.QueryLog).filter(
                models.QueryLog.timestamp >= datetime.utcnow() - timedelta(hours=1)
            ).all()
            
            if recent_queries:
                # Calculate statistics
                total_queries = len(recent_queries)
                avg_execution_time = sum(q.execution_time for q in recent_queries) / total_queries if total_queries > 0 else 0)
                slow_queries = len([q for q in recent_queries if q.execution_time > self.optimization_settings['slow_query_threshold']])
                
                # Update cache stats
                cache_stats = self.cache_stats.get('database', {})
                cache_stats['total_queries'] = total_queries
                cache_stats['cached_queries'] = cache_stats.get('cached_queries', 0) + total_queries
                
                # Calculate cache hit rate
                if cache_stats['total_queries'] > 0:
                    cache_hit_rate = (cache_stats['cached_queries'] / cache_stats['total_queries']) * 100
                else:
                    cache_hit_rate = 0
                
                cache_stats['cache_hit_rate'] = cache_hit_rate
                cache_stats['cache_efficiency'] = cache_hit_rate / 100
                
                logger.info(f"Updated database query statistics: {cache_hit_rate:.1f}% cache hit rate")
            
        except Exception as e:
            logger.error(f"Error updating query statistics: {e}")
    
    def get_slow_queries(self) -> List[Dict]:
        """Get list of slow queries"""
        return self.slow_queries[-20:]  # Last 20 slow queries

# Global database optimization service instance
database_optimization_service = DatabaseOptimizationService()
