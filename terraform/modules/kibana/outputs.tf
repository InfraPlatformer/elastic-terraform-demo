output "kibana_url" {
  description = "URL to access Kibana"
  value       = "http://${kubernetes_service.kibana.metadata[0].name}.${kubernetes_namespace.kibana.metadata[0].name}.svc.cluster.local:5601"
}

output "kibana_external_url" {
  description = "External URL to access Kibana"
  value       = kubernetes_service.kibana_external.status[0].load_balancer[0].ingress[0].hostname
}

output "kibana_namespace" {
  description = "Namespace where Kibana is deployed"
  value       = kubernetes_namespace.kibana.metadata[0].name
}

output "kibana_service_name" {
  description = "Name of the Kibana service"
  value       = kubernetes_service.kibana.metadata[0].name
}

output "kibana_deployment_name" {
  description = "Name of the Kibana deployment"
  value       = kubernetes_deployment.kibana.metadata[0].name
}

output "kibana_config_map_name" {
  description = "Name of the Kibana ConfigMap"
  value       = kubernetes_config_map.kibana_config.metadata[0].name
}

output "kibana_secret_name" {
  description = "Name of the Kibana Secret"
  value       = kubernetes_secret.kibana_secret.metadata[0].name
} 