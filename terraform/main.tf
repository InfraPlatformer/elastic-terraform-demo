# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC and Networking
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i + 100)]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-vpc"
  })
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Disable KMS encryption to avoid permission issues
  create_kms_key = false
  cluster_encryption_config = {}

  # Disable CloudWatch logging to avoid conflicts
  cluster_enabled_log_types = []
  create_cloudwatch_log_group = false

  eks_managed_node_groups = {
    elasticsearch = {
      name = "elasticsearch-nodes"

      instance_types = [var.node_groups.elasticsearch.instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_groups.elasticsearch.min_size
      max_size     = var.node_groups.elasticsearch.max_size
      desired_size = var.node_groups.elasticsearch.desired_size

      labels = {
        role = "elasticsearch"
      }

      taints = [{
        key    = "dedicated"
        value  = "elasticsearch"
        effect = "NO_SCHEDULE"
      }]

      tags = {
        ExtraTag = "elasticsearch-node-group"
      }
    }

    kibana = {
      name = "kibana-nodes"

      instance_types = [var.node_groups.kibana.instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_groups.kibana.min_size
      max_size     = var.node_groups.kibana.max_size
      desired_size = var.node_groups.kibana.desired_size

      labels = {
        role = "kibana"
      }

      taints = [{
        key    = "dedicated"
        value  = "kibana"
        effect = "NO_SCHEDULE"
      }]

      tags = {
        ExtraTag = "kibana-node-group"
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = var.cluster_name
  })
}

# Wait for EKS cluster to be fully ready
resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]
  
  create_duration = "60s"
}

# Simple Elasticsearch Deployment (no complex storage)
resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
  depends_on = [time_sleep.wait_for_eks]
}

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
        node_selector = {
          "role" = "kibana"
        }

        toleration {
          key    = "dedicated"
          value  = "kibana"
          effect = "NoSchedule"
        }

        container {
          image = "docker.elastic.co/elasticsearch/elasticsearch:${var.elasticsearch_version}"
          name  = "elasticsearch"

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
          }

          resources {
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.elasticsearch]
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

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.elasticsearch]
}

# Simple Kibana Deployment
resource "kubernetes_namespace" "kibana" {
  metadata {
    name = "kibana"
  }
  depends_on = [time_sleep.wait_for_eks]
}

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
        node_selector = {
          "role" = "kibana"
        }

        toleration {
          key    = "dedicated"
          value  = "kibana"
          effect = "NoSchedule"
        }

        container {
          image = "docker.elastic.co/kibana/kibana:${var.kibana_version}"
          name  = "kibana"

          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
          }

          port {
            container_port = 5601
          }

          resources {
            limits = {
              cpu    = var.kibana_cpu_limit
              memory = var.kibana_memory_limit
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.kibana]
}

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
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.kibana]
}

# External Load Balancer for Kibana
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
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.kibana]
}

# S3 Bucket for Elasticsearch Backups
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "elasticsearch_backups" {
  count  = var.backup_enabled ? 1 : 0
  bucket = "${var.cluster_name}-elasticsearch-backups-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-elasticsearch-backups"
  })
}

resource "aws_s3_bucket_versioning" "elasticsearch_backups" {
  count  = var.backup_enabled ? 1 : 0
  bucket = aws_s3_bucket.elasticsearch_backups[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "elasticsearch_backups" {
  count  = var.backup_enabled ? 1 : 0
  bucket = aws_s3_bucket.elasticsearch_backups[0].id

  rule {
    id     = "backup_retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.backup_retention_days
    }
  }
}

# IAM Role for Elasticsearch S3 Access
resource "aws_iam_role" "elasticsearch_s3" {
  count = var.backup_enabled ? 1 : 0
  name  = "${var.cluster_name}-elasticsearch-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "elasticsearch_s3" {
  count = var.backup_enabled ? 1 : 0
  name  = "${var.cluster_name}-elasticsearch-s3-policy"
  role  = aws_iam_role.elasticsearch_s3[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.elasticsearch_backups[0].arn,
          "${aws_s3_bucket.elasticsearch_backups[0].arn}/*"
        ]
      }
    ]
  })
} 