# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION - AWS ONLY (SIMPLE)
# =============================================================================
# Simplified configuration for AWS-only deployment
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

# AWS Only Deployment
enable_aws_deployment = true
enable_azure_deployment = false

# Azure Configuration (disabled but required for module)
azure_subscription_id = ""
azure_tenant_id = ""
azure_client_id = ""
azure_client_secret = ""
azure_resource_group = "disabled"
azure_location = "disabled"

# Azure Node Pools (not used)
azure_node_pools = {}

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

# DEVELOPMENT ENVIRONMENT CONFIGURATION - AWS ONLY (SIMPLE)
# =============================================================================
# Simplified configuration for AWS-only deployment
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

# AWS Only Deployment
enable_aws_deployment = true
enable_azure_deployment = false

# Azure Configuration (disabled but required for module)
azure_subscription_id = ""
azure_tenant_id = ""
azure_client_id = ""
azure_client_secret = ""
azure_resource_group = "disabled"
azure_location = "disabled"

# Azure Node Pools (not used)
azure_node_pools = {}

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

