#!/usr/bin/env python3
"""
Python Automation & Observability Interview Practice Exercises
================================================================

This file contains practical coding exercises for Python automation and observability interviews.
Each exercise includes:
- Problem statement
- Solution approach
- Complete implementation
- Test cases
- Discussion points

Use these exercises to practice for your interview!
"""

import json
import time
import requests
import logging
import asyncio
import aiohttp
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
import unittest
from unittest.mock import Mock, patch
import prometheus_client
from prometheus_client import Counter, Histogram, Gauge


# ============================================================================
# EXERCISE 1: Infrastructure Health Monitoring System
# ============================================================================

@dataclass
class HealthCheck:
    name: str
    url: str
    expected_status: int = 200
    timeout: int = 5
    critical: bool = False

class HealthMonitoringSystem:
    """
    Exercise 1: Build a comprehensive health monitoring system
    
    Requirements:
    1. Monitor multiple endpoints simultaneously
    2. Track response times and success rates
    3. Generate alerts for failures
    4. Provide health status aggregation
    5. Support both sync and async operations
    """
    
    def __init__(self):
        self.checks: List[HealthCheck] = []
        self.results: Dict[str, Dict] = {}
        self.alert_threshold = 3  # Alert after 3 consecutive failures
        
        # Prometheus metrics
        self.health_check_total = Counter(
            'health_check_total', 
            'Total health checks performed',
            ['service', 'status']
        )
        self.health_check_duration = Histogram(
            'health_check_duration_seconds',
            'Health check duration',
            ['service']
        )
        self.service_health_status = Gauge(
            'service_health_status',
            'Service health status (1=healthy, 0=unhealthy)',
            ['service']
        )
    
    def add_health_check(self, check: HealthCheck):
        """Add a new health check to monitor"""
        self.checks.append(check)
        self.results[check.name] = {
            'status': 'unknown',
            'last_check': None,
            'consecutive_failures': 0,
            'response_time': 0
        }
    
    def run_health_check(self, check: HealthCheck) -> Dict[str, Any]:
        """Run a single health check"""
        start_time = time.time()
        
        try:
            response = requests.get(check.url, timeout=check.timeout)
            duration = time.time() - start_time
            
            is_healthy = response.status_code == check.expected_status
            status = 'healthy' if is_healthy else 'unhealthy'
            
            # Update metrics
            self.health_check_total.labels(
                service=check.name, 
                status=status
            ).inc()
            self.health_check_duration.labels(service=check.name).observe(duration)
            self.service_health_status.labels(service=check.name).set(1 if is_healthy else 0)
            
            # Update results
            self.results[check.name].update({
                'status': status,
                'last_check': datetime.now().isoformat(),
                'response_time': duration,
                'status_code': response.status_code,
                'error': None
            })
            
            # Handle consecutive failures
            if is_healthy:
                self.results[check.name]['consecutive_failures'] = 0
            else:
                self.results[check.name]['consecutive_failures'] += 1
                
                # Generate alert if threshold exceeded
                if (self.results[check.name]['consecutive_failures'] >= self.alert_threshold 
                    and check.critical):
                    self._generate_alert(check, f"Service {check.name} is unhealthy")
            
            return self.results[check.name]
            
        except Exception as e:
            duration = time.time() - start_time
            
            # Update metrics for error
            self.health_check_total.labels(service=check.name, status='error').inc()
            self.health_check_duration.labels(service=check.name).observe(duration)
            self.service_health_status.labels(service=check.name).set(0)
            
            # Update results
            self.results[check.name].update({
                'status': 'error',
                'last_check': datetime.now().isoformat(),
                'response_time': duration,
                'error': str(e)
            })
            self.results[check.name]['consecutive_failures'] += 1
            
            # Generate alert for critical services
            if (self.results[check.name]['consecutive_failures'] >= self.alert_threshold 
                and check.critical):
                self._generate_alert(check, f"Service {check.name} error: {str(e)}")
            
            return self.results[check.name]
    
    def run_all_checks(self) -> Dict[str, Any]:
        """Run all health checks in parallel"""
        results = {}
        
        with ThreadPoolExecutor(max_workers=10) as executor:
            future_to_check = {
                executor.submit(self.run_health_check, check): check 
                for check in self.checks
            }
            
            for future in as_completed(future_to_check):
                check = future_to_check[future]
                try:
                    result = future.result()
                    results[check.name] = result
                except Exception as e:
                    results[check.name] = {
                        'status': 'error',
                        'error': str(e),
                        'last_check': datetime.now().isoformat()
                    }
        
        # Calculate overall health
        healthy_count = sum(1 for r in results.values() if r['status'] == 'healthy')
        total_count = len(results)
        
        overall_status = 'healthy' if healthy_count == total_count else 'degraded' if healthy_count > 0 else 'unhealthy'
        
        return {
            'overall_status': overall_status,
            'healthy_services': healthy_count,
            'total_services': total_count,
            'timestamp': datetime.now().isoformat(),
            'services': results
        }
    
    async def run_health_check_async(self, check: HealthCheck) -> Dict[str, Any]:
        """Run health check asynchronously"""
        start_time = time.time()
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(check.url, timeout=check.timeout) as response:
                    duration = time.time() - start_time
                    
                    is_healthy = response.status == check.expected_status
                    status = 'healthy' if is_healthy else 'unhealthy'
                    
                    # Update results (simplified for async)
                    result = {
                        'status': status,
                        'last_check': datetime.now().isoformat(),
                        'response_time': duration,
                        'status_code': response.status,
                        'error': None
                    }
                    
                    return result
                    
        except Exception as e:
            duration = time.time() - start_time
            return {
                'status': 'error',
                'last_check': datetime.now().isoformat(),
                'response_time': duration,
                'error': str(e)
            }
    
    async def run_all_checks_async(self) -> Dict[str, Any]:
        """Run all health checks asynchronously"""
        tasks = [self.run_health_check_async(check) for check in self.checks]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        service_results = {}
        for i, result in enumerate(results):
            check = self.checks[i]
            if isinstance(result, Exception):
                service_results[check.name] = {
                    'status': 'error',
                    'error': str(result),
                    'last_check': datetime.now().isoformat()
                }
            else:
                service_results[check.name] = result
        
        # Calculate overall health
        healthy_count = sum(1 for r in service_results.values() if r['status'] == 'healthy')
        total_count = len(service_results)
        
        overall_status = 'healthy' if healthy_count == total_count else 'degraded' if healthy_count > 0 else 'unhealthy'
        
        return {
            'overall_status': overall_status,
            'healthy_services': healthy_count,
            'total_services': total_count,
            'timestamp': datetime.now().isoformat(),
            'services': service_results
        }
    
    def _generate_alert(self, check: HealthCheck, message: str):
        """Generate alert for service failure"""
        alert = {
            'timestamp': datetime.now().isoformat(),
            'service': check.name,
            'message': message,
            'severity': 'critical' if check.critical else 'warning',
            'url': check.url
        }
        
        # In a real implementation, this would send to alerting system
        print(f"🚨 ALERT: {json.dumps(alert, indent=2)}")
        
        # Log the alert
        logging.error(f"Health check alert: {message}")
    
    def get_health_summary(self) -> Dict[str, Any]:
        """Get summary of all health checks"""
        return {
            'total_checks': len(self.checks),
            'results': self.results,
            'overall_status': self._calculate_overall_status()
        }
    
    def _calculate_overall_status(self) -> str:
        """Calculate overall system health status"""
        if not self.results:
            return 'unknown'
        
        healthy_count = sum(1 for r in self.results.values() if r['status'] == 'healthy')
        total_count = len(self.results)
        
        if healthy_count == total_count:
            return 'healthy'
        elif healthy_count > 0:
            return 'degraded'
        else:
            return 'unhealthy'


