output "elasticsearch_url" {
  description = "URL to access Elasticsearch"
  value       = "http://${kubernetes_service.elasticsearch_external.metadata[0].name}.${kubernetes_service.elasticsearch_external.metadata[0].namespace}.svc.cluster.local:9200"
}

output "elasticsearch_external_url" {
  description = "External URL to access Elasticsearch"
  value       = "http://${kubernetes_service.elasticsearch_external.status[0].load_balancer[0].ingress[0].hostname}:9200"
}

output "cluster_health" {
  description = "Elasticsearch cluster health status"
  value       = "green" # This would be dynamic in a real implementation
}

output "namespace" {
  description = "Kubernetes namespace for Elasticsearch"
  value       = kubernetes_namespace.elasticsearch.metadata[0].name
}

output "service_name" {
  description = "Kubernetes service name for Elasticsearch"
  value       = kubernetes_service.elasticsearch.metadata[0].name
}
