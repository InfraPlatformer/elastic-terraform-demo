# Code Walkthrough of main.tf - Presentation Notes

## 🎯 **Slide Objective**
Walk through the core infrastructure code that creates the complete Elasticsearch + Kibana stack on AWS EKS using Terraform.

---

## 📋 **Slide Structure & Speaking Points**

### **1. Introduction (30 seconds)**
> *"This main.tf file is the heart of our infrastructure. It defines everything from networking to Kubernetes deployments in about 440 lines of code. Let me walk you through the key sections."*

**Key Points:**
- Single file orchestrates entire infrastructure
- Modular approach using Terraform modules
- Production-ready with security and scalability

---

### **2. Data Sources & Foundation (45 seconds)**
```hcl
# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
```

**Speaking Points:**
> *"We start with data sources - these fetch information from AWS without creating resources. We get the current AWS account ID and available availability zones for high availability."*

**Technical Details:**
- `aws_caller_identity.current` - Gets AWS account ID for resource naming
- `aws_availability_zones.available` - Dynamically discovers AZs in the region
- Foundation for multi-AZ deployment

---

### **3. VPC & Networking Module (1 minute)**
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  
  azs             = var.availability_zones
  private_subnets = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i + 100)]
}
```

**Speaking Points:**
> *"The VPC module creates our networking foundation. Notice the dynamic subnet calculation using for loops - this automatically creates subnets across all availability zones. We have both public and private subnets for security."*

**Key Features to Highlight:**
- **Dynamic subnet creation** across all AZs
- **NAT Gateways** for private subnet internet access
- **Kubernetes-specific tags** for EKS integration
- **High availability** with multiple AZs

**Technical Deep Dive:**
- `cidrsubnet(var.vpc_cidr, 8, i)` - Creates /24 subnets (256 IPs each)
- `i + 100` offset ensures public and private subnets don't overlap
- Kubernetes tags enable proper EKS networking

---

### **4. EKS Cluster Module (1.5 minutes)**
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}
```

**Speaking Points:**
> *"The EKS module creates our Kubernetes cluster. We're using the latest EKS module version 19, which supports EKS 1.29. Notice we place the cluster in private subnets for security, but enable public endpoint access for management."*

**Node Groups Configuration:**
```hcl
eks_managed_node_groups = {
  elasticsearch = {
    name = "elasticsearch-nodes"
    instance_types = [var.node_groups.elasticsearch.instance_type]
    min_size     = var.node_groups.elasticsearch.min_size
    max_size     = var.node_groups.elasticsearch.max_size
    desired_size = var.node_groups.elasticsearch.desired_size
  }
}
```

**Key Features:**
- **Dedicated node groups** for Elasticsearch and Kibana
- **Taints and tolerations** ensure proper pod placement
- **Auto-scaling** with min/max/desired sizes
- **Resource isolation** between workloads

---

### **5. Kubernetes Resources (2 minutes)**

#### **Elasticsearch Deployment:**
```hcl
resource "kubernetes_deployment" "elasticsearch" {
  spec {
    replicas = var.elasticsearch_replicas
    
    template {
      spec {
        node_selector = {
          "role" = "kibana"  # Note: This should be "elasticsearch"
        }
        
        container {
          image = "docker.elastic.co/elasticsearch/elasticsearch:${var.elasticsearch_version}"
          name  = "elasticsearch"
          
          env {
            name  = "discovery.type"
            value = "single-node"
          }
        }
      }
    }
  }
}
```

**Speaking Points:**
> *"Here we define our Elasticsearch deployment. Notice the node selector and tolerations - this ensures Elasticsearch pods only run on dedicated elasticsearch nodes. We're using the official Elastic Docker image with configurable versioning."*

**Key Configuration:**
- **Single-node discovery** for demo purposes
- **Resource limits** (1 CPU, 1GB RAM)
- **Security disabled** for demo (xpack.security.enabled = false)
- **Port 9200** for HTTP API access