# ============================================================================
# EXERCISE 2: Configuration Management System
# ============================================================================

class ConfigurationManager:
    """
    Exercise 2: Build a configuration management system
    
    Requirements:
    1. Load configurations from multiple sources (files, environment, APIs)
    2. Support different configuration formats (JSON, YAML, ENV)
    3. Provide configuration validation
    4. Support configuration hot-reloading
    5. Handle configuration inheritance and overrides
    """
    
    def __init__(self):
        self.configs: Dict[str, Any] = {}
        self.sources: List[str] = []
        self.validators: Dict[str, callable] = {}
        self.watchers: List[callable] = []
    
    def load_from_file(self, file_path: str, format_type: str = 'auto') -> bool:
        """Load configuration from file"""
        try:
            if format_type == 'auto':
                format_type = file_path.split('.')[-1].lower()
            
            with open(file_path, 'r') as f:
                if format_type == 'json':
                    config = json.load(f)
                elif format_type == 'yaml':
                    import yaml
                    config = yaml.safe_load(f)
                else:
                    raise ValueError(f"Unsupported format: {format_type}")
            
            self.configs.update(config)
            self.sources.append(f"file:{file_path}")
            return True
            
        except Exception as e:
            logging.error(f"Failed to load config from {file_path}: {e}")
            return False
    
    def load_from_env(self, prefix: str = 'APP_') -> bool:
        """Load configuration from environment variables"""
        try:
            import os
            env_config = {}
            
            for key, value in os.environ.items():
                if key.startswith(prefix):
                    config_key = key[len(prefix):].lower()
                    # Try to parse as JSON, fallback to string
                    try:
                        env_config[config_key] = json.loads(value)
                    except (json.JSONDecodeError, ValueError):
                        env_config[config_key] = value
            
            self.configs.update(env_config)
            self.sources.append(f"env:{prefix}")
            return True
            
        except Exception as e:
            logging.error(f"Failed to load config from environment: {e}")
            return False
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value with dot notation support"""
        keys = key.split('.')
        value = self.configs
        
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default
    
    def set(self, key: str, value: Any) -> bool:
        """Set configuration value with dot notation support"""
        try:
            keys = key.split('.')
            config = self.configs
            
            # Navigate to the parent of the target key
            for k in keys[:-1]:
                if k not in config:
                    config[k] = {}
                config = config[k]
            
            # Set the final value
            config[keys[-1]] = value
            return True
            
        except Exception as e:
            logging.error(f"Failed to set config {key}: {e}")
            return False
    
    def validate_config(self, schema: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate configuration against schema"""
        errors = []
        
        def validate_recursive(config: Any, schema: Any, path: str = '') -> None:
            if isinstance(schema, dict):
                if not isinstance(config, dict):
                    errors.append(f"{path}: Expected dict, got {type(config).__name__}")
                    return
                
                for key, expected_type in schema.items():
                    if key not in config:
                        errors.append(f"{path}.{key}: Required field missing")
                    else:
                        validate_recursive(config[key], expected_type, f"{path}.{key}")
            elif isinstance(schema, type):
                if not isinstance(config, schema):
                    errors.append(f"{path}: Expected {schema.__name__}, got {type(config).__name__}")
        
        validate_recursive(self.configs, schema)
        return len(errors) == 0, errors
    
    def add_validator(self, key: str, validator: callable):
        """Add custom validator for configuration key"""
        self.validators[key] = validator
    
    def validate_with_validators(self) -> Tuple[bool, List[str]]:
        """Validate configuration using custom validators"""
        errors = []
        
        for key, validator in self.validators.items():
            try:
                value = self.get(key)
                if not validator(value):
                    errors.append(f"{key}: Validation failed")
            except Exception as e:
                errors.append(f"{key}: Validation error - {str(e)}")
        
        return len(errors) == 0, errors
    
    def add_watcher(self, callback: callable):
        """Add configuration change watcher"""
        self.watchers.append(callback)
    
    def notify_watchers(self, key: str, old_value: Any, new_value: Any):
        """Notify watchers of configuration changes"""
        for watcher in self.watchers:
            try:
                watcher(key, old_value, new_value)
            except Exception as e:
                logging.error(f"Watcher error: {e}")
    
    def reload_config(self) -> bool:
        """Reload configuration from all sources"""
        old_configs = self.configs.copy()
        self.configs.clear()
        self.sources.clear()
        
        # Reload from all sources (simplified - in real implementation, 
        # you'd track source types and reload accordingly)
        success = True
        for source in self.sources:
            if source.startswith('file:'):
                file_path = source[5:]  # Remove 'file:' prefix
                success &= self.load_from_file(file_path)
            elif source.startswith('env:'):
                prefix = source[4:]  # Remove 'env:' prefix
                success &= self.load_from_env(prefix)
        
        # Notify watchers of changes
        if success:
            self._notify_config_changes(old_configs, self.configs)
        
        return success
    
    def _notify_config_changes(self, old_config: Dict, new_config: Dict):
        """Notify watchers of configuration changes"""
        def compare_dicts(old: Dict, new: Dict, path: str = ''):
            for key in set(old.keys()) | set(new.keys()):
                current_path = f"{path}.{key}" if path else key
                
                if key not in old:
                    self.notify_watchers(current_path, None, new[key])
                elif key not in new:
                    self.notify_watchers(current_path, old[key], None)
                elif old[key] != new[key]:
                    if isinstance(old[key], dict) and isinstance(new[key], dict):
                        compare_dicts(old[key], new[key], current_path)
                    else:
                        self.notify_watchers(current_path, old[key], new[key])
        
        compare_dicts(old_config, new_config)


