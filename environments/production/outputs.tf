# =============================================================================
# PRODUCTION ENVIRONMENT OUTPUTS
# =============================================================================
# Simplified outputs that match actual module outputs
# =============================================================================

# =============================================================================
# CLUSTER INFORMATION
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.aws_eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.aws_eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.aws_eks.cluster_endpoint
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aws_eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.aws_eks.cluster_version
}

# =============================================================================
# NETWORKING INFORMATION
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# =============================================================================
# BACKUP INFORMATION
# =============================================================================

output "backup_s3_bucket" {
  description = "S3 bucket for Elasticsearch backups"
  value       = var.enable_backup ? aws_s3_bucket.elasticsearch_backups[0].bucket : null
}

output "backup_s3_bucket_arn" {
  description = "ARN of the S3 bucket for Elasticsearch backups"
  value       = var.enable_backup ? aws_s3_bucket.elasticsearch_backups[0].arn : null
}

# output "backup_kms_key_arn" {
#   description = "ARN of the KMS key for backup encryption"
#   value       = var.enable_backup ? aws_kms_key.ebs.arn : null
# }

# =============================================================================
# SECURITY INFORMATION
# =============================================================================

# output "kms_key_arn" {
#   description = "ARN of the KMS key for cluster encryption"
#   value       = aws_kms_key.eks.arn
# }

# output "kms_key_id" {
#   description = "ID of the KMS key for cluster encryption"
#   value       = aws_kms_key.eks.key_id
# }

# =============================================================================
# NODE GROUP INFORMATION
# =============================================================================

output "node_groups" {
  description = "Information about the EKS node groups"
  value       = module.aws_eks.node_groups
}

# =============================================================================
# CLOUDWATCH LOG GROUPS
# =============================================================================

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for the cluster"
  value = {
    cluster_logs     = aws_cloudwatch_log_group.eks_cluster.name
    application_logs = aws_cloudwatch_log_group.application_logs.name
  }
}

# =============================================================================
# ACCESS COMMANDS
# =============================================================================

output "kubectl_config_command" {
  description = "Command to configure kubectl for the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.aws_eks.cluster_name}"
}

output "elasticsearch_port_forward_command" {
  description = "Command to port forward Elasticsearch"
  value       = "kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200"
}

output "kibana_port_forward_command" {
  description = "Command to port forward Kibana"
  value       = "kubectl port-forward -n kibana svc/kibana 5601:5601"
}

output "grafana_port_forward_command" {
  description = "Command to port forward Grafana"
  value       = "kubectl port-forward -n monitoring svc/grafana 3000:3000"
}

output "prometheus_port_forward_command" {
  description = "Command to port forward Prometheus"
  value       = "kubectl port-forward -n monitoring svc/prometheus 9090:9090"
}

# =============================================================================
# PRODUCTION HEALTH CHECK COMMANDS
# =============================================================================

output "health_check_commands" {
  description = "Commands to check production environment health"
  value = {
    cluster_status = "kubectl get nodes"
    elasticsearch_health = "kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s localhost:9200/_cluster/health"
    kibana_status = "kubectl get pods -n kibana"
    monitoring_status = "kubectl get pods -n monitoring"
    backup_status = "kubectl get cronjobs -n elasticsearch"
  }
}

# =============================================================================
# PRODUCTION ALERTING INFORMATION
# =============================================================================

output "alerting_configuration" {
  description = "Production alerting configuration details"
  value = {
    slack_channel = var.production_slack_channel
    contact_email = var.production_contact
    pagerduty_configured = var.production_pagerduty_key != "" ? true : false
    alert_rules_count = length(var.alert_rules)
  }
  sensitive = true
}

# =============================================================================
# COST OPTIMIZATION INFORMATION
# =============================================================================

output "cost_optimization" {
  description = "Cost optimization settings"
  value = {
    spot_instances_enabled = var.enable_spot_instances
    auto_scaling_enabled = var.enable_auto_scaling
    backup_retention_days = var.backup_retention_days
    monitoring_enabled = var.enable_monitoring
  }
}

# =============================================================================
# COMPLIANCE INFORMATION
# =============================================================================

output "compliance_status" {
  description = "Compliance and security status"
  value = {
    encryption_enabled = var.enable_security
    ssl_enabled = var.enable_ssl
    backup_enabled = var.enable_backup
    monitoring_enabled = var.enable_monitoring
    cloudtrail_enabled = var.enable_cloudtrail
    config_enabled = var.enable_config
    guardduty_enabled = var.enable_guardduty
    security_hub_enabled = var.enable_security_hub
  }
}

# =============================================================================
# DISASTER RECOVERY INFORMATION
# =============================================================================

output "disaster_recovery" {
  description = "Disaster recovery configuration"
  value = {
    cross_region_replication = var.enable_cross_region_replication
    dr_region = var.disaster_recovery_region
    backup_region = var.aws_region
    backup_retention_days = var.backup_retention_days
  }
}

# =============================================================================
# PRODUCTION DEPLOYMENT INFORMATION
# =============================================================================

output "deployment_info" {
  description = "Production deployment information"
  value = {
    environment = var.environment
    region = var.aws_region
    cluster_name = module.aws_eks.cluster_name
    deployment_date = timestamp()
    kubernetes_version = module.aws_eks.cluster_version
    elasticsearch_version = "8.5+"
    kibana_version = "8.5+"
  }
}