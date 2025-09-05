# Development Environment Configuration
environment = "development"
cluster_name = "advanced-elastic-development-aws"

# EKS Configuration
cluster_version = "1.29"

# Override node groups for development (smaller instances)
aws_node_groups = {
  elasticsearch = {
    instance_types = ["t3.medium"]
    capacity_type = "ON_DEMAND"
    desired_size = 2
    max_size = 3
    min_size = 1
    disk_size = 50
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
    instance_types = ["t3.small"]
    capacity_type = "ON_DEMAND"
    desired_size = 1
    max_size = 2
    min_size = 1
    disk_size = 20
    labels = {
      role = "monitoring"
    }
    taints = []
  }
}

# Elasticsearch Configuration
elasticsearch_replicas = 1
elasticsearch_resources = {
  limits = {
    cpu    = "2000m"
    memory = "4Gi"
  }
  requests = {
    cpu    = "1000m"
    memory = "2Gi"
  }
}

# Monitoring Configuration
enable_monitoring = true
enable_logging = true
enable_metrics = true

# Security Configuration
enable_security = false
enable_ssl = false

# Backup Configuration
enable_backup = false
backup_retention_days = 7

# Cost Optimization
enable_spot_instances = false
enable_auto_scaling = true