# ============================================================================
# EXERCISE 3: Log Aggregation and Analysis System
# ============================================================================

@dataclass
class LogEntry:
    timestamp: datetime
    level: str
    service: str
    message: str
    metadata: Dict[str, Any] = None

class LogAggregator:
    """
    Exercise 3: Build a log aggregation and analysis system
    
    Requirements:
    1. Collect logs from multiple sources
    2. Parse and structure log entries
    3. Filter and search logs
    4. Generate log analytics and metrics
    5. Support real-time log streaming
    """
    
    def __init__(self):
        self.logs: List[LogEntry] = []
        self.filters: Dict[str, callable] = {}
        self.analyzers: List[callable] = []
        
        # Metrics
        self.log_count_total = Counter(
            'log_entries_total',
            'Total log entries processed',
            ['service', 'level']
        )
        self.log_processing_duration = Histogram(
            'log_processing_duration_seconds',
            'Time to process log entry'
        )
    
    def add_log(self, log_entry: LogEntry):
        """Add a log entry to the aggregator"""
        start_time = time.time()
        
        # Update metrics
        self.log_count_total.labels(
            service=log_entry.service,
            level=log_entry.level
        ).inc()
        
        # Apply filters
        if self._should_process_log(log_entry):
            self.logs.append(log_entry)
            
            # Run analyzers
            for analyzer in self.analyzers:
                try:
                    analyzer(log_entry)
                except Exception as e:
                    logging.error(f"Analyzer error: {e}")
        
        # Record processing time
        duration = time.time() - start_time
        self.log_processing_duration.observe(duration)
    
    def add_log_from_string(self, log_string: str, service: str = 'unknown'):
        """Parse and add log from string format"""
        try:
            # Simple log parsing (in real implementation, use proper log parsing)
            parts = log_string.split(' ', 3)
            if len(parts) >= 4:
                timestamp_str = f"{parts[0]} {parts[1]}"
                level = parts[2].strip('[]')
                message = parts[3]
                
                timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
                
                log_entry = LogEntry(
                    timestamp=timestamp,
                    level=level,
                    service=service,
                    message=message
                )
                
                self.add_log(log_entry)
                
        except Exception as e:
            logging.error(f"Failed to parse log string: {e}")
    
    def _should_process_log(self, log_entry: LogEntry) -> bool:
        """Check if log should be processed based on filters"""
        for filter_name, filter_func in self.filters.items():
            try:
                if not filter_func(log_entry):
                    return False
            except Exception as e:
                logging.error(f"Filter {filter_name} error: {e}")
        return True
    
    def add_filter(self, name: str, filter_func: callable):
        """Add log filter"""
        self.filters[name] = filter_func
    
    def add_analyzer(self, analyzer_func: callable):
        """Add log analyzer"""
        self.analyzers.append(analyzer_func)
    
    def search_logs(self, query: str, start_time: datetime = None, 
                   end_time: datetime = None, service: str = None, 
                   level: str = None) -> List[LogEntry]:
        """Search logs with various filters"""
        results = self.logs
        
        # Time filter
        if start_time:
            results = [log for log in results if log.timestamp >= start_time]
        if end_time:
            results = [log for log in results if log.timestamp <= end_time]
        
        # Service filter
        if service:
            results = [log for log in results if log.service == service]
        
        # Level filter
        if level:
            results = [log for log in results if log.level == level]
        
        # Text search
        if query:
            results = [log for log in results if query.lower() in log.message.lower()]
        
        return results
    
    def get_log_statistics(self) -> Dict[str, Any]:
        """Get log statistics and analytics"""
        if not self.logs:
            return {'total_logs': 0}
        
        # Count by level
        level_counts = {}
        service_counts = {}
        
        for log in self.logs:
            level_counts[log.level] = level_counts.get(log.level, 0) + 1
            service_counts[log.service] = service_counts.get(log.service, 0) + 1
        
        # Time range
        timestamps = [log.timestamp for log in self.logs]
        time_range = {
            'earliest': min(timestamps).isoformat(),
            'latest': max(timestamps).isoformat()
        }
        
        return {
            'total_logs': len(self.logs),
            'level_distribution': level_counts,
            'service_distribution': service_counts,
            'time_range': time_range,
            'logs_per_minute': len(self.logs) / max(1, (max(timestamps) - min(timestamps)).total_seconds() / 60)
        }
    
    def export_logs(self, format_type: str = 'json', 
                   start_time: datetime = None, end_time: datetime = None) -> str:
        """Export logs in specified format"""
        logs_to_export = self.search_logs('', start_time, end_time)
        
        if format_type == 'json':
            return json.dumps([
                {
                    'timestamp': log.timestamp.isoformat(),
                    'level': log.level,
                    'service': log.service,
                    'message': log.message,
                    'metadata': log.metadata
                }
                for log in logs_to_export
            ], indent=2)
        
        elif format_type == 'csv':
            import csv
            import io
            
            output = io.StringIO()
            writer = csv.writer(output)
            writer.writerow(['timestamp', 'level', 'service', 'message'])
            
            for log in logs_to_export:
                writer.writerow([
                    log.timestamp.isoformat(),
                    log.level,
                    log.service,
                    log.message
                ])
            
            return output.getvalue()
        
        else:
            raise ValueError(f"Unsupported export format: {format_type}")


