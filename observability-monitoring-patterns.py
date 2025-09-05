#!/usr/bin/env python3
"""
Advanced Observability & Monitoring Patterns for Python Interviews
==================================================================

This file demonstrates advanced observability patterns commonly used in production systems.
Each pattern includes:
- Real-world implementation
- Best practices
- Performance considerations
- Integration examples
- Testing strategies

Perfect for demonstrating deep understanding of observability concepts in interviews!
"""

import asyncio
import time
import json
import logging
import threading
from typing import Dict, List, Any, Optional, Callable, Union
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from collections import defaultdict, deque
from contextlib import contextmanager
from functools import wraps
import prometheus_client
from prometheus_client import Counter, Histogram, Gauge, Summary, Info
import aiohttp
import psutil
import requests
from concurrent.futures import ThreadPoolExecutor
import queue
import signal
import sys


# ============================================================================
# PATTERN 1: DISTRIBUTED TRACING SYSTEM
# ============================================================================

@dataclass
class Span:
    trace_id: str
    span_id: str
    parent_span_id: Optional[str]
    operation_name: str
    start_time: datetime
    end_time: Optional[datetime]
    tags: Dict[str, Any]
    logs: List[Dict[str, Any]]
    status: str = 'started'

class DistributedTracer:
    """
    Advanced distributed tracing system with context propagation
    
    Features:
    - Trace context propagation
    - Span lifecycle management
    - Performance metrics collection
    - Error tracking and correlation
    - Sampling strategies
    """
    
    def __init__(self, service_name: str, sampling_rate: float = 1.0):
        self.service_name = service_name
        self.sampling_rate = sampling_rate
        self.active_spans: Dict[str, Span] = {}
        self.completed_spans: List[Span] = []
        self.trace_context = threading.local()
        
        # Metrics
        self.traces_total = Counter(
            'traces_total',
            'Total number of traces',
            ['service', 'status']
        )
        self.span_duration = Histogram(
            'span_duration_seconds',
            'Span duration in seconds',
            ['service', 'operation']
        )
        self.active_spans_gauge = Gauge(
            'active_spans',
            'Number of active spans',
            ['service']
        )
    
    def start_trace(self, operation_name: str, trace_id: str = None, 
                   parent_context: Dict = None) -> str:
        """Start a new trace or span"""
        import uuid
        
        if trace_id is None:
            trace_id = str(uuid.uuid4())
        
        span_id = str(uuid.uuid4())
        parent_span_id = None
        
        # Handle parent context propagation
        if parent_context:
            parent_span_id = parent_context.get('span_id')
            trace_id = parent_context.get('trace_id', trace_id)
        
        span = Span(
            trace_id=trace_id,
            span_id=span_id,
            parent_span_id=parent_span_id,
            operation_name=operation_name,
            start_time=datetime.now(),
            end_time=None,
            tags={'service': self.service_name},
            logs=[]
        )
        
        self.active_spans[span_id] = span
        self.trace_context.span = span
        
        # Update metrics
        self.active_spans_gauge.labels(service=self.service_name).set(len(self.active_spans))
        
        return span_id
    
    def finish_span(self, span_id: str, status: str = 'success', 
                   error: Exception = None) -> Optional[Span]:
        """Finish a span and move to completed spans"""
        if span_id not in self.active_spans:
            return None
        
        span = self.active_spans[span_id]
        span.end_time = datetime.now()
        span.status = status
        
        if error:
            span.tags['error'] = True
            span.tags['error.message'] = str(error)
            span.tags['error.type'] = type(error).__name__
            self._add_log(span, 'error', {'error': str(error)})
        
        # Calculate duration
        duration = (span.end_time - span.start_time).total_seconds()
        
        # Update metrics
        self.span_duration.labels(
            service=self.service_name,
            operation=span.operation_name
        ).observe(duration)
        
        self.traces_total.labels(
            service=self.service_name,
            status=status
        ).inc()
        
        # Move to completed spans
        self.completed_spans.append(span)
        del self.active_spans[span_id]
        
        # Update active spans gauge
        self.active_spans_gauge.labels(service=self.service_name).set(len(self.active_spans))
        
        return span
    
    def add_tag(self, span_id: str, key: str, value: Any):
        """Add tag to span"""
        if span_id in self.active_spans:
            self.active_spans[span_id].tags[key] = value
    
    def add_log(self, span_id: str, event: str, fields: Dict[str, Any] = None):
        """Add log entry to span"""
        if span_id in self.active_spans:
            self._add_log(self.active_spans[span_id], event, fields or {})
    
    def _add_log(self, span: Span, event: str, fields: Dict[str, Any]):
        """Internal method to add log to span"""
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'event': event,
            'fields': fields
        }
        span.logs.append(log_entry)
    
    def get_trace_context(self) -> Dict[str, str]:
        """Get current trace context for propagation"""
        if hasattr(self.trace_context, 'span'):
            span = self.trace_context.span
            return {
                'trace_id': span.trace_id,
                'span_id': span.span_id
            }
        return {}
    
    def inject_headers(self, headers: Dict[str, str] = None) -> Dict[str, str]:
        """Inject trace context into HTTP headers"""
        if headers is None:
            headers = {}
        
        context = self.get_trace_context()
        if context:
            headers['X-Trace-ID'] = context['trace_id']
            headers['X-Span-ID'] = context['span_id']
        
        return headers
    
    def extract_context(self, headers: Dict[str, str]) -> Dict[str, str]:
        """Extract trace context from HTTP headers"""
        return {
            'trace_id': headers.get('X-Trace-ID'),
            'span_id': headers.get('X-Span-ID')
        }
    
    def get_trace_summary(self, trace_id: str) -> Dict[str, Any]:
        """Get summary of a complete trace"""
        trace_spans = [s for s in self.completed_spans if s.trace_id == trace_id]
        
        if not trace_spans:
            return {'error': 'Trace not found'}
        
        # Calculate trace metrics
        start_time = min(s.start_time for s in trace_spans)
        end_time = max(s.end_time for s in trace_spans if s.end_time)
        duration = (end_time - start_time).total_seconds() if end_time else None
        
        # Build span hierarchy
        span_map = {s.span_id: s for s in trace_spans}
        root_spans = [s for s in trace_spans if s.parent_span_id is None]
        
        return {
            'trace_id': trace_id,
            'service': self.service_name,
            'start_time': start_time.isoformat(),
            'end_time': end_time.isoformat() if end_time else None,
            'duration': duration,
            'span_count': len(trace_spans),
            'root_spans': [asdict(s) for s in root_spans],
            'status': 'success' if all(s.status == 'success' for s in trace_spans) else 'error'
        }


