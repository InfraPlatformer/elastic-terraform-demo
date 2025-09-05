# Production Environment Configuration
environment = "production"
cluster_name = "advanced-elastic-production-aws"

# EKS Configuration
cluster_version = "1.29"

# Override node groups for production (larger instances)
aws_node_groups = {
  elasticsearch = {
    instance_types = ["m5.large", "m5.xlarge"]
    capacity_type = "ON_DEMAND"
    desired_size = 5
    max_size = 10
    min_size = 3
    disk_size = 200
    labels = {
      role = "elasticsearch"
    }
    taints = [{
      key    = "dedicated"
      value  = "elasticsearch"
      effect = "NO_SCHEDULE"
    }]
  }
  monitoring = {
    instance_types = ["m5.large"]
    capacity_type = "ON_DEMAND"
    desired_size = 3
    max_size = 5
    min_size = 2
    disk_size = 100
    labels = {
      role = "monitoring"
    }
    taints = []
  }
}

# Elasticsearch Configuration
elasticsearch_replicas = 5
elasticsearch_resources = {
  limits = {
    cpu    = "8000m"
    memory = "16Gi"
  }
  requests = {
    cpu    = "4000m"
    memory = "8Gi"
  }
}

# Monitoring Configuration
enable_monitoring = true
enable_logging = true
enable_metrics = true

# Security Configuration
enable_security = true
enable_ssl = true

# Backup Configuration
enable_backup = true
backup_retention_days = 30

# Cost Optimization
enable_spot_instances = false
enable_auto_scaling = true
