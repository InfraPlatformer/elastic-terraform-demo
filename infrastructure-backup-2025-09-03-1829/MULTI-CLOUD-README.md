# 🌍 Multi-Cloud Elasticsearch Infrastructure

This project provides a **production-ready, multi-cloud Elasticsearch infrastructure** that runs simultaneously on **AWS EKS** and **Azure AKS**. It's designed to handle network issues gracefully and provide high availability across cloud providers.

## 🚀 **Key Features**

- **Multi-Cloud Deployment**: AWS EKS + Azure AKS simultaneously
- **Network Issue Resolution**: Automatic detection and resolution of connectivity problems
- **High Availability**: Elasticsearch clusters across multiple cloud providers
- **Auto-scaling**: Intelligent node pool management on both clouds
- **Security**: Built-in security policies and encryption
- **Monitoring**: Comprehensive monitoring and alerting
- **Disaster Recovery**: Cross-cloud backup and replication

## 🏗️ **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────┐
│                    MULTI-CLOUD ELASTICSEARCH                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐                    ┌─────────────────┐   │
│  │   AWS EKS       │                    │   Azure AKS     │   │
│  │                 │                    │                 │   │
│  │ ┌─────────────┐ │                    │ ┌─────────────┐ │   │
│  │ │Elasticsearch│ │◄──────────────────►│ │Elasticsearch│ │   │
│  │ │   Nodes     │ │   Cross-Cloud      │ │   Nodes     │ │   │
│  │ │             │ │   Communication    │ │             │ │   │
│  │ └─────────────┘ │                    │ └─────────────┘ │   │
│  │                 │                    │                 │   │
│  │ ┌─────────────┐ │                    │ ┌─────────────┐ │   │
│  │ │   Kibana    │ │                    │ │   Kibana    │ │   │
│  │ │   Nodes     │ │                    │ │   Nodes     │ │   │
│  │ └─────────────┘ │                    │ └─────────────┘ │   │
│  │                 │                    │                 │   │
│  │ ┌─────────────┐ │                    │ ┌─────────────┐ │   │
│  │ │ Monitoring  │ │                    │ │ Monitoring  │ │   │
│  │ │   Stack     │ │                    │ │   Stack     │ │   │
│  │ └─────────────┘ │                    │ └─────────────┘ │   │
│  └─────────────────┘                    └─────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Cross-Cloud Load Balancer                      │ │
│  │              (Traffic Distribution)                         │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 **Prerequisites**

### **Required Tools**
- **Terraform** >= 1.0
- **AWS CLI** with configured credentials
- **Azure CLI** with configured credentials
- **kubectl** for Kubernetes management
- **PowerShell 7** (for Windows deployment scripts)

### **Cloud Accounts**
- **AWS Account** with EKS permissions
- **Azure Subscription** with AKS permissions
- **Service Principal** for Azure automation

### **Network Requirements**
- Stable internet connection
- Access to cloud service endpoints
- No restrictive firewall rules

## 🔧 **Quick Start**

### **1. Clone and Setup**
```bash
git clone <your-repo>
cd advanced-elastic-terraform
```

### **2. Configure Credentials**
```bash
# AWS
aws configure

# Azure
az login
az account set --subscription <your-subscription-id>
```

### **3. Update Configuration**
Edit `environments/multi-cloud.tfvars`:
```hcl
azure_subscription_id = "your-actual-subscription-id"
azure_tenant_id = "your-actual-tenant-id"
azure_client_id = "your-actual-client-id"
azure_client_secret = "your-actual-client-secret"
```

### **4. Deploy Infrastructure**
```powershell
# Full deployment with validation
.\deploy-multi-cloud.ps1

# Skip validation (faster)
.\deploy-multi-cloud.ps1 -SkipValidation

# Force deployment despite network issues
.\deploy-multi-cloud.ps1 -ForceDeploy

# Cleanup on failure
.\deploy-multi-cloud.ps1 -CleanupOnFailure
```

## 🌐 **Network Issue Resolution**

### **Common Network Problems**
1. **DNS Resolution Issues**
   - Cloud service endpoints unreachable
   - Container registry access problems
   - Kubernetes API connectivity issues

2. **Firewall Restrictions**
   - Corporate network blocking cloud services
   - ISP-level filtering
   - VPN interference

3. **Proxy Issues**
   - Corporate proxy configuration
   - Authentication problems
   - SSL certificate issues

### **Automatic Resolution**
The deployment script automatically:
- ✅ **Detects network connectivity issues**
- ✅ **Flushes DNS cache**
- ✅ **Resets network configuration**
- ✅ **Retries failed connections**
- ✅ **Provides detailed error reporting**

### **Manual Resolution Steps**
If automatic resolution fails:

