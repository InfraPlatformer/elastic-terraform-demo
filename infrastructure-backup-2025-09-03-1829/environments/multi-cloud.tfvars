# =============================================================================
# MULTI-CLOUD ENVIRONMENT CONFIGURATION
# =============================================================================

# Environment Configuration
environment = "development"
project_name = "multi-cloud-elasticsearch"
owner = "DevOps Team"

# AWS Configuration
aws_region = "us-west-2"
aws_vpc_cidr = "10.0.0.0/16"
cluster_name = "multi-cloud-elastic"
cluster_version = "1.29"

# AWS Node Groups
aws_node_groups = {
  elasticsearch = {
    instance_types = ["t3.medium", "t3.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 5
    desired_size   = 3
    disk_size      = 100
    labels = {
      role = "elasticsearch"
    }
    taints = [{
      key    = "dedicated"
      value  = "elasticsearch"
      effect = "NoSchedule"
    }]
  }
  
  kibana = {
    instance_types = ["t3.small", "t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size       = 1
    max_size       = 3
    desired_size   = 2
    disk_size      = 50
    labels = {
      role = "kibana"
    }
    taints = []
  }
  
  monitoring = {
    instance_types = ["t3.small"]
    capacity_type  = "ON_DEMAND"
    min_size       = 1
    max_size       = 2
    desired_size   = 1
    disk_size      = 50
    labels = {
      role = "monitoring"
    }
    taints = []
  }
}

# AWS Storage Configuration
enable_ebs_csi_driver = true
ebs_csi_driver_version = "v2.20.0"

# Network Configuration
enable_public_access = false
allowed_cidr_blocks = ["10.0.0.0/16", "172.16.0.0/12"]

# Azure Configuration
azure_subscription_id = "f0d02754-d8ca-4e7d-b010-ebac7cd463da"
azure_tenant_id = "g9383228gmail.onmicrosoft.com"
azure_client_id = "YOUR_CLIENT_ID_FROM_SERVICE_PRINCIPAL"
azure_client_secret = "YOUR_CLIENT_SECRET_FROM_SERVICE_PRINCIPAL"
azure_resource_group = "multi-cloud-elastic-rg"
azure_location = "West US 2"

# Azure Node Pools
azure_node_pools = {
  elasticsearch = {
    vm_size             = "Standard_D2s_v3"
    os_disk_size_gb     = 100
    count               = 3
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 6
    node_labels = {
      role = "elasticsearch"
    }
    node_taints = [{
      key    = "dedicated"
      value  = "elasticsearch"
      effect = "NoSchedule"
    }]
  }

  kibana = {
    vm_size             = "Standard_D1s_v3"
    os_disk_size_gb     = 50
    count               = 2
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 4
    node_labels = {
      role = "kibana"
    }
    node_taints = [{
      key    = "dedicated"
      value  = "kibana"
      effect = "NoSchedule"
    }]
  }

  monitoring = {
    vm_size             = "Standard_D1s_v3"
    os_disk_size_gb     = 50
    count               = 1
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    node_labels = {
      role = "monitoring"
    }
    node_taints = []
  }
}

# Azure Storage Configuration
azure_backup_storage = "multicloudelasticbackup"

# Elasticsearch Configuration
elasticsearch_version = "8.11.0"
elasticsearch_replicas = 3
elasticsearch_memory_request = "2Gi"
elasticsearch_cpu_request = "1000m"
elasticsearch_memory_limit = "4Gi"
elasticsearch_cpu_limit = "2000m"

# Monitoring Configuration
enable_monitoring = true
enable_alerting = true
enable_logging = true
grafana_admin_password = "ChangeMe123!"

# Security Configuration
enable_security = true
enable_encryption = true

# Backup Configuration
enable_backup = true
backup_retention_days = 30
backup_schedule = "0 2 * * *"  # Daily at 2 AM

# Tags
tags = {
  Environment = "development"
  Project     = "multi-cloud-elasticsearch"
  ManagedBy   = "terraform"
  Owner       = "DevOps Team"
  Purpose     = "elastic-stack"
  CostCenter  = "dev-elastic"
  Backup      = "daily"
}
