# 🎯 Python Automation & Observability Interview Preparation

## 📚 Core Topics to Master

### **Automation Fundamentals**
- Infrastructure as Code (IaC) concepts
- CI/CD pipeline automation
- Configuration management
- Deployment automation
- Monitoring automation
- Alert automation

### **Observability Pillars**
- **Metrics**: Prometheus, Grafana, custom metrics
- **Logging**: Structured logging, log aggregation
- **Tracing**: Distributed tracing, performance monitoring
- **Alerting**: Intelligent alerting, alert fatigue prevention

### **Essential Python Libraries**
```python
# Infrastructure & Cloud
import boto3          # AWS automation
import kubernetes     # K8s automation
import docker         # Container automation
import paramiko       # SSH automation

# Monitoring & Observability
import prometheus_client  # Metrics collection
import requests          # HTTP monitoring
import psutil           # System monitoring
import logging          # Structured logging

# Data Processing
import pandas as pd     # Data analysis
import json            # JSON processing
import yaml            # YAML configuration
import csv             # CSV processing

# Testing & Quality
import pytest          # Testing framework
import unittest        # Unit testing
import mock           # Mocking
```

## 🚀 Common Automation Patterns

### **1. Infrastructure Automation (AWS)**
```python
import boto3
import json
from typing import Dict, List

class InfrastructureAutomation:
    def __init__(self, region: str = 'us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.ecs = boto3.client('ecs', region_name=region)
    
    def create_ec2_instance(self, instance_type: str, key_name: str) -> str:
        """Create EC2 instance with proper error handling"""
        try:
            response = self.ec2.run_instances(
                ImageId='ami-0abcdef1234567890',  # Replace with actual AMI
                MinCount=1,
                MaxCount=1,
                InstanceType=instance_type,
                KeyName=key_name,
                TagSpecifications=[{
                    'ResourceType': 'instance',
                    'Tags': [
                        {'Key': 'Name', 'Value': 'automated-instance'},
                        {'Key': 'Environment', 'Value': 'production'}
                    ]
                }]
            )
            return response['Instances'][0]['InstanceId']
        except Exception as e:
            print(f"Error creating instance: {e}")
            return None
    
    def scale_ecs_service(self, cluster: str, service: str, desired_count: int) -> bool:
        """Scale ECS service to desired count"""
        try:
            self.ecs.update_service(
                cluster=cluster,
                service=service,
                desiredCount=desired_count
            )
            return True
        except Exception as e:
            print(f"Error scaling service: {e}")
            return False
```

### **2. Kubernetes Automation**
```python
from kubernetes import client, config
import yaml
from typing import Dict, Any

class KubernetesAutomation:
    def __init__(self):
        config.load_kube_config()
        self.v1 = client.CoreV1Api()
        self.apps_v1 = client.AppsV1Api()
    
    def deploy_application(self, manifest_file: str) -> bool:
        """Deploy application from YAML manifest"""
        try:
            with open(manifest_file, 'r') as f:
                manifests = yaml.safe_load_all(f)
            
            for manifest in manifests:
                if manifest['kind'] == 'Deployment':
                    self.apps_v1.create_namespaced_deployment(
                        namespace=manifest['metadata']['namespace'],
                        body=manifest
                    )
                elif manifest['kind'] == 'Service':
                    self.v1.create_namespaced_service(
                        namespace=manifest['metadata']['namespace'],
                        body=manifest
                    )
            return True
        except Exception as e:
            print(f"Deployment failed: {e}")
            return False
    
    def get_pod_status(self, namespace: str = 'default') -> Dict[str, str]:
        """Get status of all pods in namespace"""
        try:
            pods = self.v1.list_namespaced_pod(namespace=namespace)
            status = {}
            for pod in pods.items:
                status[pod.metadata.name] = pod.status.phase
            return status
        except Exception as e:
            print(f"Error getting pod status: {e}")
            return {}
```