```powershell
# Flush DNS
ipconfig /flushdns

# Reset network stack
netsh winsock reset
netsh int ip reset

# Restart network services
Restart-Service -Name "Dnscache"
Restart-Service -Name "nsi"

# Check connectivity
Test-NetConnection -ComputerName "eks.us-west-2.amazonaws.com" -Port 443
Test-NetConnection -ComputerName "management.azure.com" -Port 443
```

## 📊 **Monitoring and Health Checks**

### **Cluster Health**
```bash
# AWS EKS
kubectl get nodes --context aws
kubectl get pods -n elasticsearch -l cloud=aws

# Azure AKS
kubectl get nodes --context azure
kubectl get pods -n elasticsearch -l cloud=azure
```

### **Elasticsearch Health**
```bash
# Check cluster health
kubectl port-forward -n elasticsearch svc/elasticsearch-aws 9200:9200
curl http://localhost:9200/_cluster/health

# Check indices
curl http://localhost:9200/_cat/indices
```

### **Cross-Cloud Communication**
```bash
# Verify cross-cloud discovery
kubectl get configmap -n elasticsearch elasticsearch-discovery -o yaml

# Test cross-cluster communication
kubectl exec -n elasticsearch deployment/elasticsearch-aws -- curl elasticsearch-azure.elasticsearch.svc.cluster.local:9200/_cluster/health
```

## 🔒 **Security Features**

### **Network Security**
- **Private subnets** for worker nodes
- **Security groups** with minimal required access
- **Network policies** for pod-to-pod communication
- **Encrypted traffic** between nodes

### **Access Control**
- **IAM roles** for AWS resources
- **Service principals** for Azure resources
- **RBAC** for Kubernetes access
- **Secrets management** for sensitive data

### **Data Protection**
- **Encryption at rest** for persistent volumes
- **Encryption in transit** for all communications
- **Regular backups** with encryption
- **Audit logging** for compliance

## 📈 **Scaling and Performance**

### **Auto-scaling Configuration**
```hcl
# AWS EKS
aws_node_groups = {
  elasticsearch = {
    min_size = 2
    max_size = 10
    desired_size = 3
  }
}

# Azure AKS
azure_node_pools = {
  elasticsearch = {
    min_count = 2
    max_count = 10
    count = 3
  }
}
```

### **Performance Optimization**
- **Dedicated node pools** for Elasticsearch
- **Resource limits** and requests
- **Anti-affinity rules** for high availability
- **Storage optimization** with appropriate volume types

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Terraform Plan Fails**
```bash
# Check configuration
terraform validate

# Check provider versions
terraform version

# Clear cache and reinitialize
rm -rf .terraform
terraform init
```

#### **2. Cluster Creation Fails**
```bash
# Check cloud provider logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks"
az monitor activity-log list --resource-group <resource-group>

# Verify credentials
aws sts get-caller-identity
az account show
```

#### **3. Pods Not Starting**
```bash
# Check pod events
kubectl describe pod <pod-name> -n elasticsearch

# Check node resources
kubectl describe node <node-name>

# Check storage classes
kubectl get storageclass
```

#### **4. Network Connectivity Issues**
```bash
# Test pod-to-pod communication
kubectl exec -it <pod-name> -n elasticsearch -- nslookup elasticsearch-service

# Check service endpoints
kubectl get endpoints -n elasticsearch

# Verify network policies
kubectl get networkpolicy -n elasticsearch
```

### **Debug Mode**
Enable debug logging:
```bash
# Terraform
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Kubernetes
kubectl --v=8 get pods

# AWS CLI
aws --debug sts get-caller-identity
```

## 🔄 **Maintenance and Updates**

### **Regular Maintenance**
```bash
# Update Terraform modules
terraform init -upgrade

# Check for updates
terraform plan

# Apply updates
terraform apply

# Clean up old resources
terraform destroy -target=module.old_module
```

### **Backup and Recovery**
```bash
# Create backup
terraform state pull > backup-$(date +%Y%m%d).json

# Restore from backup
terraform state push backup-20241201.json

# Export specific resources
terraform state show module.aws_eks.aws_eks_cluster.main
```

## 📚 **Additional Resources**

### **Documentation**
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Elasticsearch Kubernetes Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/k8s-overview.html)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Azure AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)

### **Support**
- **GitHub Issues**: Report bugs and feature requests
- **Discussions**: Community support and questions
- **Documentation**: Comprehensive guides and examples
- **Examples**: Sample configurations and use cases

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### **Development Setup**
```bash
# Install pre-commit hooks
pre-commit install

# Run tests
terraform validate
terraform fmt -check
terraform plan

# Submit pull request
git push origin feature/your-feature
```

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎯 **Next Steps**

After successful deployment:

1. **Configure Kibana** for data visualization
2. **Set up monitoring** and alerting
3. **Configure backup** and disaster recovery
4. **Test cross-cloud** data replication
5. **Implement security** policies
6. **Set up CI/CD** pipelines

**Happy multi-cloud Elasticsearch deployment! 🚀**
