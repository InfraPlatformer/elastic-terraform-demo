# Staging Environment Outputs

# EKS Cluster Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.cluster_oidc_provider_arn
}

# Node Group Outputs
output "node_groups" {
  description = "Map of EKS node groups"
  value       = module.eks.node_groups
}



# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.networking.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.networking.public_subnets
}

# Elasticsearch Outputs (to be added after manual deployment)
output "elasticsearch_service_name" {
  description = "Name of the Elasticsearch service"
  value       = "elasticsearch"
}

output "elasticsearch_service_endpoint" {
  description = "Endpoint of the Elasticsearch service"
  value       = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
}

output "elasticsearch_cluster_health" {
  description = "Health status of the Elasticsearch cluster"
  value       = "To be checked after deployment"
}



# Connection Information
output "kubectl_config" {
  description = "Kubectl configuration for connecting to the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

output "elasticsearch_connection_info" {
  description = "Information for connecting to Elasticsearch"
  value = {
    internal_endpoint = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
    external_endpoint = "To be configured after deployment"
    port     = 9200
    protocol = var.enable_ssl ? "https" : "http"
  }
}