# ============================================================================
# EXERCISE 4: Deployment Automation System
# ============================================================================

class DeploymentAutomation:
    """
    Exercise 4: Build a deployment automation system
    
    Requirements:
    1. Support multiple deployment strategies (rolling, blue-green, canary)
    2. Handle deployment validation and rollback
    3. Integrate with monitoring systems
    4. Support deployment pipelines
    5. Handle deployment notifications
    """
    
    def __init__(self):
        self.deployments: Dict[str, Dict] = {}
        self.strategies = {
            'rolling': self._rolling_deployment,
            'blue_green': self._blue_green_deployment,
            'canary': self._canary_deployment
        }
        self.validators: List[callable] = []
        self.notifiers: List[callable] = []
    
    def deploy(self, service_name: str, version: str, strategy: str = 'rolling',
              config: Dict[str, Any] = None) -> bool:
        """Deploy service with specified strategy"""
        if strategy not in self.strategies:
            raise ValueError(f"Unsupported deployment strategy: {strategy}")
        
        deployment_id = f"{service_name}-{version}-{int(time.time())}"
        
        deployment_info = {
            'id': deployment_id,
            'service_name': service_name,
            'version': version,
            'strategy': strategy,
            'config': config or {},
            'status': 'starting',
            'start_time': datetime.now(),
            'end_time': None,
            'success': False
        }
        
        self.deployments[deployment_id] = deployment_info
        
        try:
            # Run pre-deployment validations
            if not self._run_validations(service_name, version, config):
                deployment_info['status'] = 'failed'
                deployment_info['end_time'] = datetime.now()
                self._notify_deployment(deployment_info, 'failed')
                return False
            
            # Execute deployment strategy
            success = self.strategies[strategy](deployment_info)
            
            if success:
                deployment_info['status'] = 'completed'
                deployment_info['success'] = True
            else:
                deployment_info['status'] = 'failed'
            
            deployment_info['end_time'] = datetime.now()
            self._notify_deployment(deployment_info, deployment_info['status'])
            
            return success
            
        except Exception as e:
            deployment_info['status'] = 'failed'
            deployment_info['end_time'] = datetime.now()
            deployment_info['error'] = str(e)
            self._notify_deployment(deployment_info, 'failed')
            logging.error(f"Deployment failed: {e}")
            return False
    
    def _rolling_deployment(self, deployment_info: Dict) -> bool:
        """Rolling deployment strategy"""
        service_name = deployment_info['service_name']
        version = deployment_info['version']
        
        # Simulate rolling deployment steps
        steps = [
            f"Building image for {service_name}:{version}",
            f"Pushing image to registry",
            f"Updating deployment {service_name}",
            f"Waiting for rollout to complete",
            f"Running health checks for {service_name}"
        ]
        
        for step in steps:
            logging.info(f"Rolling deployment step: {step}")
            time.sleep(1)  # Simulate work
            
            # Simulate occasional failures
            if "health checks" in step and time.time() % 10 < 2:
                logging.error(f"Health check failed for {service_name}")
                return False
        
        logging.info(f"Rolling deployment completed for {service_name}")
        return True
    
    def _blue_green_deployment(self, deployment_info: Dict) -> bool:
        """Blue-green deployment strategy"""
        service_name = deployment_info['service_name']
        version = deployment_info['version']
        
        # Simulate blue-green deployment steps
        steps = [
            f"Deploying green environment for {service_name}:{version}",
            f"Running smoke tests on green environment",
            f"Switching traffic to green environment",
            f"Monitoring green environment",
            f"Cleaning up blue environment"
        ]
        
        for step in steps:
            logging.info(f"Blue-green deployment step: {step}")
            time.sleep(1)  # Simulate work
            
            # Simulate occasional failures
            if "smoke tests" in step and time.time() % 8 < 2:
                logging.error(f"Smoke tests failed for {service_name}")
                return False
        
        logging.info(f"Blue-green deployment completed for {service_name}")
        return True
    
    def _canary_deployment(self, deployment_info: Dict) -> bool:
        """Canary deployment strategy"""
        service_name = deployment_info['service_name']
        version = deployment_info['version']
        config = deployment_info.get('config', {})
        canary_percentage = config.get('canary_percentage', 10)
        
        # Simulate canary deployment steps
        steps = [
            f"Deploying canary version {version} for {service_name}",
            f"Routing {canary_percentage}% traffic to canary",
            f"Monitoring canary performance",
            f"Gradually increasing canary traffic",
            f"Promoting canary to full deployment"
        ]
        
        for step in steps:
            logging.info(f"Canary deployment step: {step}")
            time.sleep(1)  # Simulate work
            
            # Simulate occasional failures
            if "monitoring" in step and time.time() % 6 < 2:
                logging.error(f"Canary monitoring detected issues for {service_name}")
                return False
        
        logging.info(f"Canary deployment completed for {service_name}")
        return True
    
    def _run_validations(self, service_name: str, version: str, config: Dict) -> bool:
        """Run pre-deployment validations"""
        for validator in self.validators:
            try:
                if not validator(service_name, version, config):
                    logging.error(f"Validation failed for {service_name}:{version}")
                    return False
            except Exception as e:
                logging.error(f"Validator error: {e}")
                return False
        return True
    
    def _notify_deployment(self, deployment_info: Dict, status: str):
        """Notify about deployment status"""
        for notifier in self.notifiers:
            try:
                notifier(deployment_info, status)
            except Exception as e:
                logging.error(f"Notifier error: {e}")
    
    def add_validator(self, validator: callable):
        """Add deployment validator"""
        self.validators.append(validator)
    
    def add_notifier(self, notifier: callable):
        """Add deployment notifier"""
        self.notifiers.append(notifier)
    
    def rollback(self, deployment_id: str) -> bool:
        """Rollback deployment"""
        if deployment_id not in self.deployments:
            logging.error(f"Deployment {deployment_id} not found")
            return False
        
        deployment_info = self.deployments[deployment_id]
        
        if deployment_info['status'] != 'completed':
            logging.error(f"Cannot rollback deployment {deployment_id} with status {deployment_info['status']}")
            return False
        
        try:
            logging.info(f"Rolling back deployment {deployment_id}")
            
            # Simulate rollback process
            time.sleep(2)
            
            deployment_info['status'] = 'rolled_back'
            deployment_info['rollback_time'] = datetime.now()
            
            self._notify_deployment(deployment_info, 'rolled_back')
            
            logging.info(f"Rollback completed for deployment {deployment_id}")
            return True
            
        except Exception as e:
            logging.error(f"Rollback failed: {e}")
            return False
    
    def get_deployment_status(self, deployment_id: str) -> Dict[str, Any]:
        """Get deployment status"""
        if deployment_id not in self.deployments:
            return {'error': 'Deployment not found'}
        
        return self.deployments[deployment_id]
    
    def list_deployments(self, service_name: str = None) -> List[Dict[str, Any]]:
        """List deployments, optionally filtered by service"""
        deployments = list(self.deployments.values())
        
        if service_name:
            deployments = [d for d in deployments if d['service_name'] == service_name]
        
        return sorted(deployments, key=lambda x: x['start_time'], reverse=True)


