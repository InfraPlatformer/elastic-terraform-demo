# =============================================================================
# PRODUCTION MONITORING OUTPUTS
# =============================================================================

# Monitoring Dashboard URLs - Will be enabled after modules are configured
# output "monitoring_dashboard_urls" {
#   description = "URLs for monitoring dashboards"
#   value = {
#     grafana      = module.monitoring.grafana_url
#     prometheus   = module.monitoring.prometheus_url
#     alertmanager = module.monitoring.alertmanager_url
#     kibana       = module.kibana.kibana_internal_url
#   }
# }

# Infrastructure Health Checks
output "infrastructure_health_checks" {
  description = "Health check endpoints and commands"
  value = {
    cluster_health       = "aws eks describe-cluster --name ${module.aws_eks.cluster_name} --region ${var.aws_region}"
    nodegroup_health     = "aws eks list-nodegroups --cluster-name ${module.aws_eks.cluster_name} --region ${var.aws_region}"
    elasticsearch_health = "curl -X GET http://elasticsearch.elasticsearch.svc.cluster.local:9200/_cluster/health"
    kibana_health        = "curl -X GET http://kibana.kibana.svc.cluster.local:5601/api/status"
  }
}

# Security Information
output "security_info" {
  description = "Security configuration details"
  value = {
    # KMS keys temporarily disabled due to permission issues
    # kms_keys = {
    #   eks_encryption = module.aws_eks.eks_encryption_key_arn
    #   ebs_encryption = module.aws_eks.ebs_encryption_key_arn
    #   app_secrets = module.aws_eks.app_secrets_key_arn
    # }
    security_groups = {
      cluster       = module.aws_networking.eks_cluster_security_group_id
      nodes         = module.aws_networking.eks_nodes_security_group_id
      elasticsearch = module.aws_networking.elasticsearch_security_group_id
      kibana        = module.aws_networking.kibana_security_group_id
    }
  }
}

# Backup Configuration - Will be enabled after backup module is configured
# output "backup_info" {
#   description = "Backup and disaster recovery configuration"
#   value = {
#     s3_bucket = module.backup.backup_bucket_name
#     backup_schedule = "Daily at 2 AM UTC"
#     retention_policy = "7 years with lifecycle transitions"
#     encryption = "AES256 server-side encryption"
#   }
# }

# Performance Metrics
output "performance_metrics" {
  description = "Key performance indicators"
  value = {
    cluster_autoscaler   = "Enabled with 50% scale-down threshold"
    monitoring_retention = "30 days for Prometheus, 120 hours for Alertmanager"
    storage_class        = "gp2 with KMS encryption"
    node_scaling         = "Auto-scaling based on CPU/memory utilization"
  }
}