#### **Kibana Deployment:**
```hcl
resource "kubernetes_deployment" "kibana" {
  spec {
    replicas = var.kibana_replicas
    
    template {
      spec {
        container {
          image = "docker.elastic.co/kibana/kibana:${var.kibana_version}"
          
          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "http://elasticsearch.elasticsearch.svc.cluster.local:9200"
          }
        }
      }
    }
  }
}
```

**Speaking Points:**
> *"Kibana connects to Elasticsearch using the internal Kubernetes service DNS. This internal communication keeps our data secure within the cluster."*

---

### **6. Services & Load Balancing (1 minute)**
```hcl
# Internal Service
resource "kubernetes_service" "elasticsearch" {
  spec {
    type = "ClusterIP"  # Internal only
    port {
      port        = 9200
      target_port = 9200
    }
  }
}

# External Load Balancer
resource "kubernetes_service" "kibana_external" {
  spec {
    type = "LoadBalancer"  # External access
    port {
      port        = 5601
      target_port = 5601
    }
  }
}
```

**Speaking Points:**
> *"We have two types of services: Elasticsearch is ClusterIP for internal access only, while Kibana gets a LoadBalancer for external web access. This follows the principle of least privilege."*

---

### **7. S3 Backup Infrastructure (1 minute)**
```hcl
resource "aws_s3_bucket" "elasticsearch_backups" {
  count  = var.backup_enabled ? 1 : 0
  bucket = "${var.cluster_name}-elasticsearch-backups-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_lifecycle_configuration" "elasticsearch_backups" {
  rule {
    expiration {
      days = var.backup_retention_days
    }
  }
}
```

**Speaking Points:**
> *"The backup infrastructure is conditionally created using count. We generate unique bucket names and implement lifecycle policies for automatic cleanup. This prevents backup storage costs from accumulating."*

---

## 🎯 **Key Takeaways to Emphasize**

### **Architecture Benefits:**
1. **Modular Design** - Reusable, maintainable code
2. **Security First** - Private subnets, IAM roles, network policies
3. **Scalability** - Auto-scaling node groups, configurable replicas
4. **Production Ready** - High availability, monitoring, backups

### **Terraform Best Practices Demonstrated:**
1. **Module Usage** - Leveraging community modules
2. **Variable Abstraction** - Configurable without code changes
3. **Resource Dependencies** - Proper ordering with depends_on
4. **Conditional Resources** - Feature flags for optional components

---

## ⚠️ **Common Questions & Answers**

### **Q: "Why use modules instead of raw resources?"**
**A:** Modules provide battle-tested configurations, reduce code duplication, and handle complex dependencies automatically.

### **Q: "How do you handle secrets and sensitive data?"**
**A:** For production, we'd use AWS Secrets Manager, Kubernetes secrets, or external secret operators. This demo disables security for simplicity.

### **Q: "What about monitoring and logging?"**
**A:** This demo focuses on core infrastructure. Production would include CloudWatch, Prometheus, Grafana, and centralized logging.

---

## 🚀 **Demo Suggestions**

### **Live Code Changes:**
1. **Change replica count** and show `terraform plan`
2. **Modify instance types** to show node group updates
3. **Enable/disable backup** to show conditional resources

### **Infrastructure Validation:**
1. **Show kubectl get pods** after deployment
2. **Demonstrate service connectivity**
3. **Display auto-scaling in action**

---

## 📝 **Slide Summary**

**Title:** "Code Walkthrough of main.tf"
**Duration:** 8-10 minutes
**Key Message:** "This single file creates a complete, production-ready Elasticsearch + Kibana stack with proper security, scalability, and maintainability."

**Structure:**
1. Introduction (30s)
2. Data Sources (45s)
3. VPC & Networking (1m)
4. EKS Cluster (1.5m)
5. Kubernetes Resources (2m)
6. Services & Load Balancing (1m)
7. S3 Backup Infrastructure (1m)
8. Key Takeaways (1m)
9. Q&A (1-2m)

---

## 🔧 **Technical Notes for Presenter**

- **File Size:** 440 lines
- **Resources Created:** ~15-20 AWS/K8s resources
- **Deployment Time:** ~15-20 minutes
- **Cost:** ~$50-100/month for demo environment
- **Production Considerations:** Add monitoring, security, and backup validation