# ============================================================================
# TEST CASES
# ============================================================================

class TestHealthMonitoringSystem(unittest.TestCase):
    """Test cases for HealthMonitoringSystem"""
    
    def setUp(self):
        self.health_system = HealthMonitoringSystem()
        self.health_check = HealthCheck(
            name="test-service",
            url="https://httpbin.org/status/200",
            expected_status=200
        )
        self.health_system.add_health_check(self.health_check)
    
    def test_add_health_check(self):
        """Test adding health check"""
        self.assertEqual(len(self.health_system.checks), 1)
        self.assertEqual(self.health_system.checks[0].name, "test-service")
    
    @patch('requests.get')
    def test_run_health_check_success(self, mock_get):
        """Test successful health check"""
        mock_response = Mock()
        mock_response.status_code = 200
        mock_get.return_value = mock_response
        
        result = self.health_system.run_health_check(self.health_check)
        
        self.assertEqual(result['status'], 'healthy')
        self.assertEqual(result['status_code'], 200)
    
    @patch('requests.get')
    def test_run_health_check_failure(self, mock_get):
        """Test failed health check"""
        mock_response = Mock()
        mock_response.status_code = 500
        mock_get.return_value = mock_response
        
        result = self.health_system.run_health_check(self.health_check)
        
        self.assertEqual(result['status'], 'unhealthy')
        self.assertEqual(result['status_code'], 500)


