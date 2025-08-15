# Cluster Information
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

# VPC Information
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# Elasticsearch Information
output "elasticsearch_url" {
  description = "Elasticsearch internal URL"
  value       = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
}

output "elasticsearch_external_url" {
  description = "Elasticsearch external URL (if available)"
  value       = "N/A"
}

# Kibana Information
output "kibana_url" {
  description = "Kibana internal URL"
  value       = "http://kibana.kibana.svc.cluster.local:5601"
}

output "kibana_external_url" {
  description = "Kibana external URL (if available)"
  value       = "N/A"
}

output "kibana_username" {
  description = "Kibana username"
  value       = "elastic"
}

output "kibana_password" {
  description = "Kibana password"
  value       = var.elastic_password
  sensitive   = true
}

# S3 Backup Information
output "backup_enabled" {
  description = "Whether Elasticsearch backup is enabled"
  value       = var.backup_enabled
}

output "backup_s3_bucket" {
  description = "S3 bucket for Elasticsearch backups"
  value       = var.backup_enabled ? aws_s3_bucket.elasticsearch_backups[0].bucket : "N/A"
}

output "backup_retention_days" {
  description = "Backup retention period in days"
  value       = var.backup_retention_days
}

# Cost Estimation
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    eks_cluster         = "~$150-300/month"
    elasticsearch_nodes = "~$200-400/month"
    kibana_nodes        = "~$50-100/month"
    load_balancer       = "~$20-50/month"
    storage             = "~$50-100/month"
    total               = "~$470-950/month"
  }
} 