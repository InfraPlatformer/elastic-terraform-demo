# Quick Start Guide - Complete Elasticsearch & Kibana Infrastructure

This guide will walk you through deploying the complete Elasticsearch and Kibana infrastructure on AWS EKS in under 30 minutes.

## 🚀 Prerequisites Check

Before starting, ensure you have:

- [ ] AWS CLI installed and configured
- [ ] Terraform installed (v1.0+)
- [ ] kubectl installed
- [ ] PowerShell 7.0+ (for Windows users)
- [ ] AWS account with appropriate permissions

### Quick Prerequisites Installation

#### Windows (PowerShell)
```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required tools
choco install terraform awscli kubernetes-cli -y
```

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install terraform awscli kubernetes-cli
```

#### Linux (Ubuntu/Debian)
```bash
# Install required tools
sudo apt update
sudo apt install -y terraform awscli kubectl
```

## ⚡ 5-Minute Deployment

### Step 1: Clone and Navigate
```bash
git clone <repository-url>
cd "Elastic and Terraform"
```

### Step 2: Configure AWS
```bash
aws configure
# Enter your AWS credentials when prompted
```

### Step 3: Deploy Everything
```powershell
# Navigate to scripts directory
cd scripts

# Run the complete deployment script
.\deploy-complete.ps1 -SkipConfirmation
```

That's it! The script will handle everything else automatically.

## 🔧 Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
cd terraform

# Copy and customize configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferences

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## 🌐 Access Your Services

After deployment (usually 15-20 minutes), you'll get:

### Kibana Access
- **External URL**: `http://your-alb-url` (from terraform output)
- **Username**: `elastic`
- **Password**: Value from `terraform.tfvars`

### Internal Access
- **Elasticsearch**: `http://elasticsearch.elasticsearch.svc.cluster.local:9200`
- **Kibana**: `http://kibana.kibana.svc.cluster.local:5601`
- **Monitoring**: `http://prometheus.monitoring.svc.cluster.local:9090`

## 📊 Verify Deployment

### Check Cluster Status
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name elastic-demo-cluster

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### Check Services
```bash
# Check all pods
kubectl get pods -A

# Check Elasticsearch
kubectl get pods -n elasticsearch
kubectl logs -n elasticsearch elasticsearch-0

# Check Kibana
kubectl get pods -n kibana
kubectl logs -n kibana kibana-0
```

### Test Elasticsearch
```bash
# Check cluster health
kubectl exec -n elasticsearch elasticsearch-0 -- curl -s http://localhost:9200/_cluster/health

# Create test index
kubectl exec -n elasticsearch elasticsearch-0 -- curl -X PUT "http://localhost:9200/test-index"
```

## 🎯 First Steps with Kibana

1. **Access Kibana**: Open the ALB URL in your browser
2. **Login**: Use `elastic` username and password from terraform.tfvars
3. **Create Index Pattern**: Go to Stack Management → Index Patterns
4. **Add Sample Data**: Use the sample data sets for testing

## 🔍 Monitoring Your Infrastructure

### Prometheus Metrics
- **Elasticsearch**: Cluster health, performance metrics
- **Kibana**: Request latency, error rates
- **Kubernetes**: Resource usage, pod health

### Grafana Dashboards
- Pre-configured dashboards for Elasticsearch and Kibana
- Kubernetes cluster monitoring
- Custom metric visualization

### Alerts
- Cluster health notifications
- Resource usage warnings
- Backup failure alerts

## 🚨 Troubleshooting Quick Fixes

### Common Issues and Solutions

#### Elasticsearch Pods Not Starting
```bash
# Check resource limits
kubectl describe pod -n elasticsearch elasticsearch-0

# Check storage
kubectl get pvc -n elasticsearch

# Check events
kubectl get events -n elasticsearch --sort-by='.lastTimestamp'
```

#### Kibana Connection Issues
```bash
# Verify Elasticsearch is running
kubectl exec -n elasticsearch elasticsearch-0 -- curl -s http://localhost:9200/_cluster/health

# Check Kibana logs
kubectl logs -n kibana kibana-0 -f
```

#### Storage Problems
```bash
# Check storage class
kubectl get storageclass

# Check persistent volumes
kubectl get pv,pvc -A
```

## 💰 Cost Management

### Current Costs
- **EKS Cluster**: ~$150-300/month
- **Elasticsearch**: ~$200-400/month
- **Kibana**: ~$50-100/month
- **Total**: ~$400-800/month

### Cost Optimization
```bash
# Scale down for development
terraform apply -var="elasticsearch_replicas=1" -var="kibana_replicas=1"

# Use smaller instances
terraform apply -var='node_groups={"elasticsearch":{"instance_type":"t3.small","min_size":1,"max_size":3,"desired_size":1},"kibana":{"instance_type":"t3.micro","min_size":1,"max_size":2,"desired_size":1}}'
```

## 🧹 Cleanup

### Destroy Infrastructure
```bash
cd terraform
terraform destroy
```

### Remove Local Files
```bash
# Remove Terraform state and plan files
rm -rf .terraform* tfplan
```

## 📚 Next Steps

### Production Readiness
1. **Security**: Review and customize security configurations
2. **Monitoring**: Set up external monitoring and alerting
3. **Backup**: Test backup and restore procedures
4. **Scaling**: Configure auto-scaling policies

### Advanced Features
1. **Ingress Controller**: Enable for custom domain access
2. **SSL/TLS**: Configure custom certificates
3. **Authentication**: Integrate with external identity providers
4. **Logging**: Set up centralized logging with Fluentd

### Integration
1. **CI/CD**: Automate deployments with GitHub Actions
2. **Monitoring**: Integrate with external monitoring tools
3. **Alerting**: Set up Slack/email notifications
4. **Backup**: Configure cross-region backup replication

## 🆘 Getting Help

### Quick Support
- **Documentation**: Check the main README.md
- **Troubleshooting**: Review the troubleshooting section
- **Issues**: Open an issue in the repository

### Community Resources
- [Elastic Community](https://discuss.elastic.co/)
- [AWS EKS Community](https://github.com/aws/eks-charts)
- [Terraform Community](https://discuss.hashicorp.com/)

---

## ⏱️ Deployment Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| **Preparation** | 5 min | Prerequisites, configuration |
| **Infrastructure** | 15-20 min | EKS cluster, VPC, networking |
| **Applications** | 10-15 min | Elasticsearch, Kibana, monitoring |
| **Verification** | 5 min | Health checks, testing |
| **Total** | **35-45 min** | Complete deployment |

## 🎉 Success Checklist

- [ ] EKS cluster is running
- [ ] Elasticsearch pods are healthy
- [ ] Kibana is accessible via ALB
- [ ] Monitoring stack is operational
- [ ] Backups are configured
- [ ] Security is enabled
- [ ] Cost monitoring is set up

**Congratulations! You now have a production-ready Elasticsearch and Kibana infrastructure running on AWS EKS! 🚀**
