# 🚀 Azure Deployment Guide - Elastic Stack on AKS

This guide walks you through deploying the Elastic Stack on Azure Kubernetes Service (AKS) and setting up cross-cloud communication with your existing AWS deployment.

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Manual Deployment](#-manual-deployment)
- [Cross-Cloud Setup](#-cross-cloud-setup)
- [Cost Analysis](#-cost-analysis)
- [Troubleshooting](#-troubleshooting)

## ⚡ Prerequisites

### Required Tools
- **Azure CLI** >= 2.0
- **Terraform** >= 1.0
- **kubectl** >= 1.28
- **Helm** >= 3.0
- **Git** for cloning the repository

### Azure Requirements
- **Azure Subscription** with appropriate permissions
- **Resource Group** creation permissions
- **AKS** and **Container Registry** creation permissions
- **Key Vault** creation permissions

### Install Prerequisites

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/InfraPlatformer/elastic-terraform-demo.git
cd elastic-terraform-demo

# Make scripts executable
chmod +x scripts/*.sh
```

### 2. Configure Azure

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "Your Subscription ID"

# Create resource group (if not exists)
az group create \
  --name elastic-stack-staging-rg \
  --location "West US 2" \
  --tags Environment=staging Project=elastic-stack
```

### 3. Deploy Azure Infrastructure

```bash
# Deploy everything with one command
./scripts/deploy-azure.sh

# Or with custom parameters
./scripts/deploy-azure.sh \
  --azure-region "East US" \
  --cluster-name "my-elastic-aks" \
  --resource-group "my-elastic-rg"
```

### 4. Access Your Services

After deployment, you'll get URLs like:
- **Kibana**: `http://your-kibana-ip:5601`
- **Grafana**: `http://your-grafana-ip:3000`
- **Elasticsearch**: Use port-forward: `kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200`

## 🔧 Manual Deployment

### 1. Deploy Infrastructure

```bash
cd environments/azure-staging

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 2. Configure kubectl

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group elastic-stack-staging-rg \
  --name elastic-aks \
  --overwrite-existing

# Verify connection
kubectl get nodes
```

### 3. Verify Deployment

```bash
# Check all pods
kubectl get pods --all-namespaces

# Check services
kubectl get services --all-namespaces

# Check Elasticsearch health
kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200 &
curl http://localhost:9200/_cluster/health
```

### 4. Load Sample Data

```bash
# Load sample data
./scripts/load-sample-data.sh --elasticsearch-url "http://localhost:9200"
```

## 🌐 Cross-Cloud Setup

### Prerequisites
- Both AWS and Azure clusters must be running
- kubectl configured for both clusters
- Elasticsearch running on both clusters

### 1. Setup Cross-Cloud Communication

```bash
# Configure cross-cluster search
./scripts/setup-cross-cloud.sh

# Or with custom parameters
./scripts/setup-cross-cloud.sh \
  --aws-cluster "elastic-stack-cluster" \
  --aws-region "us-west-2" \
  --azure-cluster "elastic-aks" \
  --azure-resource-group "elastic-stack-staging-rg"
```

### 2. Test Cross-Cloud Queries

```bash
# Test from AWS to Azure
aws eks update-kubeconfig --region us-west-2 --name elastic-stack-cluster
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X GET "localhost:9200/azure_cluster:azure-data/_search"

# Test from Azure to AWS
az aks get-credentials --resource-group elastic-stack-staging-rg --name elastic-aks
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X GET "localhost:9200/aws_cluster:aws-data/_search"
```

## 💰 Cost Analysis

### Azure Resources and Costs (Monthly)

| Resource | Type | Quantity | Estimated Cost |
|----------|------|----------|----------------|
| **AKS Control Plane** | Managed | 1 | $0 (Free) |
| **Worker Nodes** | Standard_D4s_v3 | 3 | $360-600 |
| **Application Gateway** | Standard_v2 | 1 | $20-50 |
| **Container Registry** | Basic | 1 | $5 |
| **Key Vault** | Standard | 1 | $1 |
| **Log Analytics** | PerGB | 1 | $10-30 |
| **Storage** | Managed Disks | 300GB | $30-60 |
| **Data Transfer** | Outbound | Variable | $15-80 |
| **Total** | | | **$441-826/month** |

### Cost Optimization Tips

1. **Use Spot Instances**: Save 70-90% on worker nodes
2. **Reserved Instances**: Save 20-60% with 1-3 year commitments
3. **Auto-scaling**: Reduce costs by 30-40% during low usage
4. **Right-sizing**: Monitor and adjust VM sizes based on usage

### Multi-Cloud Cost Comparison

| Environment | AWS Only | Azure Only | Multi-Cloud |
|-------------|----------|------------|-------------|
| Development | $90-180 | $80-160 | $170-340 |
| Staging | $270-550 | $240-480 | $510-1030 |
| Production | $550-1400 | $480-1200 | $1030-2600 |

## 🛠️ Troubleshooting

### Common Issues

#### 1. AKS Cluster Creation Fails

**Problem**: `Error creating AKS cluster: Insufficient capacity`

**Solution**:
```bash
# Try different VM sizes
az vm list-skus --location "West US 2" --output table

# Use different availability zones
az aks get-versions --location "West US 2" --output table
```

#### 2. Pods Not Starting

**Problem**: Pods stuck in `Pending` state

**Diagnosis**:
```bash
# Check pod status
kubectl get pods --all-namespaces

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl top nodes
```

**Solutions**:
- Check node capacity
- Verify resource requests/limits
- Check node taints and tolerations

#### 3. LoadBalancer Not Getting IP

**Problem**: External IP shows `<pending>`

**Solution**:
```bash
# Check LoadBalancer service
kubectl get svc --all-namespaces

# Check if public IP is available
az network public-ip list --resource-group MC_elastic-stack-staging-rg_elastic-aks_westus2

# Create public IP if needed
az network public-ip create \
  --resource-group MC_elastic-stack-staging-rg_elastic-aks_westus2 \
  --name myPublicIP \
  --allocation-method Static
```

#### 4. Cross-Cloud Communication Issues

**Problem**: Cross-cluster search not working

**Diagnosis**:
```bash
# Check remote cluster info
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s "localhost:9200/_remote/info"

# Check network connectivity
kubectl exec -n elasticsearch deployment/elasticsearch -- nslookup <remote-cluster-ip>
```

**Solutions**:
- Verify security group rules
- Check network connectivity
- Ensure Elasticsearch is accessible

### Debugging Commands

```bash
# Get cluster information
az aks show --resource-group elastic-stack-staging-rg --name elastic-aks

# Check node status
kubectl get nodes -o wide

# Check pod logs
kubectl logs -n elasticsearch deployment/elasticsearch

# Check service endpoints
kubectl get endpoints --all-namespaces

# Check persistent volumes
kubectl get pv,pvc --all-namespaces
```

## 📊 Monitoring and Observability

### Azure Monitor Integration

```bash
# Check Log Analytics workspace
az monitor log-analytics workspace show \
  --resource-group elastic-stack-staging-rg \
  --workspace-name elastic-aks-logs

# View logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "KubePodInventory | where Namespace == 'elasticsearch'"
```

### Grafana Dashboards

Access Grafana at `http://your-grafana-ip:3000` with:
- **Username**: admin
- **Password**: admin123

Pre-built dashboards:
- Azure AKS Cluster Overview
- Elasticsearch Performance
- Application Metrics
- Cross-Cloud Data Flow

## 🔒 Security Best Practices

### Network Security
- Use private subnets for worker nodes
- Configure Network Security Groups (NSGs)
- Enable Azure Firewall for outbound traffic
- Use VNet integration for services

### Identity and Access
- Enable Azure AD integration
- Use managed identities
- Implement RBAC policies
- Store secrets in Azure Key Vault

### Data Protection
- Enable encryption at rest
- Use TLS for data in transit
- Implement backup and recovery
- Monitor access logs

## 📚 Additional Resources

### Documentation
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Elasticsearch on Azure](https://www.elastic.co/guide/en/elasticsearch/reference/current/azure.html)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### Tutorials
- [AKS Quick Start](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)
- [Elasticsearch on Kubernetes](https://www.elastic.co/guide/en/elasticsearch/reference/current/orchestrating-elasticsearch.html)
- [Cross-Cluster Search](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cross-cluster-search.html)

---

**🎉 Your Azure Elastic Stack deployment is now ready! You can now enjoy the benefits of a true multi-cloud architecture with cross-cluster search capabilities.**
