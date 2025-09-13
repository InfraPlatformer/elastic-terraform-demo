# Azure Staging Environment
# This creates the Azure infrastructure for the Elastic Stack

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = var.tags
}

# Networking
module "azure_networking" {
  source = "../../modules/azure-networking"

  resource_group_name = azurerm_resource_group.main.name
  cluster_name        = var.cluster_name
  location            = var.location
  vnet_address_space  = var.vnet_address_space
  aks_subnet_cidr     = var.aks_subnet_cidr
  gateway_subnet_cidr = var.gateway_subnet_cidr
  enable_firewall     = var.enable_firewall

  tags = var.tags
}

# AKS Cluster
module "azure_aks" {
  source = "../../modules/azure-aks"

  resource_group_name      = azurerm_resource_group.main.name
  cluster_name             = var.cluster_name
  kubernetes_version       = var.kubernetes_version
  node_vm_size            = var.node_vm_size
  node_count              = var.node_count
  min_count               = var.min_count
  max_count               = var.max_count
  os_disk_size_gb         = var.os_disk_size_gb
  subnet_id               = module.azure_networking.aks_subnet_id
  gateway_subnet_id       = module.azure_networking.gateway_subnet_id
  service_cidr            = var.service_cidr
  dns_service_ip          = var.dns_service_ip
  admin_group_object_ids  = var.admin_group_object_ids

  tags = var.tags

  depends_on = [module.azure_networking]
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.azure_aks.kube_config_host
  client_certificate     = base64decode(module.azure_aks.kube_config_client_certificate)
  client_key            = base64decode(module.azure_aks.kube_config_client_key)
  cluster_ca_certificate = base64decode(module.azure_aks.kube_config_cluster_ca_certificate)
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.azure_aks.kube_config_host
    client_certificate     = base64decode(module.azure_aks.kube_config_client_certificate)
    client_key            = base64decode(module.azure_aks.kube_config_client_key)
    cluster_ca_certificate = base64decode(module.azure_aks.kube_config_cluster_ca_certificate)
  }
}

# Namespaces
resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      name = "elasticsearch"
    }
  }
}

resource "kubernetes_namespace" "kibana" {
  metadata {
    name = "kibana"
    labels = {
      name = "kibana"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
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
    }
  }

  spec {
    replicas = var.elasticsearch_replicas

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
          image = "docker.elastic.co/elasticsearch/elasticsearch:${var.elasticsearch_version}"

          port {
            container_port = 9200
            name          = "http"
          }

          port {
            container_port = 9300
            name          = "transport"
          }

          env {
            name  = "node.name"
            value = "elasticsearch"
          }

          env {
            name  = "cluster.name"
            value = "elasticsearch-cluster"
          }

          env {
            name  = "discovery.type"
            value = "single-node"
          }

          env {
            name  = "bootstrap.memory_lock"
            value = "true"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms${var.elasticsearch_heap_size} -Xmx${var.elasticsearch_heap_size}"
          }

          env {
            name  = "xpack.security.enabled"
            value = "false"
          }

          env {
            name  = "xpack.security.enrollment.enabled"
            value = "false"
          }

          resources {
            requests = {
              memory = var.elasticsearch_memory_requests
              cpu    = var.elasticsearch_cpu_requests
            }
            limits = {
              memory = var.elasticsearch_memory_limits
              cpu    = var.elasticsearch_cpu_limits
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

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
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
      name        = "http"
      port        = 9200
      target_port = 9200
      protocol    = "TCP"
    }

    port {
      name        = "transport"
      port        = 9300
      target_port = 9300
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Kibana Deployment
resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.kibana.metadata[0].name
    labels = {
      app = "kibana"
    }
  }

  spec {
    replicas = var.kibana_replicas

    selector {
      match_labels = {
        app = "kibana"
      }
    }

    template {
      metadata {
        labels = {
          app = "kibana"
        }
      }

      spec {
        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:${var.kibana_version}"

          port {
            container_port = 5601
            name          = "http"
          }

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

          resources {
            requests = {
              memory = var.kibana_memory_requests
              cpu    = var.kibana_cpu_requests
            }
            limits = {
              memory = var.kibana_memory_limits
              cpu    = var.kibana_cpu_limits
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
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
      name        = "http"
      port        = 5601
      target_port = 5601
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

# Grafana Deployment
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "grafana"
    }
  }

  spec {
    replicas = var.grafana_replicas

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:${var.grafana_version}"

          port {
            container_port = 3000
            name          = "http"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = var.grafana_admin_password
          }

          env {
            name  = "GF_INSTALL_PLUGINS"
            value = "grafana-kubernetes-app,grafana-elasticsearch-datasource"
          }

          resources {
            requests = {
              memory = var.grafana_memory_requests
              cpu    = var.grafana_cpu_requests
            }
            limits = {
              memory = var.grafana_memory_limits
              cpu    = var.grafana_cpu_limits
            }
          }

          volume_mount {
            name       = "grafana-storage"
            mount_path = "/var/lib/grafana"
          }
        }

        volume {
          name = "grafana-storage"
          empty_dir {}
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
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
      name        = "http"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
