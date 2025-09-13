# =============================================================================
# STAGING ENVIRONMENT - ELASTICSEARCH FOCUSED CONFIGURATION
# =============================================================================
# Multi-cloud Elasticsearch staging environment - AWS + Azure
# Primary focus: Elasticsearch search engine and data processing
# Supporting tools: Kibana (UI), Grafana (monitoring)
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
      Purpose     = "elasticsearch-staging"
      Primary     = "elasticsearch"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}
}

# Configure Kubernetes Provider - AWS EKS
provider "kubernetes" {
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

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# AWS NETWORKING MODULE
# =============================================================================

module "aws_networking" {
  source = "../../modules/networking"

  environment = var.environment
  vpc_cidr = var.aws_vpc_cidr
  
  # Multi-AZ configuration for high availability
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  
  # VPC endpoints for staging
  enable_vpc_endpoints = var.enable_vpc_endpoints
  
  tags = var.common_tags
}

# =============================================================================
# AWS EKS CLUSTER MODULE
# =============================================================================

module "aws_eks" {
  source = "../../modules/eks"

  cluster_name = var.aws_cluster_name
  cluster_version = var.cluster_version
  environment = var.environment

  # VPC Configuration
  subnet_ids = module.aws_networking.private_subnets
  cluster_security_group_id = module.aws_networking.eks_cluster_security_group_id
  nodes_security_group_id = module.aws_networking.eks_nodes_security_group_id

  # Staging node groups - optimized for Elasticsearch
  node_groups = var.aws_node_groups

  # Security configuration
  enable_public_access = var.enable_public_access
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  # EBS CSI Driver
  enable_ebs_csi_driver = var.enable_ebs_csi_driver
  ebs_csi_driver_version = var.ebs_csi_driver_version

  tags = var.common_tags
}

# =============================================================================
# ELASTICSEARCH DEPLOYMENT - PRIMARY FOCUS
# =============================================================================

# Elasticsearch Namespace
resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      name = "elasticsearch"
      purpose = "primary-search-engine"
    }
  }
}

# Elasticsearch Deployment
resource "kubernetes_deployment" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
    labels = {
      app = "elasticsearch"
      tier = "primary"
      purpose = "search-engine"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
          tier = "primary"
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
            value = "-Xms2g -Xmx2g"
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
              cpu    = "1000m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "2000m"
              memory = "4Gi"
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

# Elasticsearch Service
resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
    labels = {
      app = "elasticsearch"
    }
  }

  spec {
    selector = {
      app = "elasticsearch"
    }

    port {
      port        = 9200
      target_port = 9200
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.elasticsearch]
}

# =============================================================================
# KIBANA DEPLOYMENT - ELASTICSEARCH UI
# =============================================================================

# Kibana Namespace
resource "kubernetes_namespace" "kibana" {
  metadata {
    name = "kibana"
    labels = {
      name = "kibana"
      purpose = "elasticsearch-ui"
    }
  }
}

# Kibana Deployment
resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.kibana.metadata[0].name
    labels = {
      app = "kibana"
      tier = "ui"
      purpose = "elasticsearch-ui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kibana"
      }
    }

    template {
      metadata {
        labels = {
          app = "kibana"
          tier = "ui"
        }
      }

      spec {
        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:8.11.0"

          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
          }

          env {
            name  = "SERVER_NAME"
            value = "kibana"
          }

          env {
            name  = "SERVER_HOST"
            value = "0.0.0.0"
          }

          port {
            container_port = 5601
            name          = "http"
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.elasticsearch]
}

# Kibana Service
resource "kubernetes_service" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.kibana.metadata[0].name
    labels = {
      app = "kibana"
    }
  }

  spec {
    selector = {
      app = "kibana"
    }

    port {
      port        = 5601
      target_port = 5601
      name        = "http"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.kibana]
}

# =============================================================================
# GRAFANA DEPLOYMENT - SUPPORTING MONITORING TOOL
# =============================================================================

# Monitoring Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
      purpose = "supporting-tool"
    }
  }
}

# Grafana Deployment
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "grafana"
      tier = "monitoring"
      purpose = "supporting-tool"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
          tier = "monitoring"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "admin123"
          }

          port {
            container_port = 3000
            name          = "http"
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.elasticsearch]
}

# Grafana Service
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "grafana"
    }
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      port        = 3000
      target_port = 3000
      name        = "http"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.grafana]
}