### **3. Monitoring & Metrics Collection**
```python
import prometheus_client
import time
import requests
from prometheus_client import Counter, Histogram, Gauge, start_http_server
from typing import Dict, Any

class MonitoringSystem:
    def __init__(self, port: int = 8000):
        # Define metrics
        self.request_count = Counter(
            'http_requests_total', 
            'Total HTTP requests', 
            ['method', 'endpoint', 'status']
        )
        self.request_duration = Histogram(
            'http_request_duration_seconds', 
            'HTTP request duration'
        )
        self.active_connections = Gauge(
            'active_connections', 
            'Number of active connections'
        )
        self.error_rate = Gauge(
            'error_rate', 
            'Current error rate percentage'
        )
        
        # Start metrics server
        start_http_server(port)
    
    def record_request(self, method: str, endpoint: str, status: int, duration: float):
        """Record HTTP request metrics"""
        self.request_count.labels(
            method=method, 
            endpoint=endpoint, 
            status=str(status)
        ).inc()
        self.request_duration.observe(duration)
    
    def update_connection_count(self, count: int):
        """Update active connections count"""
        self.active_connections.set(count)
    
    def update_error_rate(self, rate: float):
        """Update error rate percentage"""
        self.error_rate.set(rate)
    
    def health_check(self, url: str) -> Dict[str, Any]:
        """Perform health check and return metrics"""
        start_time = time.time()
        try:
            response = requests.get(url, timeout=5)
            duration = time.time() - start_time
            
            self.record_request('GET', '/health', response.status_code, duration)
            
            return {
                'status': 'healthy' if response.status_code == 200 else 'unhealthy',
                'response_time': duration,
                'status_code': response.status_code
            }
        except Exception as e:
            duration = time.time() - start_time
            self.record_request('GET', '/health', 0, duration)
            return {
                'status': 'error',
                'response_time': duration,
                'error': str(e)
            }
```

## 📊 Observability Patterns

### **1. Structured Logging**
```python
import logging
import json
from datetime import datetime
from typing import Dict, Any

class StructuredLogger:
    def __init__(self, name: str, level: int = logging.INFO):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(level)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        # Add handlers
        handler = logging.StreamHandler()
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def log_event(self, event_type: str, **kwargs):
        """Log structured event with metadata"""
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            **kwargs
        }
        self.logger.info(json.dumps(log_data))
    
    def log_error(self, error: Exception, context: Dict[str, Any] = None):
        """Log error with context"""
        error_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': 'error',
            'error_type': type(error).__name__,
            'error_message': str(error),
            'context': context or {}
        }
        self.logger.error(json.dumps(error_data))
```

### **2. Health Check System**
```python
import requests
import time
from typing import Dict, List, Any
from concurrent.futures import ThreadPoolExecutor, as_completed

class HealthChecker:
    def __init__(self):
        self.checks = []
    
    def add_check(self, name: str, url: str, expected_status: int = 200, timeout: int = 5):
        """Add health check endpoint"""
        self.checks.append({
            'name': name,
            'url': url,
            'expected_status': expected_status,
            'timeout': timeout
        })
    
    def run_single_check(self, check: Dict[str, Any]) -> Dict[str, Any]:
        """Run single health check"""
        try:
            start_time = time.time()
            response = requests.get(
                check['url'], 
                timeout=check['timeout']
            )
            duration = time.time() - start_time
            
            is_healthy = response.status_code == check['expected_status']
            
            return {
                'name': check['name'],
                'status': 'healthy' if is_healthy else 'unhealthy',
                'status_code': response.status_code,
                'response_time': duration,
                'error': None
            }
        except Exception as e:
            return {
                'name': check['name'],
                'status': 'error',
                'status_code': None,
                'response_time': None,
                'error': str(e)
            }
    
    def run_all_checks(self) -> Dict[str, Any]:
        """Run all health checks in parallel"""
        results = {}
        
        with ThreadPoolExecutor(max_workers=10) as executor:
            future_to_check = {
                executor.submit(self.run_single_check, check): check 
                for check in self.checks
            }
            
            for future in as_completed(future_to_check):
                result = future.result()
                results[result['name']] = result
        
        # Calculate overall health
        healthy_count = sum(1 for r in results.values() if r['status'] == 'healthy')
        total_count = len(results)
        
        overall_status = 'healthy' if healthy_count == total_count else 'degraded' if healthy_count > 0 else 'unhealthy'
        
        return {
            'overall_status': overall_status,
            'healthy_checks': healthy_count,
            'total_checks': total_count,
            'checks': results
        }
```