class TestConfigurationManager(unittest.TestCase):
    """Test cases for ConfigurationManager"""
    
    def setUp(self):
        self.config_manager = ConfigurationManager()
    
    def test_set_and_get_config(self):
        """Test setting and getting configuration"""
        self.config_manager.set('database.host', 'localhost')
        self.config_manager.set('database.port', 5432)
        
        self.assertEqual(self.config_manager.get('database.host'), 'localhost')
        self.assertEqual(self.config_manager.get('database.port'), 5432)
        self.assertEqual(self.config_manager.get('database.user', 'default'), 'default')
    
    def test_config_validation(self):
        """Test configuration validation"""
        self.config_manager.set('database.host', 'localhost')
        self.config_manager.set('database.port', 5432)
        
        schema = {
            'database': {
                'host': str,
                'port': int
            }
        }
        
        is_valid, errors = self.config_manager.validate_config(schema)
        self.assertTrue(is_valid)
        self.assertEqual(len(errors), 0)


class TestLogAggregator(unittest.TestCase):
    """Test cases for LogAggregator"""
    
    def setUp(self):
        self.log_aggregator = LogAggregator()
    
    def test_add_log_entry(self):
        """Test adding log entry"""
        log_entry = LogEntry(
            timestamp=datetime.now(),
            level='INFO',
            service='test-service',
            message='Test log message'
        )
        
        self.log_aggregator.add_log(log_entry)
        
        self.assertEqual(len(self.log_aggregator.logs), 1)
        self.assertEqual(self.log_aggregator.logs[0].message, 'Test log message')
    
    def test_search_logs(self):
        """Test log search functionality"""
        # Add test logs
        for i in range(5):
            log_entry = LogEntry(
                timestamp=datetime.now(),
                level='INFO' if i % 2 == 0 else 'ERROR',
                service='test-service',
                message=f'Test message {i}'
            )
            self.log_aggregator.add_log(log_entry)
        
        # Search by level
        error_logs = self.log_aggregator.search_logs('', level='ERROR')
        self.assertEqual(len(error_logs), 2)
        
        # Search by text
        message_logs = self.log_aggregator.search_logs('message 1')
        self.assertEqual(len(message_logs), 1)


