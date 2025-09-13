# Staging Environment Configuration
environment = "staging"
cluster_name = "elasticsearch-cluster-staging"

# EKS Configuration
cluster_version = "1.29"
aws_node_groups = {
  elasticsearch = {
    instance_types = ["t3.large"]
    capacity_type = "ON_DEMAND"
    desired_size = 3
    max_size = 5
    min_size = 2
    disk_size = 100
    labels = {
      role = "elasticsearch"
    }
    taints = []  # No taints to allow system pods like CoreDNS
  }
}

# Elasticsearch Configuration
elasticsearch_replicas = 3
elasticsearch_resources = {
  limits = {
    cpu    = "4000m"
    memory = "8Gi"
  }
  requests = {
    cpu    = "2000m"
    memory = "4Gi"
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
backup_retention_days = 14

# Cost Optimization
enable_spot_instances = false
enable_auto_scaling = true
