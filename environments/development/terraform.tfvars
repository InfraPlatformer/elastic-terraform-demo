# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# =============================================================================
# Updated to match main variables.tf definitions
# =============================================================================

# Global Configuration
environment = "development"
project_name = "advanced-elastic"
owner = "devops-team"
cluster_name = "advanced-elastic-development-aws"

# Kubernetes Configuration
kubernetes_version = "1.29"
cluster_version = "1.29"

# AWS Configuration
aws_region = "us-west-2"
aws_vpc_cidr = "10.0.0.0/16"

# AWS Node Groups (optimized for development)
aws_node_groups = {
  elasticsearch = {
    instance_types = ["t3.medium"]
    capacity_type = "ON_DEMAND"
    min_size = 1
    max_size = 3
    desired_size = 2
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
    min_size = 1
    max_size = 2
    desired_size = 1
    disk_size = 20
    labels = {
      role = "monitoring"
    }
    taints = []
  }
}

# Elasticsearch Configuration
elasticsearch_heap_size = "2g"
elasticsearch_data_nodes = 2
elasticsearch_master_nodes = 1
elasticsearch_ingest_nodes = 1

# Kibana Configuration
kibana_replicas = 1

# Storage Configuration
enable_ebs_csi_driver = true
ebs_csi_driver_version = "v2.20.0"

# Networking & Access
enable_public_access = true
allowed_cidr_blocks = ["0.0.0.0/0"]
enable_vpc_endpoints = true

# Multi-Cloud Deployment (Both AWS and Azure for development)
enable_aws_deployment = true
enable_azure_deployment = true

# Azure Configuration (required for multi-cloud deployment)
azure_subscription_id = "your-azure-subscription-id"
azure_tenant_id = "your-azure-tenant-id"
azure_client_id = "your-azure-client-id"
azure_client_secret = "your-azure-client-secret"
azure_resource_group = "multi-cloud-elastic-rg"
azure_location = "West US 2"

# Azure Node Pools (not used in development)
azure_node_pools = {
  elasticsearch = {
    vm_size = "Standard_D2s_v3"
    os_disk_size_gb = 100
    count = 2
    enable_auto_scaling = true
    min_count = 1
    max_count = 5
    node_labels = {
      role = "elasticsearch"
    }
    node_taints = []
  }
  monitoring = {
    vm_size = "Standard_D2s_v3"
    os_disk_size_gb = 50
    count = 1
    enable_auto_scaling = true
    min_count = 1
    max_count = 3
    node_labels = {
      role = "monitoring"
    }
    node_taints = []
  }
}

# SSH Access
ssh_key_name = ""

# Grafana Configuration
grafana_admin_password = "admin123"

# Common Tags
common_tags = {
  Project     = "advanced-elastic"
  Environment = "development"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
  Purpose     = "elastic-stack"
  CostCenter  = "engineering"
}