class TestDeploymentAutomation(unittest.TestCase):
    """Test cases for DeploymentAutomation"""
    
    def setUp(self):
        self.deployment = DeploymentAutomation()
    
    def test_deployment_creation(self):
        """Test deployment creation"""
        success = self.deployment.deploy('test-service', 'v1.0.0', 'rolling')
        
        self.assertTrue(success)
        self.assertEqual(len(self.deployment.deployments), 1)
    
    def test_deployment_strategies(self):
        """Test different deployment strategies"""
        strategies = ['rolling', 'blue_green', 'canary']
        
        for strategy in strategies:
            success = self.deployment.deploy(f'test-service-{strategy}', 'v1.0.0', strategy)
            self.assertTrue(success)


# ============================================================================
# DEMO AND USAGE EXAMPLES
# ============================================================================

def demo_health_monitoring():
    """Demonstrate health monitoring system"""
    print("🏥 Health Monitoring System Demo")
    print("=" * 50)
    
    health_system = HealthMonitoringSystem()
    
    # Add health checks
    health_system.add_health_check(HealthCheck(
        name="web-service",
        url="https://httpbin.org/status/200",
        expected_status=200,
        critical=True
    ))
    
    health_system.add_health_check(HealthCheck(
        name="api-service",
        url="https://httpbin.org/status/200",
        expected_status=200
    ))
    
    # Run health checks
    results = health_system.run_all_checks()
    print(f"Overall Status: {results['overall_status']}")
    print(f"Healthy Services: {results['healthy_services']}/{results['total_services']}")
    
    for service, result in results['services'].items():
        print(f"  {service}: {result['status']} ({result.get('response_time', 0):.3f}s)")


