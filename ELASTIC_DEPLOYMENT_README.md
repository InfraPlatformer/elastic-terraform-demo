# Elasticsearch and Kibana Deployment Guide

This guide explains how to deploy a complete Elasticsearch and Kibana infrastructure on AWS EKS using Terraform.

## 🏗️ Infrastructure Overview

The deployment creates:
- **VPC with private/public subnets** across 2 availability zones
- **EKS cluster** with dedicated node groups for Elasticsearch and monitoring
- **Security groups** with production-ready security rules
- **Elasticsearch and Kibana** deployed using Helm charts
- **LoadBalancer services** for external access

## 📋 Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** (version 1.11.4 or later)
3. **kubectl** installed
4. **Helm** installed (version 3.0.0 or later)
5. **PowerShell** (for Windows deployment script)

## 🚀 Deployment Steps

### Step 1: Deploy Infrastructure with Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

This will create:
- VPC and networking components
- EKS cluster with node groups
- Security groups and IAM roles
- Namespaces for Elasticsearch and Kibana

### Step 2: Deploy Elasticsearch and Kibana

After Terraform completes successfully, run the deployment script:

```powershell
# Run the deployment script
.\deploy-elastic.ps1

# Or with custom parameters
.\deploy-elastic.ps1 -ClusterName "my-cluster" -Region "us-east-1"
```

The script will:
1. Update kubeconfig to connect to the EKS cluster
2. Create namespaces
3. Deploy Elasticsearch using Helm
4. Wait for Elasticsearch to be ready
5. Deploy Kibana using Helm
6. Wait for Kibana to be ready
7. Create LoadBalancer services for external access

## 🔍 Verification Commands

### Check Infrastructure Status
```bash
# Check EKS cluster
aws eks describe-cluster --name advanced-elastic-staging-aws --region us-west-2

# Check node groups
aws eks list-nodegroups --cluster-name advanced-elastic-staging-aws --region us-west-2
```

### Check Kubernetes Resources
```bash
# Check namespaces
kubectl get namespaces

# Check Elasticsearch pods
kubectl get pods -n elasticsearch

# Check Kibana pods
kubectl get pods -n kibana

# Check services
kubectl get svc -n elasticsearch
kubectl get svc -n kibana
```

### Check Application Health
```bash
# Check Elasticsearch health
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/health

# Check Kibana status
kubectl exec -n kibana deployment/kibana -- curl -s http://localhost:5601/api/status
```

## 🌐 Access URLs

After deployment, you can access:

- **Elasticsearch**: `http://<elasticsearch-lb-endpoint>:9200`
- **Kibana**: `http://<kibana-lb-endpoint>:5601`

To get the LoadBalancer endpoints:
```bash
kubectl get svc -n elasticsearch elasticsearch-external
kubectl get svc -n kibana kibana-external
```

## 🔧 Troubleshooting

### Common Issues

1. **Pods stuck in ContainerCreating**
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   kubectl get events -n <namespace> --sort-by='.lastTimestamp'
   ```

2. **Image pull issues**
   ```bash
   kubectl describe pod <pod-name> -n <namespace> | grep -i image
   ```

3. **Storage issues**
   ```bash
   kubectl get pvc -n <namespace>
   kubectl describe pvc <pvc-name> -n <namespace>
   ```

4. **Network connectivity**
   ```bash
   kubectl exec -it <pod-name> -n <namespace> -- nslookup elasticsearch-elasticsearch.elasticsearch.svc.cluster.local
   ```

### Reset Deployment

If you need to start over:

```bash
# Delete Helm releases
helm uninstall kibana -n kibana
helm uninstall elasticsearch -n elasticsearch

# Delete namespaces
kubectl delete namespace kibana
kubectl delete namespace elasticsearch

# Re-run deployment script
.\deploy-elastic.ps1
```

## 📊 Monitoring and Scaling

### Resource Monitoring
```bash
# Check resource usage
kubectl top pods -n elasticsearch
kubectl top pods -n kibana

# Check node resources
kubectl top nodes
```

### Scaling
```bash
# Scale Elasticsearch
kubectl scale deployment elasticsearch -n elasticsearch --replicas=3

# Scale Kibana
kubectl scale deployment kibana -n kibana --replicas=2
```

## 🔒 Security Considerations

The current deployment has security disabled for simplicity. For production:

1. Enable X-Pack security
2. Configure TLS certificates
3. Set up authentication and authorization
4. Enable audit logging
5. Configure network policies

## 📝 Configuration Files

- **`main.tf`**: Main Terraform configuration
- **`elastic-deployment.tf`**: Elasticsearch and Kibana Terraform resources (commented out)
- **`deploy-elastic.ps1`**: PowerShell deployment script
- **`variables.tf`**: Terraform variables
- **`environments/`**: Environment-specific variable files

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Terraform and Kubernetes logs
3. Verify AWS permissions and quotas
4. Check network connectivity and security groups

## 📚 Additional Resources

- [Elasticsearch Helm Chart Documentation](https://github.com/elastic/helm-charts/tree/main/elasticsearch)
- [Kibana Helm Chart Documentation](https://github.com/elastic/helm-charts/tree/main/kibana)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)



