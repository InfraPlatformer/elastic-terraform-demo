output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${kubernetes_service.prometheus.metadata[0].name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:9090"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${kubernetes_service.grafana.metadata[0].name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:3000"
}

output "grafana_external_url" {
  description = "External URL to access Grafana"
  value       = kubernetes_service.grafana_external.status[0].load_balancer[0].ingress[0].hostname
}

output "alertmanager_url" {
  description = "URL to access AlertManager"
  value       = "http://${kubernetes_service.alertmanager.metadata[0].name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:9093"
}

output "dashboard_url" {
  description = "URL to access monitoring dashboards"
  value       = "http://${kubernetes_service.grafana_external.status[0].load_balancer[0].ingress[0].hostname}:3000"
}

output "monitoring_namespace" {
  description = "Namespace where monitoring tools are deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
} 