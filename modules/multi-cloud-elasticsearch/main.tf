# =============================================================================
# MULTI-CLOUD ELASTICSEARCH MODULE
# =============================================================================

# AWS EKS Elasticsearch Deployment
resource "kubernetes_deployment" "elasticsearch_aws" {
  count = var.enable_aws_deployment ? 1 : 0
  
  metadata {
    name      = "${var.cluster_name}-elasticsearch-aws"
    namespace = var.namespace
    labels = {
      app       = "elasticsearch"
      cloud     = "aws"
      cluster   = var.cluster_name
      component = "elasticsearch"
    }
  }

  spec {
    replicas = var.elasticsearch_replicas

    selector {
      match_labels = {
        app       = "elasticsearch"
        cloud     = "aws"
        component = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app       = "elasticsearch"
          cloud     = "aws"
          component = "elasticsearch"
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["elasticsearch"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        container {
          name  = "elasticsearch"
          image = "${var.elasticsearch_image}:${var.elasticsearch_version}"

          env {
            name  = "cluster.name"
            value = var.cluster_name
          }

          env {
            name  = "node.name"
            value = "elasticsearch-aws-$(POD_NAME)"
          }

          env {
            name  = "discovery.seed_hosts"
            value = var.elasticsearch_seed_hosts
          }

          env {
            name  = "cluster.initial_master_nodes"
            value = var.elasticsearch_initial_master_nodes
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = var.elasticsearch_java_opts
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          ports {
            container_port = 9200
            name          = "http"
          }

          ports {
            container_port = 9300
            name          = "transport"
          }

          resources {
            requests = {
              memory = var.elasticsearch_memory_request
              cpu    = var.elasticsearch_cpu_request
            }
            limits = {
              memory = var.elasticsearch_memory_limit
              cpu    = var.elasticsearch_cpu_limit
            }
          }

          volume_mount {
            name       = "elasticsearch-data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          liveness_probe {
            http_get {
              path = "/_cluster/health"
              port = 9200
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/_cluster/health"
              port = 9200
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }

        volume {
          name = "elasticsearch-data"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [var.aws_eks_cluster]
}

# Azure AKS Elasticsearch Deployment
resource "kubernetes_deployment" "elasticsearch_azure" {
  count = var.enable_azure_deployment ? 1 : 0
  
  provider = kubernetes.azure

  metadata {
    name      = "${var.cluster_name}-elasticsearch-azure"
    namespace = var.namespace
    labels = {
      app       = "elasticsearch"
      cloud     = "azure"
      cluster   = var.cluster_name
      component = "elasticsearch"
    }
  }

  spec {
    replicas = var.elasticsearch_replicas

    selector {
      match_labels = {
        app       = "elasticsearch"
        cloud     = "azure"
        component = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app       = "elasticsearch"
          cloud     = "azure"
          component = "elasticsearch"
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["elasticsearch"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        container {
          name  = "elasticsearch"
          image = "${var.elasticsearch_image}:${var.elasticsearch_version}"

          env {
            name  = "cluster.name"
            value = var.cluster_name
          }

          env {
            name  = "node.name"
            value = "elasticsearch-azure-$(POD_NAME)"
          }

          env {
            name  = "discovery.seed_hosts"
            value = var.elasticsearch_seed_hosts
          }

          env {
            name  = "cluster.initial_master_nodes"
            value = var.elasticsearch_initial_master_nodes
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = var.elasticsearch_java_opts
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          ports {
            container_port = 9200
            name          = "http"
          }

          ports {
            container_port = 9300
            name          = "transport"
          }

          resources {
            requests = {
              memory = var.elasticsearch_memory_request
              cpu    = var.elasticsearch_cpu_request
            }
            limits = {
              memory = var.elasticsearch_memory_limit
              cpu    = var.elasticsearch_cpu_limit
            }
          }

          volume_mount {
            name       = "elasticsearch-data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          liveness_probe {
            http_get {
              path = "/_cluster/health"
              port = 9200
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/_cluster/health"
              port = 9200
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }

        volume {
          name = "elasticsearch-data"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [var.azure_aks_cluster]
}

# AWS EKS Elasticsearch Service
resource "kubernetes_service" "elasticsearch_aws" {
  count = var.enable_aws_deployment ? 1 : 0
  
  metadata {
    name      = "${var.cluster_name}-elasticsearch-aws"
    namespace = var.namespace
    labels = {
      app       = "elasticsearch"
      cloud     = "aws"
      component = "elasticsearch"
    }
  }

  spec {
    selector = {
      app       = "elasticsearch"
      cloud     = "aws"
      component = "elasticsearch"
    }

    port {
      port        = 9200
      target_port = 9200
      name        = "http"
    }

    port {
      port        = 9300
      target_port = 9300
      name        = "transport"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.elasticsearch_aws]
}

# Azure AKS Elasticsearch Service
resource "kubernetes_service" "elasticsearch_azure" {
  count = var.enable_azure_deployment ? 1 : 0
  
  provider = kubernetes.azure

  metadata {
    name      = "${var.cluster_name}-elasticsearch-azure"
    namespace = var.namespace
    labels = {
      app       = "elasticsearch"
      cloud     = "azure"
      component = "elasticsearch"
    }
  }

  spec {
    selector = {
      app       = "elasticsearch"
      cloud     = "azure"
      component = "elasticsearch"
    }

    port {
      port        = 9200
      target_port = 9200
      name        = "http"
    }

    port {
      port        = 9300
      target_port = 9300
      name        = "transport"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.elasticsearch_azure]
}

# Cross-Cloud Service Discovery
resource "kubernetes_config_map" "elasticsearch_discovery" {
  count = (var.enable_aws_deployment && var.enable_azure_deployment) ? 1 : 0
  
  metadata {
    name      = "${var.cluster_name}-elasticsearch-discovery"
    namespace = var.namespace
    labels = {
      app       = "elasticsearch"
      component = "discovery"
    }
  }

  data = {
    "aws_endpoints"   = var.enable_aws_deployment ? join(",", [for svc in kubernetes_service.elasticsearch_aws : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9300"]) : ""
    "azure_endpoints" = var.enable_azure_deployment ? join(",", [for svc in kubernetes_service.elasticsearch_azure : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9300"]) : ""
    "all_endpoints"   = join(",", concat(
      var.enable_aws_deployment ? [for svc in kubernetes_service.elasticsearch_aws : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9300"] : [],
      var.enable_azure_deployment ? [for svc in kubernetes_service.elasticsearch_azure : "${svc.metadata[0].name}.${var.namespace}.svc.cluster.local:9300"] : []
    ))
  }
}
