# =============================================================================
# PRODUCTION ENVIRONMENT VARIABLES
# =============================================================================
# Enterprise-grade production configuration variables
# =============================================================================

# Global Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "advanced-elastic"
}

variable "environment" {
  description = "Environment (production)"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "advanced-elastic-production-aws"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Production Node Groups Configuration
variable "aws_node_groups" {
  description = "AWS EKS node group configuration for production"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    elasticsearch = {
      instance_types = ["m5.large", "m5.xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size       = 3
      max_size       = 10
      desired_size   = 5
      disk_size      = 200
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
      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 5
      desired_size   = 3
      disk_size      = 100
      labels = {
        role = "monitoring"
      }
      taints = []
    }
  }
}

# Elasticsearch Configuration
variable "elasticsearch_replicas" {
  description = "Number of Elasticsearch replicas for production"
  type        = number
  default     = 5
}

variable "elasticsearch_resources" {
  description = "Resource limits and requests for Elasticsearch"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "8000m"
      memory = "16Gi"
    }
    requests = {
      cpu    = "4000m"
      memory = "8Gi"
    }
  }
}

variable "elasticsearch_heap_size" {
  description = "Elasticsearch heap size"
  type        = string
  default     = "8g"
}

variable "elasticsearch_data_nodes" {
  description = "Number of Elasticsearch data nodes"
  type        = number
  default     = 5
}

variable "elasticsearch_master_nodes" {
  description = "Number of Elasticsearch master nodes"
  type        = number
  default     = 3
}

variable "elasticsearch_ingest_nodes" {
  description = "Number of Elasticsearch ingest nodes"
  type        = number
  default     = 2
}

# Kibana Configuration
variable "kibana_replicas" {
  description = "Number of Kibana replicas"
  type        = number
  default     = 2
}

variable "kibana_version" {
  description = "Kibana Helm chart version"
  type        = string
  default     = "8.11.0"
}

variable "enable_ingress" {
  description = "Enable Ingress for services"
  type        = bool
  default     = false
}

variable "monitoring_retention_days" {
  description = "Number of days to retain monitoring data"
  type        = number
  default     = 30
}

variable "kibana_resources" {
  description = "Resource limits and requests for Kibana"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
    requests = {
      cpu    = "1000m"
      memory = "2Gi"
    }
  }
}

# Security Configuration
variable "enable_security" {
  description = "Enable Elasticsearch security features"
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Enable SSL/TLS encryption"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable centralized logging"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

# Grafana Configuration
variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "ProductionSecurePassword123!"
}

variable "grafana_resources" {
  description = "Resource limits and requests for Grafana"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "1000m"
      memory = "2Gi"
    }
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
}

# Backup Configuration
variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

# Cost Optimization
variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false  # Production should use on-demand instances
}

variable "enable_auto_scaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = true
}