### **3. Intelligent Alerting System**
```python
import smtplib
import json
from email.mime.text import MIMEText
from typing import Dict, List, Any
from datetime import datetime, timedelta
from collections import defaultdict

class AlertManager:
    def __init__(self, smtp_server: str, smtp_port: int, username: str, password: str):
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.username = username
        self.password = password
        self.alert_history = []
        self.alert_counts = defaultdict(int)
        self.last_alert_time = defaultdict(lambda: datetime.min)
    
    def should_send_alert(self, alert_type: str, cooldown_minutes: int = 15) -> bool:
        """Check if alert should be sent based on cooldown period"""
        now = datetime.now()
        last_alert = self.last_alert_time[alert_type]
        
        if now - last_alert < timedelta(minutes=cooldown_minutes):
            return False
        
        self.last_alert_time[alert_type] = now
        return True
    
    def send_alert(self, alert_type: str, message: str, severity: str = 'warning', 
                   recipients: List[str] = None):
        """Send alert with intelligent throttling"""
        if not self.should_send_alert(alert_type):
            print(f"Alert {alert_type} suppressed due to cooldown period")
            return
        
        alert = {
            'timestamp': datetime.utcnow().isoformat(),
            'type': alert_type,
            'message': message,
            'severity': severity
        }
        
        self.alert_history.append(alert)
        self.alert_counts[alert_type] += 1
        
        # Send email for critical alerts
        if severity in ['critical', 'error'] and recipients:
            self._send_email_alert(alert, recipients)
        
        # Log alert
        print(f"ALERT [{severity.upper()}]: {message}")
    
    def _send_email_alert(self, alert: Dict[str, Any], recipients: List[str]):
        """Send email alert"""
        try:
            msg = MIMEText(f"Alert: {alert['message']}\n\nTimestamp: {alert['timestamp']}")
            msg['Subject'] = f"[{alert['severity'].upper()}] {alert['type']}"
            msg['From'] = self.username
            msg['To'] = ', '.join(recipients)
            
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.username, self.password)
            server.send_message(msg)
            server.quit()
        except Exception as e:
            print(f"Failed to send email alert: {e}")
    
    def get_alert_summary(self) -> Dict[str, Any]:
        """Get summary of alert history"""
        return {
            'total_alerts': len(self.alert_history),
            'alert_counts': dict(self.alert_counts),
            'recent_alerts': self.alert_history[-10:]  # Last 10 alerts
        }
```

## 🧪 Testing Patterns

### **1. Unit Testing with Mocking**
```python
import unittest
from unittest.mock import Mock, patch, MagicMock
import requests

class TestInfrastructureAutomation(unittest.TestCase):
    def setUp(self):
        self.automation = InfrastructureAutomation()
    
    @patch('boto3.client')
    def test_create_ec2_instance_success(self, mock_boto_client):
        """Test successful EC2 instance creation"""
        # Mock the EC2 client response
        mock_ec2 = Mock()
        mock_ec2.run_instances.return_value = {
            'Instances': [{'InstanceId': 'i-1234567890abcdef0'}]
        }
        mock_boto_client.return_value = mock_ec2
        
        # Test the method
        result = self.automation.create_ec2_instance('t3.micro', 'test-key')
        
        # Assertions
        self.assertEqual(result, 'i-1234567890abcdef0')
        mock_ec2.run_instances.assert_called_once()
    
    @patch('requests.get')
    def test_health_check_success(self, mock_get):
        """Test successful health check"""
        # Mock successful response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_get.return_value = mock_response
        
        monitor = MonitoringSystem()
        result = monitor.health_check('http://example.com/health')
        
        self.assertEqual(result['status'], 'healthy')
        self.assertEqual(result['status_code'], 200)
```

### **2. Integration Testing**
```python
import pytest
import time
from unittest.mock import patch

class TestHealthCheckerIntegration:
    def test_health_checker_with_real_endpoints(self):
        """Integration test with real HTTP endpoints"""
        checker = HealthChecker()
        checker.add_check('google', 'https://www.google.com', 200)
        checker.add_check('invalid', 'https://invalid-url-that-does-not-exist.com', 200)
        
        results = checker.run_all_checks()
        
        assert 'google' in results['checks']
        assert 'invalid' in results['checks']
        assert results['checks']['google']['status'] == 'healthy'
        assert results['checks']['invalid']['status'] == 'error'
```

## 🎯 Common Interview Questions & Solutions

### **1. "How would you automate the deployment of a microservice?"**

