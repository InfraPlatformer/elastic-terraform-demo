# Elastic and Terraform Meetup Presentation

## Prerequisites & Requirements

### 1. Tooling
- ✅ **AWS CLI v2** (configured with appropriate permissions)
- ✅ **Terraform ≥1.12.2** (latest stable version recommended)
- ✅ **kubectl** (version compatible with EKS 1.29)

### 2. AWS Requirements
- **IAM Permissions** 🔒
  - **Core Services**: EKS, EC2, VPC, IAM, S3, CloudWatch
  - **Networking**: ELB, Route 53, VPC Endpoints
  - **Storage**: EBS, EFS (if using)
  - **Security**: KMS, Secrets Manager
  - **Monitoring**: CloudWatch, CloudTrail

### 3. Quotas & Limits
- **VPC Limits**: 5 VPCs per region (default)
- **EBS Limits**: 20 volumes per region (default)
- **Elastic IPs**: 5+ available (for load balancers and NAT gateways)
- **EKS Clusters**: 100 per account (default)
- **EC2 Instances**: t3.medium/t3.small for demo (cost-effective)

## Default Configuration

| Parameter | Default Value | Notes |
|-----------|---------------|-------|
| `aws_region` | `us-west-2` | Demo region, change as needed |
| `cluster_name` | `elastic-demo-cluster` | Demo environment, DNS-compatible |
| `node_type` | `t3.medium` | Cost-effective for demo, 2 vCPU, 4GB RAM |
| `es_storage` | `100Gi` | GP2 volumes, sufficient for demo data |
| `environment` | `demo` | Clearly indicates demo environment |

## Demo Environment Specifications

### EKS Cluster
- **Version**: 1.29 (latest stable)
- **Node Groups**: 2-3 nodes for cost optimization
- **Instance Types**: t3.medium for Elasticsearch, t3.small for Kibana

### Elasticsearch
- **Version**: 8.11.0 (latest stable)
- **Replicas**: 2 (demo configuration)
- **Storage**: 100Gi per node (GP2 volumes)
- **Resources**: 1 CPU, 2GB RAM (demo limits)

### Kibana
- **Version**: 8.11.0 (matches Elasticsearch)
- **Replicas**: 2 (high availability)
- **Storage**: 10Gi (configuration and logs)
- **Resources**: 500m CPU, 1GB RAM

## Cost Optimization for Demo
- **Instance Types**: t3 family (burstable, cost-effective)
- **Storage**: GP2 instead of GP3 (better availability)
- **Auto-scaling**: Enabled but with conservative limits
- **Monitoring**: Basic CloudWatch metrics only
