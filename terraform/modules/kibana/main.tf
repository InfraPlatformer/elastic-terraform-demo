# Kibana Namespace
resource "kubernetes_namespace" "kibana" {
  metadata {
    name = "kibana"
    labels = {
      name = "kibana"
    }
  }
}

# Kibana ConfigMap
resource "kubernetes_config_map" "kibana_config" {
  metadata {
    name      = "kibana-config"
    namespace = kubernetes_namespace.kibana.metadata[0].name
  }

  data = {
    "kibana.yml" = yamlencode({
      server = {
        name = "kibana"
        host = "0.0.0.0"
        port = 5601
      }
      elasticsearch = {
        hosts = [var.elasticsearch_url]
        username = "elastic"
        password = var.kibana_password
      }
      xpack = {
        security = {
          enabled = false
        }
        reporting = {
          enabled = true
        }
      }
      monitoring = {
        ui = {
          enabled = true
        }
      }
      logging = {
        appenders = {
          console = {
            type = "console"
            layout = {
              type = "pattern"
            }
          }
        }
        root = {
          appenders = ["console"]
        }
      }
    })
  }
}

# Kibana Secret for passwords
resource "kubernetes_secret" "kibana_secret" {
  metadata {
    name      = "kibana-secret"
    namespace = kubernetes_namespace.kibana.metadata[0].name
  }

  data = {
    "kibana-password" = base64encode(var.kibana_password)
  }

  type = "Opaque"
}

# Kibana Service Account
resource "kubernetes_service_account" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.kibana.metadata[0].name
  }
}

# Kibana PersistentVolumeClaim - Temporarily commented out due to storage issues
# resource "kubernetes_persistent_volume_claim" "kibana" {
#   metadata {
#     name      = "kibana-data"
#     namespace = kubernetes_namespace.kibana.metadata[0].name
#   }
#
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = var.storage_size
#       }
#     }
#     storage_class_name = "gp2"
#   }
# }

# Kibana Deployment
resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.kibana.metadata[0].name
  }

  spec {
    replicas = var.replicas

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
        service_account_name = kubernetes_service_account.kibana.metadata[0].name
        
        node_selector = {
          "role" = "kibana"
        }
        


        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:${var.kibana_version}"

          port {
            container_port = 5601
            name          = "http"
          }

          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = var.elasticsearch_url
          }

          env {
            name  = "ELASTICSEARCH_USERNAME"
            value = "elastic"
          }

          env {
            name = "ELASTICSEARCH_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.kibana_secret.metadata[0].name
                key  = "kibana-password"
              }
            }
          }



          volume_mount {
            name       = "kibana-data"
            mount_path = "/usr/share/kibana/data"
          }

          volume_mount {
            name       = "kibana-config"
            mount_path = "/usr/share/kibana/config/kibana.yml"
            sub_path   = "kibana.yml"
          }

          resources {
            limits = {
              memory = var.memory_limit
              cpu    = var.cpu_limit
            }
            requests = {
              memory = "512Mi"
              cpu    = "250m"
            }
          }

          liveness_probe {
            http_get {
              path = "/api/status"
              port = 5601
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/api/status"
              port = 5601
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          security_context {
            run_as_user = 1000
          }
        }

        volume {
          name = "kibana-config"
          config_map {
            name = kubernetes_config_map.kibana_config.metadata[0].name
          }
        }

        volume {
          name = "kibana-data"
          empty_dir {}
        }

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          fs_group        = 1000
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

    type = "ClusterIP"
  }
}

# Kibana Service (LoadBalancer for external access)
resource "kubernetes_service" "kibana_external" {
  metadata {
    name      = "kibana-external"
    namespace = kubernetes_namespace.kibana.metadata[0].name
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
}

# Kibana Ingress (if using ingress controller)
resource "kubernetes_ingress_v1" "kibana" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = "kibana-ingress"
    namespace = kubernetes_namespace.kibana.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = "kibana.${var.cluster_name}.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kibana"
              port {
                number = 5601
              }
            }
          }
        }
      }
    }
  }
}

# Kibana HorizontalPodAutoscaler
resource "kubernetes_horizontal_pod_autoscaler" "kibana" {
  count = var.enable_autoscaling ? 1 : 0

  metadata {
    name      = "kibana-hpa"
    namespace = kubernetes_namespace.kibana.metadata[0].name
  }

  spec {
    max_replicas = var.max_replicas
    min_replicas = var.min_replicas

    target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.kibana.metadata[0].name
    }
  }
} 