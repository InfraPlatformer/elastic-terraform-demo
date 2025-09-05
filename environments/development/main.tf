# =============================================================================
# DEVELOPMENT ENVIRONMENT MAIN CONFIGURATION
# =============================================================================
# Multi-cloud configuration for development - AWS + Azure
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}
  
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

# Configure Kubernetes Provider - AWS EKS
provider "kubernetes" {
  alias = "aws"
  
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.aws_eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

# Configure Kubernetes Provider - Azure AKS
provider "kubernetes" {
  alias = "azure"
  
  host                   = azurerm_kubernetes_cluster.main[0].kube_config[0].host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "az"
    args = [
      "aks",
      "get-credentials",
      "--resource-group",
      azurerm_resource_group.aks[0].name,
      "--name",
      azurerm_kubernetes_cluster.main[0].name,
      "--overwrite-existing"
    ]
  }
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# EKS Cluster Auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_eks.cluster_name
}

# Locals for standardized configuration
locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  # Standardized tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    Purpose     = "elastic-stack"
    CreatedAt   = timestamp()
    Version     = "1.0.0"
  }
}

# Networking Infrastructure
module "aws_networking" {
  source = "../../modules/networking"

  vpc_cidr           = var.aws_vpc_cidr
  environment        = var.environment
  availability_zones = local.availability_zones
  tags               = local.common_tags
}

# EKS Cluster
module "aws_eks" {
  source = "../../modules/eks"

  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  subnet_ids                = module.aws_networking.private_subnets
  cluster_security_group_id = module.aws_networking.eks_cluster_security_group_id
  nodes_security_group_id   = module.aws_networking.eks_nodes_security_group_id
  enable_public_access      = var.enable_public_access
  allowed_cidr_blocks       = var.allowed_cidr_blocks
  environment               = var.environment
  tags                      = local.common_tags

  # Node groups configuration
  node_groups = var.aws_node_groups

  # Storage configuration
  enable_ebs_csi_driver  = var.enable_ebs_csi_driver
  ebs_csi_driver_version = var.ebs_csi_driver_version
}

# Azure Resource Group
resource "azurerm_resource_group" "aks" {
  count = var.enable_azure_deployment ? 1 : 0
  
  name     = var.azure_resource_group
  location = var.azure_location

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.cluster_name}-azure-rg"
    Type = "AKS Resource Group"
  })
}

# Azure AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  count = var.enable_azure_deployment ? 1 : 0
  
  name                = "${var.cluster_name}-azure"
  location            = azurerm_resource_group.aks[0].location
  resource_group_name = azurerm_resource_group.aks[0].name
  dns_prefix          = "${var.cluster_name}-azure"
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_D2s_v3"
    os_disk_size_gb     = 100
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    type                = "VirtualMachineScaleSets"
    node_labels = {
      role = "default"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.cluster_name}-azure"
    Type = "AKS Cluster"
  })
}

# AWS Elasticsearch Deployment
resource "kubernetes_namespace" "elasticsearch_aws" {
  count = var.enable_aws_deployment ? 1 : 0
  
  provider = kubernetes.aws
  
  metadata {
    name = "elasticsearch"
    labels = {
      name = "elasticsearch"
    }
  }
}

resource "kubernetes_deployment" "elasticsearch_aws" {
  count = var.enable_aws_deployment ? 1 : 0
  
  provider = kubernetes.aws
  
  metadata {
    name      = "elasticsearch-aws"
    namespace = kubernetes_namespace.elasticsearch_aws[0].metadata[0].name
    labels = {
      app = "elasticsearch"
      cloud = "aws"
    }
  }

  spec {
    replicas = var.elasticsearch_replicas

    selector {
      match_labels = {
        app = "elasticsearch"
        cloud = "aws"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
          cloud = "aws"
        }
      }

      spec {
        container {
          name  = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:8.11.0"

          env {
            name  = "discovery.type"
            value = "single-node"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms1g -Xmx1g"
          }

          env {
            name  = "xpack.security.enabled"
            value = "false"
          }

          port {
            container_port = 9200
            name          = "http"
          }

          port {
            container_port = 9300
            name          = "transport"
          }

          resources {
            requests = {
              memory = "1Gi"
              cpu    = "500m"
            }
            limits = {
              memory = "2Gi"
              cpu    = "1000m"
            }
          }

          volume_mount {
            name       = "elasticsearch-data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }

        volume {
          name = "elasticsearch-data"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [module.aws_eks]
}

resource "kubernetes_service" "elasticsearch_aws" {
  count = var.enable_aws_deployment ? 1 : 0
  
  provider = kubernetes.aws
  
  metadata {
    name      = "elasticsearch-aws"
    namespace = kubernetes_namespace.elasticsearch_aws[0].metadata[0].name
    labels = {
      app = "elasticsearch"
      cloud = "aws"
    }
  }

  spec {
    selector = {
      app = "elasticsearch"
      cloud = "aws"
    }

    port {
      port        = 9200
      target_port = 9200
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.elasticsearch_aws]
}

# Azure Elasticsearch Deployment
resource "kubernetes_namespace" "elasticsearch_azure" {
  count = var.enable_azure_deployment ? 1 : 0
  
  provider = kubernetes.azure
  
  metadata {
    name = "elasticsearch"
    labels = {
      name = "elasticsearch"
    }
  }
}

resource "kubernetes_deployment" "elasticsearch_azure" {
  count = var.enable_azure_deployment ? 1 : 0
  
  provider = kubernetes.azure
  
  metadata {
    name      = "elasticsearch-azure"
    namespace = kubernetes_namespace.elasticsearch_azure[0].metadata[0].name
    labels = {
      app = "elasticsearch"
      cloud = "azure"
    }
  }

  spec {
    replicas = var.elasticsearch_replicas

    selector {
      match_labels = {
        app = "elasticsearch"
        cloud = "azure"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
          cloud = "azure"
        }
      }

      spec {
        container {
          name  = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:8.11.0"

          env {
            name  = "discovery.type"
            value = "single-node"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms1g -Xmx1g"
          }

          env {
            name  = "xpack.security.enabled"
            value = "false"
          }

          port {
            container_port = 9200
            name          = "http"
          }

          port {
            container_port = 9300
            name          = "transport"
          }

          resources {
            requests = {
              memory = "1Gi"
              cpu    = "500m"
            }
            limits = {
              memory = "2Gi"
              cpu    = "1000m"
            }
          }

          volume_mount {
            name       = "elasticsearch-data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }

        volume {
          name = "elasticsearch-data"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [azurerm_kubernetes_cluster.main]
}

resource "kubernetes_service" "elasticsearch_azure" {
  count = var.enable_azure_deployment ? 1 : 0
  
  provider = kubernetes.azure
  
  metadata {
    name      = "elasticsearch-azure"
    namespace = kubernetes_namespace.elasticsearch_azure[0].metadata[0].name
    labels = {
      app = "elasticsearch"
      cloud = "azure"
    }
  }

  spec {
    selector = {
      app = "elasticsearch"
      cloud = "azure"
    }

    port {
      port        = 9200
      target_port = 9200
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.elasticsearch_azure]
}