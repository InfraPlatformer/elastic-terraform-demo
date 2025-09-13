# Development Environment - Main Configuration
# Copy of staging configuration for development

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Use the same modules as staging
module "aws_eks" {
  source = "../../modules/eks"
  
  cluster_name    = "elastic-stack-dev"
  cluster_version = var.cluster_version
  vpc_id          = module.aws_networking.vpc_id
  subnet_ids      = module.aws_networking.private_subnet_ids
  
  node_groups = var.aws_node_groups
  
  tags = {
    Environment = "development"
    Project     = "elastic-stack"
    ManagedBy   = "terraform"
  }
}

module "aws_networking" {
  source = "../../modules/aws-networking"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  cluster_name         = "elastic-stack-dev"
  
  tags = {
    Environment = "development"
    Project     = "elastic-stack"
    ManagedBy   = "terraform"
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.aws_eks.cluster_name]
  }
}

# Elasticsearch deployment
resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
}

resource "kubernetes_deployment" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
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
        }
      }
      
      spec {
        container {
          name  = "elasticsearch"
          image = "elasticsearch:8.11.0"
          
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          
          env {
            name  = "xpack.security.enabled"
            value = "false"
          }
          
          port {
            container_port = 9200
          }
          
          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }
  
  spec {
    selector = {
      app = "elasticsearch"
    }
    
    port {
      port        = 9200
      target_port = 9200
    }
  }
}