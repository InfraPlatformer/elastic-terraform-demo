# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION - AWS + AZURE (FIXED)
# =============================================================================
# Fixed configuration with compatible Kubernetes versions
# =============================================================================

# Global Configuration
environment = "development"
project_name = "advanced-elastic"
owner = "devops-team"
cluster_name = "advanced-elastic-development-aws"

# Kubernetes Configuration (Fixed versions)
kubernetes_version = "1.30"  # Supported in both AWS and Azure
cluster_version = "1.30"

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

# Multi-Cloud Deployment (Both AWS and Azure)
enable_aws_deployment = true
enable_azure_deployment = true

# Azure Configuration (CLI Authentication)
azure_subscription_id = "f0d02754-d8ca-4e7d-b010-ebac7cd463da"
azure_tenant_id = "g9383228gmail.onmicrosoft.com"
azure_client_id = ""  # Not needed for CLI auth
azure_client_secret = ""  # Not needed for CLI auth
azure_resource_group = "multi-cloud-elastic-rg"
azure_location = "West US 2"

# Azure Node Pools
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

# =============================================================================
# Fixed configuration with compatible Kubernetes versions
# =============================================================================

# Global Configuration
environment = "development"
project_name = "advanced-elastic"
owner = "devops-team"
cluster_name = "advanced-elastic-development-aws"

# Kubernetes Configuration (Fixed versions)
kubernetes_version = "1.30"  # Supported in both AWS and Azure
cluster_version = "1.30"

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

# Multi-Cloud Deployment (Both AWS and Azure)
enable_aws_deployment = true
enable_azure_deployment = true

# Azure Configuration (CLI Authentication)
azure_subscription_id = "f0d02754-d8ca-4e7d-b010-ebac7cd463da"
azure_tenant_id = "g9383228gmail.onmicrosoft.com"
azure_client_id = ""  # Not needed for CLI auth
azure_client_secret = ""  # Not needed for CLI auth
azure_resource_group = "multi-cloud-elastic-rg"
azure_location = "West US 2"

# Azure Node Pools
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
