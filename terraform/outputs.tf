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

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# Elasticsearch Outputs
output "elasticsearch_url" {
  description = "URL to access Elasticsearch"
  value       = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
}

output "elasticsearch_external_url" {
  description = "External URL to access Elasticsearch (if ingress enabled)"
  value       = var.enable_ingress ? "http://elasticsearch.${var.cluster_name}.local" : "N/A"
}

# Kibana Outputs
output "kibana_url" {
  description = "Internal URL to access Kibana"
  value       = "http://kibana.kibana.svc.cluster.local:5601"
}

output "kibana_external_url" {
  description = "External URL to access Kibana (if ingress enabled)"
  value       = var.enable_ingress ? "http://kibana.${var.cluster_name}.local" : "N/A"
}

output "kibana_alb_url" {
  description = "Application Load Balancer URL for Kibana"
  value       = aws_lb.kibana.dns_name
}

output "kibana_username" {
  description = "Username for Kibana access"
  value       = "elastic"
}

output "kibana_password" {
  description = "Password for Kibana access"
  value       = var.kibana_password
  sensitive   = true
}

# Monitoring Outputs
output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = var.enable_monitoring ? "http://prometheus.monitoring.svc.cluster.local:9090" : "N/A"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = var.enable_monitoring ? "http://grafana.monitoring.svc.cluster.local:3000" : "N/A"
}

output "grafana_external_url" {
  description = "External URL to access Grafana (if ingress enabled)"
  value       = var.enable_ingress && var.enable_monitoring ? "http://grafana.${var.cluster_name}.local" : "N/A"
}

output "alertmanager_url" {
  description = "URL to access AlertManager"
  value       = var.enable_monitoring ? "http://alertmanager.monitoring.svc.cluster.local:9093" : "N/A"
}

# Backup Outputs
output "backup_enabled" {
  description = "Whether automated backups are enabled"
  value       = var.enable_backup
}

output "backup_s3_bucket" {
  description = "S3 bucket name for Elasticsearch backups"
  value       = var.enable_backup ? aws_s3_bucket.elasticsearch_backups[0].bucket : "N/A"
}

output "backup_retention_days" {
  description = "Number of days to retain backups"
  value       = var.backup_retention_days
}

# Security Group Outputs
output "security_groups" {
  description = "Security group IDs"
  value = {
    kibana_alb = aws_security_group.kibana_alb.id
  }
}

# Cost Estimation
output "estimated_monthly_cost" {
  description = "Estimated monthly cost for the infrastructure"
  value = {
    eks_cluster = "~$150-300/month"
    elasticsearch_nodes = "~$200-400/month"
    kibana_nodes = "~$50-100/month"
    load_balancer = "~$20-50/month"
    storage = "~$50-100/month"
    monitoring = var.enable_monitoring ? "~$30-60/month" : "N/A"
    total = var.enable_monitoring ? "~$500-1010/month" : "~$470-950/month"
  }
}

# TLS Configuration
output "tls_enabled" {
  description = "Whether TLS encryption is enabled"
  value       = var.enable_tls
}

# Monitoring Configuration
output "monitoring_enabled" {
  description = "Whether monitoring and alerting is enabled"
  value       = var.enable_monitoring
} 