# Alerting Configuration
variable "alert_rules" {
  description = "Prometheus alerting rules for production"
  type = map(object({
    alert = string
    expr = string
    for  = string
    labels = map(string)
    annotations = map(string)
  }))
  default = {
    elasticsearch_cluster_red = {
      alert = "ElasticsearchClusterRed"
      expr  = "elasticsearch_cluster_health_status{color=\"red\"} == 1"
      for   = "5m"
      labels = {
        severity = "critical"
        service  = "elasticsearch"
      }
      annotations = {
        summary = "Elasticsearch cluster is in RED state"
        description = "Elasticsearch cluster {{ $labels.cluster }} is in RED state for more than 5 minutes"
      }
    }
    elasticsearch_high_cpu = {
      alert = "ElasticsearchHighCPU"
      expr  = "rate(container_cpu_usage_seconds_total{pod=~\"elasticsearch.*\"}[5m]) > 0.8"
      for   = "10m"
      labels = {
        severity = "warning"
        service  = "elasticsearch"
      }
      annotations = {
        summary = "Elasticsearch high CPU usage"
        description = "Elasticsearch pod {{ $labels.pod }} has high CPU usage: {{ $value }}"
      }
    }
    elasticsearch_high_memory = {
      alert = "ElasticsearchHighMemory"
      expr  = "container_memory_usage_bytes{pod=~\"elasticsearch.*\"} / container_spec_memory_limit_bytes{pod=~\"elasticsearch.*\"} > 0.9"
      for   = "10m"
      labels = {
        severity = "warning"
        service  = "elasticsearch"
      }
      annotations = {
        summary = "Elasticsearch high memory usage"
        description = "Elasticsearch pod {{ $labels.pod }} has high memory usage: {{ $value }}"
      }
    }
    kibana_down = {
      alert = "KibanaDown"
      expr  = "up{job=\"kibana\"} == 0"
      for   = "5m"
      labels = {
        severity = "critical"
        service  = "kibana"
      }
      annotations = {
        summary = "Kibana is down"
        description = "Kibana service has been down for more than 5 minutes"
      }
    }
    prometheus_down = {
      alert = "PrometheusDown"
      expr  = "up{job=\"prometheus\"} == 0"
      for   = "5m"
      labels = {
        severity = "critical"
        service  = "prometheus"
      }
      annotations = {
        summary = "Prometheus is down"
        description = "Prometheus monitoring service has been down for more than 5 minutes"
      }
    }
  }
}

# Network Configuration
variable "enable_public_access" {
  description = "Enable public access to the cluster"
  type        = bool
  default     = false  # Production should be private
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Allow all for now, can be restricted later
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

# Storage Configuration
variable "enable_ebs_csi_driver" {
  description = "Enable AWS EBS CSI driver"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver"
  type        = string
  default     = "v1.20.0"
}

# SSH Access
variable "ssh_key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
  default     = ""
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "advanced-elastic"
    Environment = "production"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
    Purpose     = "elastic-stack"
    CostCenter  = "production"
    Compliance  = "required"
    Backup      = "required"
    Monitoring  = "required"
  }
}

# Production-specific variables
variable "production_contact" {
  description = "Primary contact for production issues"
  type        = string
  default     = "devops-team@company.com"
}

variable "production_slack_channel" {
  description = "Slack channel for production alerts"
  type        = string
  default     = "#production-alerts"
}

variable "production_pagerduty_key" {
  description = "PagerDuty integration key for production alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication for disaster recovery"
  type        = bool
  default     = false
}

variable "disaster_recovery_region" {
  description = "AWS region for disaster recovery"
  type        = string
  default     = "us-east-1"
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail for audit logging"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config for compliance monitoring"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty for threat detection"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub for security findings"
  type        = bool
  default     = true
}

# Performance tuning variables
variable "elasticsearch_jvm_options" {
  description = "Additional JVM options for Elasticsearch"
  type        = list(string)
  default = [
    "-XX:+UseG1GC",
    "-XX:MaxGCPauseMillis=200",
    "-XX:+UnlockExperimentalVMOptions",
    "-XX:+UseCGroupMemoryLimitForHeap"
  ]
}

variable "elasticsearch_indices_memory_index_buffer_size" {
  description = "Elasticsearch indices memory index buffer size"
  type        = string
  default     = "30%"
}

variable "elasticsearch_cluster_routing_allocation_disk_threshold_enabled" {
  description = "Enable disk threshold for cluster routing allocation"
  type        = bool
  default     = true
}

variable "elasticsearch_cluster_routing_allocation_disk_watermark_low" {
  description = "Low disk watermark for cluster routing allocation"
  type        = string
  default     = "85%"
}

variable "elasticsearch_cluster_routing_allocation_disk_watermark_high" {
  description = "High disk watermark for cluster routing allocation"
  type        = string
  default     = "90%"
}

variable "elasticsearch_cluster_routing_allocation_disk_watermark_flood_stage" {
  description = "Flood stage disk watermark for cluster routing allocation"
  type        = string
  default     = "95%"
}
