# Elasticsearch Namespace
resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      name = "elasticsearch"
    }
  }
}

# Elasticsearch ConfigMap
resource "kubernetes_config_map" "elasticsearch_config" {
  metadata {
    name      = "elasticsearch-config"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }

  data = {
    "elasticsearch.yml" = yamlencode({
      cluster = {
        name = "${var.cluster_name}-elasticsearch"
      }
      node = {
        name = "elasticsearch-node"
        roles = ["master", "data"]
      }
      network = {
        host = "0.0.0.0"
      }
      discovery = {
        seed_hosts = ["elasticsearch-0.elasticsearch", "elasticsearch-1.elasticsearch", "elasticsearch-2.elasticsearch"]
        type = "single-node"
      }
      xpack = {
        security = {
          enabled = false
          transport = {
            ssl = {
              enabled = false
            }
          }
          http = {
            ssl = {
              enabled = false
            }
          }
        }
        monitoring = {
          templates = {
            enabled = true
          }
        }
        watcher = {
          enabled = true
        }
      }
      path = {
        data = "/usr/share/elasticsearch/data"
        logs = "/usr/share/elasticsearch/logs"
      }
    })
  }
}

# Elasticsearch Secret for passwords
resource "kubernetes_secret" "elasticsearch_secret" {
  metadata {
    name      = "elasticsearch-secret"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }

  data = {
    "elastic-password" = base64encode(var.elastic_password)
  }

  type = "Opaque"
}

# Elasticsearch Service Account
resource "kubernetes_service_account" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }
}

# Elasticsearch ClusterRole
resource "kubernetes_cluster_role" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings", "roles", "rolebindings"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Elasticsearch ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.elasticsearch.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.elasticsearch.metadata[0].name
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }
}

# Elasticsearch PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "elasticsearch" {
  count = var.replicas

  metadata {
    name      = "elasticsearch-data-${count.index}"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }

  timeouts {
    create = "45m"
  }
}

# Elasticsearch StatefulSet
resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
    labels = {
      app = "elasticsearch"
    }
  }

  depends_on = [kubernetes_persistent_volume_claim.elasticsearch]

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  spec {
    service_name = kubernetes_service.elasticsearch.metadata[0].name
    replicas     = var.replicas
    
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
        service_account_name = kubernetes_service_account.elasticsearch.metadata[0].name
        
        node_selector = var.node_selector
        
        dynamic "toleration" {
          for_each = var.tolerations
          content {
            key    = toleration.value.key
            value  = toleration.value.value
            effect = toleration.value.effect
          }
        }

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
            name  = "cluster.name"
            value = "${var.cluster_name}-elasticsearch"
          }

          env {
            name  = "node.name"
            value = "elasticsearch-$(hostname)"
          }

          env {
            name  = "discovery.seed_hosts"
            value = "elasticsearch-0.elasticsearch,elasticsearch-1.elasticsearch,elasticsearch-2.elasticsearch"
          }



          env {
            name  = "bootstrap.memory_lock"
            value = "true"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms1g -Xmx1g"
          }

          env {
            name = "ELASTIC_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.elasticsearch_secret.metadata[0].name
                key  = "elastic-password"
              }
            }
          }

          volume_mount {
            name       = "elasticsearch-data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          volume_mount {
            name       = "elasticsearch-config"
            mount_path = "/usr/share/elasticsearch/config/elasticsearch.yml"
            sub_path   = "elasticsearch.yml"
          }

          resources {
            limits = {
              memory = var.memory_limit
              cpu    = var.cpu_limit
            }
            requests = {
              memory = "1Gi"
              cpu    = "500m"
            }
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

                  security_context {
          run_as_user = 1000
        }
        }

        volume {
          name = "elasticsearch-config"
          config_map {
            name = kubernetes_config_map.elasticsearch_config.metadata[0].name
          }
        }

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          fs_group        = 1000
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "elasticsearch-data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.storage_size
          }
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

    port {
      port        = 9300
      target_port = 9300
      name        = "transport"
    }

    cluster_ip = "None"
  }
}

# Elasticsearch Service (LoadBalancer for external access)
resource "kubernetes_service" "elasticsearch_external" {
  metadata {
    name      = "elasticsearch-external"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
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

    type = "LoadBalancer"
  }
}

# Elasticsearch Ingress (if using ingress controller)
resource "kubernetes_ingress_v1" "elasticsearch" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = "elasticsearch-ingress"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = "elasticsearch.${var.cluster_name}.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "elasticsearch"
              port {
                number = 9200
              }
            }
          }
        }
      }
    }
  }
} 
