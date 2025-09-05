# =============================================================================
# MULTI-CLOUD ELASTICSEARCH MODULE OUTPUTS
# =============================================================================

# AWS EKS Elasticsearch Outputs
output "aws_elasticsearch_deployment_name" {
  description = "Name of the AWS Elasticsearch deployment"
  value       = var.enable_aws_deployment ? kubernetes_deployment.elasticsearch_aws[0].metadata[0].name : null
}

output "aws_elasticsearch_service_name" {
  description = "Name of the AWS Elasticsearch service"
  value       = var.enable_aws_deployment ? kubernetes_service.elasticsearch_aws[0].metadata[0].name : null
}

output "aws_elasticsearch_endpoint" {
  description = "AWS Elasticsearch service endpoint"
  value       = var.enable_aws_deployment ? "${kubernetes_service.elasticsearch_aws[0].metadata[0].name}.${var.namespace}.svc.cluster.local:9200" : null
}

output "aws_elasticsearch_transport_endpoint" {
  description = "AWS Elasticsearch transport endpoint"
  value       = var.enable_aws_deployment ? "${kubernetes_service.elasticsearch_aws[0].metadata[0].name}.${var.namespace}.svc.cluster.local:9300" : null
}

# Azure AKS Elasticsearch Outputs
output "azure_elasticsearch_deployment_name" {
  description = "Name of the Azure Elasticsearch deployment"
  value       = var.enable_azure_deployment ? kubernetes_deployment.elasticsearch_azure[0].metadata[0].name : null
}

output "azure_elasticsearch_service_name" {
  description = "Name of the Azure Elasticsearch service"
  value       = var.enable_azure_deployment ? kubernetes_service.elasticsearch_azure[0].metadata[0].name : null
}

output "azure_elasticsearch_endpoint" {
  description = "Azure Elasticsearch service endpoint"
  value       = var.enable_azure_deployment ? "${kubernetes_service.elasticsearch_azure[0].metadata[0].name}.${var.namespace}.svc.cluster.local:9200" : null
}

output "azure_elasticsearch_transport_endpoint" {
  description = "Azure Elasticsearch transport endpoint"
  value       = var.enable_azure_deployment ? "${kubernetes_service.elasticsearch_azure[0].metadata[0].name}.${var.namespace}.svc.cluster.local:9300" : null
}

# Multi-Cloud Discovery Outputs
output "elasticsearch_discovery_config_map" {
  description = "Elasticsearch discovery configuration map"
  value       = (var.enable_aws_deployment && var.enable_azure_deployment) ? kubernetes_config_map.elasticsearch_discovery[0].metadata[0].name : null
}

output "all_elasticsearch_endpoints" {
  description = "All Elasticsearch endpoints across clouds"
  value = {
    aws = var.enable_aws_deployment ? [for svc in kubernetes_service.elasticsearch_aws : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9200"] : []
    azure = var.enable_azure_deployment ? [for svc in kubernetes_service.elasticsearch_azure : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9200"] : []
  }
}

output "all_elasticsearch_transport_endpoints" {
  description = "All Elasticsearch transport endpoints across clouds"
  value = {
    aws = var.enable_aws_deployment ? [for svc in kubernetes_service.elasticsearch_aws : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9300"] : []
    azure = var.enable_azure_deployment ? [for svc in kubernetes_service.elasticsearch_azure : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9300"] : []
  }
}

# Cluster Health Information
output "cluster_health_endpoints" {
  description = "Elasticsearch cluster health check endpoints"
  value = {
    aws = var.enable_aws_deployment ? "http://${kubernetes_service.elasticsearch_aws[0].metadata[0].name}.${var.namespace}.svc.cluster.local:9200/_cluster/health" : null
    azure = var.enable_azure_deployment ? "http://${kubernetes_service.elasticsearch_azure[0].metadata[0].name}.${var.namespace}.svc.cluster.local:9200/_cluster/health" : null
  }
}

# Deployment Status
output "deployment_status" {
  description = "Status of Elasticsearch deployments across clouds"
  value = {
    aws_enabled   = var.enable_aws_deployment
    azure_enabled = var.enable_azure_deployment
    total_replicas = (var.enable_aws_deployment ? var.elasticsearch_replicas : 0) + (var.enable_azure_deployment ? var.elasticsearch_replicas : 0)
    namespace     = var.namespace
    cluster_name  = var.cluster_name
  }
}

# Resource Information
output "resource_requirements" {
  description = "Resource requirements for Elasticsearch pods"
  value = {
    memory_request = var.elasticsearch_memory_request
    cpu_request    = var.elasticsearch_cpu_request
    memory_limit   = var.elasticsearch_memory_limit
    cpu_limit      = var.elasticsearch_cpu_limit
  }
}

# Configuration Summary
output "configuration_summary" {
  description = "Summary of Elasticsearch configuration"
  value = {
    image                    = var.elasticsearch_image
    version                  = var.elasticsearch_version
    java_opts                = var.elasticsearch_java_opts
    enable_security          = var.enable_security
    enable_monitoring        = var.enable_monitoring
    enable_persistent_storage = var.enable_persistent_storage
    service_type             = var.service_type
  }
}
