# 🚀 Elasticsearch + Terraform Infrastructure as Code

**Complete Infrastructure as Code solution for deploying Elasticsearch and Kibana on AWS EKS using Terraform.**

## 📋 Overview

This project demonstrates how to deploy a production-ready Elasticsearch cluster with Kibana on AWS EKS using Terraform. Perfect for learning Infrastructure as Code, Kubernetes, and Elasticsearch deployment patterns.

## 🎯 What You'll Learn

- **Infrastructure as Code** with Terraform
- **EKS cluster management** and node group configuration
- **Elasticsearch deployment** on Kubernetes
- **Kibana integration** and configuration
- **Security best practices** for production deployments
- **Monitoring and observability** setup

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWS VPC       │    │   EKS Cluster   │    │   Elasticsearch │
│                 │    │                 │    │   + Kibana      │
│ • Public Subnets│    │ • Control Plane │    │ • StatefulSets  │
│ • Private       │    │ • Node Groups   │    │ • Services      │
│   Subnets       │    │ • Security      │    │ • Ingress       │
│ • NAT Gateways  │    │   Groups        │    │ • Monitoring    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### Required Tools
- ✅ **AWS CLI v2** (configured with appropriate permissions)
- ✅ **Terraform ≥1.12.2** (latest stable version recommended)
- ✅ **kubectl** (version compatible with EKS 1.29)

### AWS Requirements
- **IAM Permissions** for: EKS, EC2, VPC, IAM, S3, CloudWatch, ELB, Route 53, KMS
- **Service Quotas**: Ensure you have sufficient limits for EKS clusters, EBS volumes, and Elastic IPs
- **Region**: Currently configured for `us-west-2` (modifiable)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd elastic-terraform-demo
```

### 2. Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region
```

### 3. Customize Configuration
```bash
# Copy the example configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit terraform.tfvars with your values
# Pay special attention to passwords and cluster names
```

### 4. Deploy Infrastructure
```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 5. Access Your Deployment
```bash
# Configure kubectl for your cluster
aws eks update-kubeconfig --region us-west-2 --name elastic-demo-cluster

# Check deployment status
kubectl get pods -n elasticsearch
kubectl get pods -n kibana

# Port forward to access services
kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200
kubectl port-forward -n kibana svc/kibana 5601:5601
```

## ⚙️ Configuration

### Key Variables
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `aws_region` | `us-west-2` | AWS region for deployment |
| `cluster_name` | `elastic-demo-cluster` | EKS cluster name |
| `environment` | `demo` | Environment identifier |
| `elasticsearch_replicas` | `2` | Number of Elasticsearch replicas |
| `kibana_replicas` | `2` | Number of Kibana replicas |

### Node Groups
- **Elasticsearch Nodes**: t3.medium (2 vCPU, 4GB RAM)
- **Kibana Nodes**: t3.small (2 vCPU, 2GB RAM)

### Storage
- **Elasticsearch**: 100Gi GP2 volumes per node
- **Kibana**: 10Gi GP2 volumes per node

## 🔒 Security Features

- **TLS encryption** enabled by default
- **RBAC** configured for proper access control
- **Network policies** for pod-to-pod communication
- **IAM roles** for service accounts
- **Secrets management** for sensitive data

## 📊 Monitoring & Observability

- **CloudWatch integration** for metrics and logs
- **Kubernetes monitoring** with built-in tools
- **Elasticsearch monitoring** stack
- **Log aggregation** and analysis

## 🧹 Cleanup

### Destroy Infrastructure
```bash
cd terraform
terraform destroy -auto-approve
```

### Manual Cleanup (if needed)
```bash
# Delete Kubernetes resources
kubectl delete namespace elasticsearch
kubectl delete namespace kibana

# Check for orphaned AWS resources
aws ec2 describe-volumes --filters "Name=tag:kubernetes.io/cluster/elastic-demo-cluster,Values=owned"
```

## 📚 Documentation

- **Meetup Presentation**: `docs/Meetup_Presentation.md`
- **Architecture Diagrams**: `docs/architecture/`
- **Troubleshooting**: `docs/troubleshooting.md`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **HashiCorp** for Terraform
- **Elastic** for Elasticsearch and Kibana
- **AWS** for EKS and infrastructure services
- **Kubernetes** community for best practices

## 📞 Support

For questions or issues:
- **GitHub Issues**: Create an issue in this repository
- **Meetup**: Ask during the presentation
- **Email**: [Your Email]

---

**Happy Infrastructure as Coding! 🚀** 