```python
class MicroserviceDeployment:
    def __init__(self, namespace: str = 'default'):
        self.namespace = namespace
    
    def deploy_microservice(self, service_name: str, image_tag: str, 
                           replicas: int = 3) -> bool:
        """Complete microservice deployment pipeline"""
        try:
            # 1. Build and push Docker image
            if not self._build_and_push_image(service_name, image_tag):
                return False
            
            # 2. Update Kubernetes deployment
            if not self._update_deployment(service_name, image_tag, replicas):
                return False
            
            # 3. Wait for rollout to complete
            if not self._wait_for_rollout(service_name):
                return False
            
            # 4. Run health checks
            if not self._run_health_checks(service_name):
                return False
            
            # 5. Update monitoring
            self._update_monitoring(service_name)
            
            return True
        except Exception as e:
            print(f"Deployment failed: {e}")
            return False
    
    def _build_and_push_image(self, service_name: str, tag: str) -> bool:
        """Build and push Docker image"""
        # Implementation would use docker-py or subprocess
        pass
    
    def _update_deployment(self, service_name: str, image_tag: str, replicas: int) -> bool:
        """Update Kubernetes deployment"""
        # Implementation would use kubernetes-py
        pass
    
    def _wait_for_rollout(self, service_name: str) -> bool:
        """Wait for deployment rollout to complete"""
        # Implementation would poll deployment status
        pass
    
    def _run_health_checks(self, service_name: str) -> bool:
        """Run post-deployment health checks"""
        # Implementation would check service endpoints
        pass
    
    def _update_monitoring(self, service_name: str):
        """Update monitoring configuration"""
        # Implementation would update Prometheus/Grafana configs
        pass
```

### **2. "How would you implement circuit breaker pattern for external API calls?"**

```python
import time
from enum import Enum
from typing import Callable, Any

class CircuitState(Enum):
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Circuit is open, failing fast
    HALF_OPEN = "half_open"  # Testing if service is back

class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, 
                 recovery_timeout: int = 60, 
                 expected_exception: type = Exception):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
    
    def call(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with circuit breaker protection"""
        if self.state == CircuitState.OPEN:
            if self._should_attempt_reset():
                self.state = CircuitState.HALF_OPEN
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except self.expected_exception as e:
            self._on_failure()
            raise e
    
    def _should_attempt_reset(self) -> bool:
        """Check if enough time has passed to attempt reset"""
        return (time.time() - self.last_failure_time) >= self.recovery_timeout
    
    def _on_success(self):
        """Handle successful call"""
        self.failure_count = 0
        self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        """Handle failed call"""
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN

# Usage example
def unreliable_api_call():
    """Simulate unreliable API call"""
    import random
    if random.random() < 0.7:  # 70% failure rate
        raise requests.RequestException("API call failed")
    return "Success"

# Use circuit breaker
breaker = CircuitBreaker(failure_threshold=3, recovery_timeout=30)

try:
    result = breaker.call(unreliable_api_call)
    print(f"API call successful: {result}")
except Exception as e:
    print(f"API call failed: {e}")
```

## 📝 Quick Reference Commands

### **Python Testing**
```bash
# Run tests
pytest test_file.py -v
pytest --cov=module_name  # With coverage
pytest -k "test_name"     # Run specific test

# Mock testing
from unittest.mock import Mock, patch
```

### **Docker Commands**
```bash
# Build and run
docker build -t service:latest .
docker run -p 8080:8080 service:latest

# Docker Compose
docker-compose up -d
docker-compose logs -f service_name
```

### **Kubernetes Commands**
```bash
# Deploy and manage
kubectl apply -f deployment.yaml
kubectl get pods -l app=service-name
kubectl logs -f deployment/service-name
kubectl rollout status deployment/service-name
```

### **Monitoring Commands**
```bash
# Prometheus queries
rate(http_requests_total[5m])
histogram_quantile(0.95, http_request_duration_seconds)

# Log analysis
grep "ERROR" /var/log/app.log | tail -100
```

## 🎯 Pair Programming Tips

1. **Communication**: Explain your thought process out loud
2. **Collaboration**: Ask for input and suggestions
3. **Code Quality**: Write clean, readable code with comments
4. **Testing**: Write tests as you go
5. **Error Handling**: Always include proper error handling
6. **Documentation**: Add docstrings and comments
7. **Iterative**: Build incrementally and test frequently

## 📚 Additional Resources

- **Python Best Practices**: PEP 8, type hints, async/await
- **Testing**: pytest, unittest, mocking strategies
- **Monitoring**: Prometheus metrics, Grafana dashboards
- **Infrastructure**: Terraform, Ansible, Docker, Kubernetes
- **Cloud Platforms**: AWS, Azure, GCP automation APIs

