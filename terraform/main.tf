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

# Elasticsearch Module
module "elasticsearch" {
  source = "./modules/elasticsearch"

  cluster_name = var.cluster_name
  elasticsearch_version = var.elasticsearch_version
  replicas     = var.elasticsearch_replicas

  storage_size    = var.elasticsearch_storage_size
  memory_limit    = var.elasticsearch_memory_limit
  cpu_limit       = var.elasticsearch_cpu_limit

  enable_tls       = var.enable_tls
  elastic_password = var.elastic_password

  node_selector = {
    "role" = "elasticsearch"
  }

  tolerations = [{
    key    = "dedicated"
    value  = "elasticsearch"
    effect = "NoSchedule"
  }]

  depends_on = [time_sleep.wait_for_eks]
}

# Kibana Module
module "kibana" {
  source = "./modules/kibana"

  cluster_name = var.cluster_name
  kibana_version = var.kibana_version
  replicas     = var.kibana_replicas

  storage_size = var.kibana_storage_size
  memory_limit = var.kibana_memory_limit
  cpu_limit    = var.kibana_cpu_limit

  elasticsearch_url = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
  kibana_password   = var.kibana_password

  enable_tls = var.enable_tls
  enable_ingress = var.enable_ingress
  enable_autoscaling = var.enable_autoscaling
  min_replicas = var.kibana_replicas
  max_replicas = var.kibana_replicas * 2

  tolerations = [{
    key    = "dedicated"
    value  = "kibana"
    effect = "NoSchedule"
  }]

  depends_on = [module.elasticsearch]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  count  = var.enable_monitoring ? 1 : 0

  cluster_name = var.cluster_name
  environment  = var.environment

  elasticsearch_url = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
  kibana_url        = "http://kibana.kibana.svc.cluster.local:5601"

  depends_on = [module.elasticsearch, module.kibana]
}

# Application Load Balancer for Kibana
resource "aws_lb" "kibana" {
  name               = "${var.cluster_name}-kibana-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kibana_alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-kibana-alb"
  })
}

resource "aws_lb_target_group" "kibana" {
  name     = "${var.cluster_name}-kibana-tg"
  port     = 5601
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/api/status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-kibana-tg"
  })
}

resource "aws_lb_listener" "kibana" {
  load_balancer_arn = aws_lb.kibana.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana.arn
  }
}

# Security Group for Kibana ALB
resource "aws_security_group" "kibana_alb" {
  name_prefix = "${var.cluster_name}-kibana-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-kibana-alb-sg"
  })
}

# S3 Bucket for Elasticsearch Backups
resource "aws_s3_bucket" "elasticsearch_backups" {
  count  = var.enable_backup ? 1 : 0
  bucket = "${var.cluster_name}-elasticsearch-backups-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-elasticsearch-backups"
  })
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "elasticsearch_backups" {
  count  = var.enable_backup ? 1 : 0
  bucket = aws_s3_bucket.elasticsearch_backups[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "elasticsearch_backups" {
  count  = var.enable_backup ? 1 : 0
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
  count = var.enable_backup ? 1 : 0
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

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-elasticsearch-s3-role"
  })
}

resource "aws_iam_role_policy" "elasticsearch_s3" {
  count  = var.enable_backup ? 1 : 0
  name   = "${var.cluster_name}-elasticsearch-s3-policy"
  role   = aws_iam_role.elasticsearch_s3[0].id

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

# Elasticsearch Backup CronJob
resource "kubernetes_cron_job_v1" "elasticsearch_backup" {
  count = var.enable_backup ? 1 : 0

  metadata {
    name      = "elasticsearch-backup"
    namespace = "elasticsearch"
  }

  spec {
    schedule = "0 2 * * *"  # Daily at 2 AM

    job_template {
      metadata {
        name = "elasticsearch-backup-job"
      }
      spec {
        template {
          metadata {
            name = "elasticsearch-backup-pod"
          }
          spec {
            container {
              name  = "backup"
              image = "curlimages/curl:latest"

              command = ["/bin/sh"]
              args = [
                "-c",
                <<-EOT
                  curl -X PUT "http://elasticsearch:9200/_snapshot/s3_repository" \
                    -H "Content-Type: application/json" \
                    -d '{
                      "type": "s3",
                      "settings": {
                        "bucket": "${aws_s3_bucket.elasticsearch_backups[0].bucket}",
                        "region": "${var.aws_region}"
                      }
                    }'
                  
                  curl -X PUT "http://elasticsearch:9200/_snapshot/s3_repository/snapshot_$(date +%Y%m%d_%H%M%S)" \
                    -H "Content-Type: application/json" \
                    -d '{
                      "indices": "*",
                      "ignore_unavailable": true,
                      "include_global_state": false
                    }'
                EOT
              ]

              resources {
                limits = {
                  memory = "256Mi"
                  cpu    = "100m"
                }
                requests = {
                  memory = "128Mi"
                  cpu    = "50m"
                }
              }
            }

            restart_policy = "OnFailure"
          }
        }
      }
    }
  }

  depends_on = [module.elasticsearch]
} 