def demo_configuration_manager():
    """Demonstrate configuration management system"""
    print("\n⚙️ Configuration Manager Demo")
    print("=" * 50)
    
    config_manager = ConfigurationManager()
    
    # Set configurations
    config_manager.set('database.host', 'localhost')
    config_manager.set('database.port', 5432)
    config_manager.set('redis.host', 'redis-server')
    config_manager.set('redis.port', 6379)
    
    # Get configurations
    print(f"Database Host: {config_manager.get('database.host')}")
    print(f"Database Port: {config_manager.get('database.port')}")
    print(f"Redis Host: {config_manager.get('redis.host')}")
    
    # Validate configuration
    schema = {
        'database': {
            'host': str,
            'port': int
        },
        'redis': {
            'host': str,
            'port': int
        }
    }
    
    is_valid, errors = config_manager.validate_config(schema)
    print(f"Configuration Valid: {is_valid}")
    if errors:
        print(f"Errors: {errors}")


def demo_log_aggregator():
    """Demonstrate log aggregation system"""
    print("\n📊 Log Aggregator Demo")
    print("=" * 50)
    
    log_aggregator = LogAggregator()
    
    # Add log filter
    def error_filter(log_entry):
        return log_entry.level in ['ERROR', 'WARN', 'INFO']
    
    log_aggregator.add_filter('error_filter', error_filter)
    
    # Add log analyzer
    def error_analyzer(log_entry):
        if log_entry.level == 'ERROR':
            print(f"🚨 Error detected: {log_entry.message}")
    
    log_aggregator.add_analyzer(error_analyzer)
    
    # Add sample logs
    sample_logs = [
        "2024-01-15 10:30:00 [INFO] Application started",
        "2024-01-15 10:31:00 [ERROR] Database connection failed",
        "2024-01-15 10:32:00 [WARN] High memory usage detected",
        "2024-01-15 10:33:00 [INFO] User login successful"
    ]
    
    for log_string in sample_logs:
        log_aggregator.add_log_from_string(log_string, 'web-app')
    
    # Get statistics
    stats = log_aggregator.get_log_statistics()
    print(f"Total Logs: {stats['total_logs']}")
    print(f"Level Distribution: {stats['level_distribution']}")
    print(f"Service Distribution: {stats['service_distribution']}")


def demo_deployment_automation():
    """Demonstrate deployment automation system"""
    print("\n🚀 Deployment Automation Demo")
    print("=" * 50)
    
    deployment = DeploymentAutomation()
    
    # Add validator
    def version_validator(service_name, version, config):
        return version.startswith('v') and '.' in version
    
    deployment.add_validator(version_validator)
    
    # Add notifier
    def deployment_notifier(deployment_info, status):
        print(f"📢 Deployment {deployment_info['id']}: {status}")
    
    deployment.add_notifier(deployment_notifier)
    
    # Deploy services with different strategies
    strategies = ['rolling', 'blue_green', 'canary']
    
    for strategy in strategies:
        success = deployment.deploy(
            f'demo-service-{strategy}',
            'v1.2.0',
            strategy,
            {'canary_percentage': 20} if strategy == 'canary' else {}
        )
        print(f"Deployment {strategy}: {'✅ Success' if success else '❌ Failed'}")
    
    # List deployments
    deployments = deployment.list_deployments()
    print(f"\nTotal Deployments: {len(deployments)}")
    for dep in deployments[:3]:  # Show first 3
        print(f"  {dep['service_name']} ({dep['strategy']}): {dep['status']}")


if __name__ == "__main__":
    # Run demos
    demo_health_monitoring()
    demo_configuration_manager()
    demo_log_aggregator()
    demo_deployment_automation()
    
    print("\n🧪 Running Test Suite")
    print("=" * 50)
    
    # Run tests
    unittest.main(argv=[''], exit=False, verbosity=2)