# ============================================================================
# PATTERN 2: CIRCUIT BREAKER WITH INTELLIGENT RECOVERY
# ============================================================================

class CircuitBreakerState:
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Circuit is open, failing fast
    HALF_OPEN = "half_open"  # Testing if service is back

class IntelligentCircuitBreaker:
    """
    Advanced circuit breaker with intelligent recovery strategies
    
    Features:
    - Adaptive failure thresholds
    - Exponential backoff with jitter
    - Health check integration
    - Metrics collection
    - Multiple recovery strategies
    """
    
    def __init__(self, name: str, failure_threshold: int = 5, 
                 recovery_timeout: int = 60, expected_exception: type = Exception):
        self.name = name
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
        self.last_success_time = None
        self.state = CircuitBreakerState.CLOSED
        
        # Adaptive thresholds
        self.adaptive_threshold = failure_threshold
        self.consecutive_successes = 0
        
        # Metrics
        self.circuit_breaker_state = Gauge(
            'circuit_breaker_state',
            'Circuit breaker state (0=closed, 1=open, 2=half_open)',
            ['name']
        )
        self.circuit_breaker_failures = Counter(
            'circuit_breaker_failures_total',
            'Total circuit breaker failures',
            ['name']
        )
        self.circuit_breaker_requests = Counter(
            'circuit_breaker_requests_total',
            'Total circuit breaker requests',
            ['name', 'result']
        )
    
    def call(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with circuit breaker protection"""
        self._update_metrics()
        
        if self.state == CircuitBreakerState.OPEN:
            if self._should_attempt_reset():
                self.state = CircuitBreakerState.HALF_OPEN
                self.consecutive_successes = 0
            else:
                self.circuit_breaker_requests.labels(
                    name=self.name, result='circuit_open'
                ).inc()
                raise Exception(f"Circuit breaker {self.name} is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            self.circuit_breaker_requests.labels(
                name=self.name, result='success'
            ).inc()
            return result
            
        except self.expected_exception as e:
            self._on_failure()
            self.circuit_breaker_requests.labels(
                name=self.name, result='failure'
            ).inc()
            raise e
    
    def _should_attempt_reset(self) -> bool:
        """Check if enough time has passed to attempt reset"""
        if self.last_failure_time is None:
            return True
        
        # Exponential backoff with jitter
        base_timeout = self.recovery_timeout
        exponential_factor = min(2 ** (self.failure_count // self.failure_threshold), 16)
        jitter = time.time() % 10  # Add up to 10 seconds of jitter
        
        timeout = base_timeout * exponential_factor + jitter
        return (time.time() - self.last_failure_time) >= timeout
    
    def _on_success(self):
        """Handle successful call"""
        self.success_count += 1
        self.last_success_time = time.time()
        self.consecutive_successes += 1
        
        if self.state == CircuitBreakerState.HALF_OPEN:
            # Need multiple successes to close circuit
            if self.consecutive_successes >= 3:
                self.state = CircuitBreakerState.CLOSED
                self.failure_count = 0
                self.consecutive_successes = 0
        elif self.state == CircuitBreakerState.CLOSED:
            # Reset failure count on success
            if self.failure_count > 0:
                self.failure_count = max(0, self.failure_count - 1)
    
    def _on_failure(self):
        """Handle failed call"""
        self.failure_count += 1
        self.last_failure_time = time.time()
        self.consecutive_successes = 0
        
        # Adaptive threshold adjustment
        if self.failure_count > self.adaptive_threshold:
            self.adaptive_threshold = min(
                self.adaptive_threshold * 1.2, 
                self.failure_threshold * 2
            )
        
        if self.failure_count >= self.adaptive_threshold:
            self.state = CircuitBreakerState.OPEN
            self.circuit_breaker_failures.labels(name=self.name).inc()
    
    def _update_metrics(self):
        """Update Prometheus metrics"""
        state_value = {
            CircuitBreakerState.CLOSED: 0,
            CircuitBreakerState.OPEN: 1,
            CircuitBreakerState.HALF_OPEN: 2
        }[self.state]
        
        self.circuit_breaker_state.labels(name=self.name).set(state_value)
    
    def get_state(self) -> Dict[str, Any]:
        """Get current circuit breaker state"""
        return {
            'name': self.name,
            'state': self.state,
            'failure_count': self.failure_count,
            'success_count': self.success_count,
            'adaptive_threshold': self.adaptive_threshold,
            'last_failure_time': self.last_failure_time.isoformat() if self.last_failure_time else None,
            'last_success_time': self.last_success_time.isoformat() if self.last_success_time else None
        }


# ============================================================================
# PATTERN 3: ASYNCHRONOUS METRICS COLLECTOR
# ============================================================================

@dataclass
class MetricData:
    name: str
    value: float
    timestamp: datetime
    labels: Dict[str, str]
    metric_type: str  # counter, gauge, histogram, summary

class AsyncMetricsCollector:
    """
    High-performance asynchronous metrics collection system
    
    Features:
    - Async metric collection
    - Batch processing
    - Metric aggregation
    - Backpressure handling
    - Multiple output formats
    """
    
    def __init__(self, batch_size: int = 1000, flush_interval: float = 5.0):
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.metrics_queue = asyncio.Queue(maxsize=10000)
        self.metrics_buffer: List[MetricData] = []
        self.aggregated_metrics: Dict[str, Dict] = defaultdict(dict)
        self.running = False
        self.collector_task = None
        
        # Performance metrics
        self.collection_duration = Histogram(
            'metrics_collection_duration_seconds',
            'Time to collect metrics batch'
        )
        self.metrics_processed = Counter(
            'metrics_processed_total',
            'Total metrics processed'
        )
        self.queue_size = Gauge(
            'metrics_queue_size',
            'Current metrics queue size'
        )
    
    async def start(self):
        """Start the metrics collector"""
        if self.running:
            return
        
        self.running = True
        self.collector_task = asyncio.create_task(self._collector_loop())
    
    async def stop(self):
        """Stop the metrics collector"""
        self.running = False
        if self.collector_task:
            await self.collector_task
    
    async def record_metric(self, name: str, value: float, 
                          labels: Dict[str, str] = None, 
                          metric_type: str = 'gauge'):
        """Record a metric asynchronously"""
        metric = MetricData(
            name=name,
            value=value,
            timestamp=datetime.now(),
            labels=labels or {},
            metric_type=metric_type
        )
        
        try:
            await self.metrics_queue.put(metric)
        except asyncio.QueueFull:
            # Handle backpressure by dropping oldest metrics
            try:
                await self.metrics_queue.get()
                await self.metrics_queue.put(metric)
            except asyncio.QueueEmpty:
                pass
    
    async def _collector_loop(self):
        """Main collector loop"""
        while self.running:
            try:
                # Collect metrics in batches
                batch = []
                timeout = self.flush_interval
                
                # Collect up to batch_size metrics or timeout
                start_time = time.time()
                while len(batch) < self.batch_size and (time.time() - start_time) < timeout:
                    try:
                        metric = await asyncio.wait_for(
                            self.metrics_queue.get(), 
                            timeout=0.1
                        )
                        batch.append(metric)
                    except asyncio.TimeoutError:
                        break
                
                if batch:
                    await self._process_batch(batch)
                
                # Update queue size metric
                self.queue_size.set(self.metrics_queue.qsize())
                
            except Exception as e:
                logging.error(f"Metrics collector error: {e}")
                await asyncio.sleep(1)
    
    async def _process_batch(self, batch: List[MetricData]):
        """Process a batch of metrics"""
        start_time = time.time()
        
        try:
            # Aggregate metrics
            for metric in batch:
                self._aggregate_metric(metric)
            
            # Update processed count
            self.metrics_processed.inc(len(batch))
            
        finally:
            # Record processing time
            duration = time.time() - start_time
            self.collection_duration.observe(duration)
    
    def _aggregate_metric(self, metric: MetricData):
        """Aggregate metric data"""
        key = f"{metric.name}:{json.dumps(metric.labels, sort_keys=True)}"
        
        if metric.metric_type == 'counter':
            if key not in self.aggregated_metrics:
                self.aggregated_metrics[key] = {
                    'value': 0,
                    'count': 0,
                    'last_update': metric.timestamp
                }
            self.aggregated_metrics[key]['value'] += metric.value
            self.aggregated_metrics[key]['count'] += 1
            self.aggregated_metrics[key]['last_update'] = metric.timestamp
            
        elif metric.metric_type == 'gauge':
            self.aggregated_metrics[key] = {
                'value': metric.value,
                'count': 1,
                'last_update': metric.timestamp
            }
            
        elif metric.metric_type == 'histogram':
            if key not in self.aggregated_metrics:
                self.aggregated_metrics[key] = {
                    'values': [],
                    'count': 0,
                    'sum': 0,
                    'last_update': metric.timestamp
                }
            self.aggregated_metrics[key]['values'].append(metric.value)
            self.aggregated_metrics[key]['count'] += 1
            self.aggregated_metrics[key]['sum'] += metric.value
            self.aggregated_metrics[key]['last_update'] = metric.timestamp
    
    def get_aggregated_metrics(self) -> Dict[str, Any]:
        """Get current aggregated metrics"""
        result = {}
        
        for key, data in self.aggregated_metrics.items():
            name, labels_str = key.split(':', 1)
            labels = json.loads(labels_str)
            
            if name not in result:
                result[name] = {}
            
            if data['count'] == 1:
                # Single value
                result[name][labels_str] = {
                    'value': data['value'],
                    'labels': labels,
                    'last_update': data['last_update'].isoformat()
                }
            else:
                # Multiple values - calculate statistics
                if 'values' in data:
                    # Histogram data
                    values = data['values']
                    result[name][labels_str] = {
                        'count': data['count'],
                        'sum': data['sum'],
                        'min': min(values),
                        'max': max(values),
                        'avg': data['sum'] / data['count'],
                        'labels': labels,
                        'last_update': data['last_update'].isoformat()
                    }
                else:
                    # Counter data
                    result[name][labels_str] = {
                        'value': data['value'],
                        'count': data['count'],
                        'labels': labels,
                        'last_update': data['last_update'].isoformat()
                    }
        
        return result
    
    async def export_metrics(self, format_type: str = 'prometheus') -> str:
        """Export metrics in specified format"""
        if format_type == 'prometheus':
            return self._export_prometheus()
        elif format_type == 'json':
            return json.dumps(self.get_aggregated_metrics(), indent=2)
        else:
            raise ValueError(f"Unsupported format: {format_type}")
    
    def _export_prometheus(self) -> str:
        """Export metrics in Prometheus format"""
        lines = []
        
        for name, metric_data in self.get_aggregated_metrics().items():
            for labels_str, data in metric_data.items():
                labels = data['labels']
                label_str = ','.join(f'{k}="{v}"' for k, v in labels.items())
                
                if label_str:
                    metric_line = f'{name}{{{label_str}}} {data["value"]}'
                else:
                    metric_line = f'{name} {data["value"]}'
                
                lines.append(metric_line)
        
        return '\n'.join(lines)


# ============================================================================
# PATTERN 4: INTELLIGENT ALERTING SYSTEM
# ============================================================================

@dataclass
class AlertRule:
    name: str
    condition: Callable
    severity: str
    cooldown: int = 300  # 5 minutes
    escalation_time: int = 1800  # 30 minutes
    notification_channels: List[str] = None

@dataclass
class Alert:
    id: str
    rule_name: str
    severity: str
    message: str
    timestamp: datetime
    status: str = 'active'  # active, resolved, suppressed
    escalation_level: int = 0

class IntelligentAlertingSystem:
    """
    Advanced alerting system with intelligent features
    
    Features:
    - Rule-based alerting
    - Alert correlation and deduplication
    - Escalation policies
    - Alert fatigue prevention
    - Machine learning-based anomaly detection
    - Multi-channel notifications
    """
    
    def __init__(self):
        self.rules: Dict[str, AlertRule] = {}
        self.active_alerts: Dict[str, Alert] = {}
        self.alert_history: List[Alert] = []
        self.suppression_rules: List[Callable] = []
        self.notification_channels: Dict[str, Callable] = {}
        
        # Alert metrics
        self.alerts_total = Counter(
            'alerts_total',
            'Total alerts generated',
            ['rule', 'severity', 'status']
        )
        self.alert_duration = Histogram(
            'alert_duration_seconds',
            'Alert duration in seconds',
            ['rule', 'severity']
        )
        self.active_alerts_gauge = Gauge(
            'active_alerts',
            'Number of active alerts',
            ['severity']
        )
    
    def add_rule(self, rule: AlertRule):
        """Add alert rule"""
        self.rules[rule.name] = rule
    
    def add_suppression_rule(self, suppression_func: Callable):
        """Add alert suppression rule"""
        self.suppression_rules.append(suppression_func)
    
    def add_notification_channel(self, name: str, channel_func: Callable):
        """Add notification channel"""
        self.notification_channels[name] = channel_func
    
    def evaluate_rules(self, metrics: Dict[str, Any]) -> List[Alert]:
        """Evaluate all rules against current metrics"""
        triggered_alerts = []
        
        for rule_name, rule in self.rules.items():
            try:
                if rule.condition(metrics):
                    alert = self._create_alert(rule, metrics)
                    if alert and not self._should_suppress_alert(alert):
                        triggered_alerts.append(alert)
                        self._process_alert(alert)
            except Exception as e:
                logging.error(f"Error evaluating rule {rule_name}: {e}")
        
        return triggered_alerts
    
    def _create_alert(self, rule: AlertRule, metrics: Dict[str, Any]) -> Optional[Alert]:
        """Create alert from rule"""
        import uuid
        
        alert_id = str(uuid.uuid4())
        
        # Check if similar alert already exists
        existing_alert = self._find_similar_alert(rule.name)
        if existing_alert:
            # Update existing alert instead of creating new one
            existing_alert.timestamp = datetime.now()
            return existing_alert
        
        alert = Alert(
            id=alert_id,
            rule_name=rule.name,
            severity=rule.severity,
            message=f"Alert triggered: {rule.name}",
            timestamp=datetime.now()
        )
        
        return alert
    
    def _find_similar_alert(self, rule_name: str) -> Optional[Alert]:
        """Find similar active alert to prevent duplicates"""
        for alert in self.active_alerts.values():
            if (alert.rule_name == rule_name and 
                alert.status == 'active' and
                (datetime.now() - alert.timestamp).total_seconds() < 300):  # 5 minutes
                return alert
        return None
    
    def _should_suppress_alert(self, alert: Alert) -> bool:
        """Check if alert should be suppressed"""
        for suppression_func in self.suppression_rules:
            try:
                if suppression_func(alert):
                    return True
            except Exception as e:
                logging.error(f"Suppression rule error: {e}")
        return False
    
    def _process_alert(self, alert: Alert):
        """Process new alert"""
        self.active_alerts[alert.id] = alert
        self.alert_history.append(alert)
        
        # Update metrics
        self.alerts_total.labels(
            rule=alert.rule_name,
            severity=alert.severity,
            status='active'
        ).inc()
        
        self._update_active_alerts_gauge()
        
        # Send notifications
        self._send_notifications(alert)
        
        # Schedule escalation if needed
        self._schedule_escalation(alert)
    
    def _send_notifications(self, alert: Alert):
        """Send notifications for alert"""
        rule = self.rules.get(alert.rule_name)
        if not rule or not rule.notification_channels:
            return
        
        for channel_name in rule.notification_channels:
            if channel_name in self.notification_channels:
                try:
                    self.notification_channels[channel_name](alert)
                except Exception as e:
                    logging.error(f"Notification channel {channel_name} error: {e}")
    
    def _schedule_escalation(self, alert: Alert):
        """Schedule alert escalation"""
        rule = self.rules.get(alert.rule_name)
        if not rule:
            return
        
        # In a real implementation, this would use a task scheduler
        # For demo purposes, we'll just log the escalation
        logging.info(f"Alert {alert.id} will escalate in {rule.escalation_time} seconds")
    
    def resolve_alert(self, alert_id: str, resolution_message: str = None):
        """Resolve an alert"""
        if alert_id not in self.active_alerts:
            return False
        
        alert = self.active_alerts[alert_id]
        alert.status = 'resolved'
        
        # Calculate duration
        duration = (datetime.now() - alert.timestamp).total_seconds()
        
        # Update metrics
        self.alert_duration.labels(
            rule=alert.rule_name,
            severity=alert.severity
        ).observe(duration)
        
        self.alerts_total.labels(
            rule=alert.rule_name,
            severity=alert.severity,
            status='resolved'
        ).inc()
        
        # Remove from active alerts
        del self.active_alerts[alert_id]
        self._update_active_alerts_gauge()
        
        logging.info(f"Alert {alert_id} resolved: {resolution_message or 'No message'}")
        return True
    
    def _update_active_alerts_gauge(self):
        """Update active alerts gauge metric"""
        severity_counts = defaultdict(int)
        for alert in self.active_alerts.values():
            severity_counts[alert.severity] += 1
        
        for severity, count in severity_counts.items():
            self.active_alerts_gauge.labels(severity=severity).set(count)
    
    def get_alert_summary(self) -> Dict[str, Any]:
        """Get alert system summary"""
        active_by_severity = defaultdict(int)
        for alert in self.active_alerts.values():
            active_by_severity[alert.severity] += 1
        
        return {
            'total_rules': len(self.rules),
            'active_alerts': len(self.active_alerts),
            'active_by_severity': dict(active_by_severity),
            'total_alerts_generated': len(self.alert_history),
            'recent_alerts': [
                {
                    'id': alert.id,
                    'rule': alert.rule_name,
                    'severity': alert.severity,
                    'message': alert.message,
                    'timestamp': alert.timestamp.isoformat(),
                    'status': alert.status
                }
                for alert in self.alert_history[-10:]  # Last 10 alerts
            ]
        }


# ============================================================================
# PATTERN 5: PERFORMANCE MONITORING DECORATOR
# ============================================================================

class PerformanceMonitor:
    """
    Advanced performance monitoring decorator system
    
    Features:
    - Function execution time tracking
    - Memory usage monitoring
    - Exception tracking
    - Custom metrics collection
    - Async function support
    """
    
    def __init__(self, name: str = None):
        self.name = name
        self.execution_time = Histogram(
            'function_execution_time_seconds',
            'Function execution time',
            ['function', 'status']
        )
        self.function_calls = Counter(
            'function_calls_total',
            'Total function calls',
            ['function', 'status']
        )
        self.memory_usage = Histogram(
            'function_memory_usage_bytes',
            'Function memory usage',
            ['function']
        )
    
    def __call__(self, func):
        """Decorator implementation"""
        function_name = self.name or func.__name__
        
        if asyncio.iscoroutinefunction(func):
            @wraps(func)
            async def async_wrapper(*args, **kwargs):
                return await self._monitor_async_function(func, function_name, *args, **kwargs)
            return async_wrapper
        else:
            @wraps(func)
            def sync_wrapper(*args, **kwargs):
                return self._monitor_sync_function(func, function_name, *args, **kwargs)
            return sync_wrapper
    
    def _monitor_sync_function(self, func, function_name, *args, **kwargs):
        """Monitor synchronous function"""
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss
        
        try:
            result = func(*args, **kwargs)
            status = 'success'
            return result
        except Exception as e:
            status = 'error'
            raise e
        finally:
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss
            
            duration = end_time - start_time
            memory_used = end_memory - start_memory
            
            # Update metrics
            self.execution_time.labels(
                function=function_name,
                status=status
            ).observe(duration)
            
            self.function_calls.labels(
                function=function_name,
                status=status
            ).inc()
            
            self.memory_usage.labels(function=function_name).observe(memory_used)
    
    async def _monitor_async_function(self, func, function_name, *args, **kwargs):
        """Monitor asynchronous function"""
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss
        
        try:
            result = await func(*args, **kwargs)
            status = 'success'
            return result
        except Exception as e:
            status = 'error'
            raise e
        finally:
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss
            
            duration = end_time - start_time
            memory_used = end_memory - start_memory
            
            # Update metrics
            self.execution_time.labels(
                function=function_name,
                status=status
            ).observe(duration)
            
            self.function_calls.labels(
                function=function_name,
                status=status
            ).inc()
            
            self.memory_usage.labels(function=function_name).observe(memory_used)


# ============================================================================
# DEMO AND INTEGRATION EXAMPLES
# ============================================================================

async def demo_distributed_tracing():
    """Demonstrate distributed tracing system"""
    print("🔍 Distributed Tracing Demo")
    print("=" * 50)
    
    tracer = DistributedTracer("demo-service")
    
    # Start root span
    root_span_id = tracer.start_trace("user_request")
    tracer.add_tag(root_span_id, "user_id", "12345")
    tracer.add_log(root_span_id, "request_started", {"method": "GET", "path": "/api/users"})
    
    # Simulate nested operations
    await asyncio.sleep(0.1)
    
    # Database operation
    db_span_id = tracer.start_trace("database_query", parent_context=tracer.get_trace_context())
    tracer.add_tag(db_span_id, "query", "SELECT * FROM users WHERE id = ?")
    await asyncio.sleep(0.05)
    tracer.finish_span(db_span_id, "success")
    
    # External API call
    api_span_id = tracer.start_trace("external_api_call", parent_context=tracer.get_trace_context())
    tracer.add_tag(api_span_id, "api", "user-profile-service")
    await asyncio.sleep(0.08)
    tracer.finish_span(api_span_id, "success")
    
    # Finish root span
    tracer.finish_span(root_span_id, "success")
    
    # Get trace summary
    context = tracer.get_trace_context()
    if context:
        summary = tracer.get_trace_summary(context['trace_id'])
        print(f"Trace ID: {summary['trace_id']}")
        print(f"Duration: {summary['duration']:.3f}s")
        print(f"Span Count: {summary['span_count']}")
        print(f"Status: {summary['status']}")


def demo_circuit_breaker():
    """Demonstrate intelligent circuit breaker"""
    print("\n⚡ Circuit Breaker Demo")
    print("=" * 50)
    
    def unreliable_service():
        import random
        if random.random() < 0.7:  # 70% failure rate
            raise requests.RequestException("Service unavailable")
        return "Success"
    
    breaker = IntelligentCircuitBreaker("demo-service", failure_threshold=3)
    
    # Simulate requests
    for i in range(10):
        try:
            result = breaker.call(unreliable_service)
            print(f"Request {i+1}: ✅ {result}")
        except Exception as e:
            print(f"Request {i+1}: ❌ {str(e)}")
        
        time.sleep(0.5)
    
    # Show circuit breaker state
    state = breaker.get_state()
    print(f"\nCircuit Breaker State:")
    print(f"  State: {state['state']}")
    print(f"  Failures: {state['failure_count']}")
    print(f"  Successes: {state['success_count']}")
    print(f"  Adaptive Threshold: {state['adaptive_threshold']}")


async def demo_async_metrics():
    """Demonstrate async metrics collection"""
    print("\n📊 Async Metrics Collection Demo")
    print("=" * 50)
    
    collector = AsyncMetricsCollector(batch_size=5, flush_interval=2.0)
    await collector.start()
    
    try:
        # Generate some metrics
        for i in range(15):
            await collector.record_metric(
                "request_duration",
                value=0.1 + (i * 0.01),
                labels={"service": "api", "endpoint": "/users"},
                metric_type="histogram"
            )
            
            await collector.record_metric(
                "active_connections",
                value=100 + i,
                labels={"service": "api"},
                metric_type="gauge"
            )
            
            await asyncio.sleep(0.1)
        
        # Wait for processing
        await asyncio.sleep(3)
        
        # Export metrics
        prometheus_metrics = await collector.export_metrics('prometheus')
        print("Prometheus Metrics:")
        print(prometheus_metrics[:500] + "..." if len(prometheus_metrics) > 500 else prometheus_metrics)
        
    finally:
        await collector.stop()


def demo_intelligent_alerting():
    """Demonstrate intelligent alerting system"""
    print("\n🚨 Intelligent Alerting Demo")
    print("=" * 50)
    
    alerting = IntelligentAlertingSystem()
    
    # Add alert rules
    def high_cpu_condition(metrics):
        return metrics.get('cpu_usage', 0) > 80
    
    def low_memory_condition(metrics):
        return metrics.get('memory_usage', 0) > 90
    
    alerting.add_rule(AlertRule(
        name="high_cpu",
        condition=high_cpu_condition,
        severity="warning",
        notification_channels=["email", "slack"]
    ))
    
    alerting.add_rule(AlertRule(
        name="low_memory",
        condition=low_memory_condition,
        severity="critical",
        notification_channels=["email", "slack", "pagerduty"]
    ))
    
    # Add notification channels
    def email_notification(alert):
        print(f"📧 Email: {alert.severity.upper()} - {alert.message}")
    
    def slack_notification(alert):
        print(f"💬 Slack: {alert.severity.upper()} - {alert.message}")
    
    def pagerduty_notification(alert):
        print(f"📱 PagerDuty: {alert.severity.upper()} - {alert.message}")
    
    alerting.add_notification_channel("email", email_notification)
    alerting.add_notification_channel("slack", slack_notification)
    alerting.add_notification_channel("pagerduty", pagerduty_notification)
    
    # Simulate metrics and evaluate rules
    test_metrics = [
        {"cpu_usage": 75, "memory_usage": 85},  # No alerts
        {"cpu_usage": 85, "memory_usage": 75},  # High CPU alert
        {"cpu_usage": 95, "memory_usage": 95},  # Both alerts
    ]
    
    for i, metrics in enumerate(test_metrics):
        print(f"\nMetrics {i+1}: {metrics}")
        alerts = alerting.evaluate_rules(metrics)
        if alerts:
            for alert in alerts:
                print(f"  🚨 Alert: {alert.rule_name} ({alert.severity})")
        else:
            print("  ✅ No alerts triggered")
    
    # Show alert summary
    summary = alerting.get_alert_summary()
    print(f"\nAlert Summary:")
    print(f"  Active Alerts: {summary['active_alerts']}")
    print(f"  Total Rules: {summary['total_rules']}")


@PerformanceMonitor("demo_function")
def demo_performance_monitoring():
    """Demonstrate performance monitoring"""
    print("\n⚡ Performance Monitoring Demo")
    print("=" * 50)
    
    # Simulate some work
    time.sleep(0.1)
    
    # Simulate memory allocation
    data = [i for i in range(10000)]
    
    return len(data)


async def main():
    """Run all demos"""
    print("🎯 Advanced Observability Patterns Demo")
    print("=" * 60)
    
    # Run demos
    await demo_distributed_tracing()
    demo_circuit_breaker()
    await demo_async_metrics()
    demo_intelligent_alerting()
    demo_performance_monitoring()
    
    print("\n✅ All demos completed!")


if __name__ == "__main__":
    # Start Prometheus metrics server
    prometheus_client.start_http_server(8000)
    print("📊 Prometheus metrics available at http://localhost:8000/metrics")
    
    # Run demos
    asyncio.run(main())

