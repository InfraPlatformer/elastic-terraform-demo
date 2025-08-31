# 🚨 Troubleshooting Guide

## 🔍 Quick Diagnosis

### **Check GitHub Actions Status**
1. Go to **Actions** tab in your repository
2. Look for **failed workflows** or **error messages**
3. Check **job logs** for specific error details

### **Check Infrastructure Status**
```bash
# AWS EKS Status
aws eks describe-cluster --name advanced-elastic-staging-aws --region us-west-2

# Azure AKS Status
az aks show --resource-group multi-cloud-elastic-rg --name advanced-elastic-staging-azure

# Terraform State
terraform show
terraform state list
```

## 🚨 Common Issues & Solutions

### **Issue 1: CI/CD Pipeline Fails**

#### **Problem**: GitHub Actions workflow fails to start
**Symptoms**: No workflow runs, or workflow shows as failed
**Root Cause**: Repository configuration issues

**Solutions**:
1. **Check workflow file syntax**
   ```bash
   # Validate YAML syntax
   yamllint .github/workflows/terraform-ci-cd.yml
   ```

2. **Verify trigger paths**
   - Ensure workflow triggers on correct file changes
   - Check branch protection rules

3. **Review workflow permissions**
   - Verify repository has Actions enabled
   - Check organization-level restrictions

#### **Problem**: Terraform validation fails
**Symptoms**: "Terraform Validate" job fails
**Root Cause**: Terraform configuration errors

**Solutions**:
1. **Check Terraform syntax**
   ```bash
   terraform fmt -check -recursive
   terraform validate
   ```

2. **Verify provider versions**
   ```bash
   terraform version
   # Ensure version matches .terraform.lock.hcl
   ```

3. **Check variable definitions**
   - Verify all required variables are defined
   - Check variable types and validation rules

### **Issue 2: AWS Authentication Fails**

#### **Problem**: "Invalid credentials" error
**Symptoms**: AWS-related jobs fail with authentication errors
**Root Cause**: Invalid or expired AWS credentials

**Solutions**:
1. **Verify GitHub secrets**
   - Check `AWS_ACCESS_KEY_ID_*` secrets exist
   - Verify `AWS_SECRET_ACCESS_KEY_*` secrets exist
   - Ensure secrets are in correct environments

2. **Test credentials locally**
   ```bash
   aws configure list
   aws sts get-caller-identity
   ```

3. **Check IAM permissions**
   - Verify IAM user has required policies
   - Check for policy restrictions or conditions

#### **Problem**: "Access denied" error
**Symptoms**: AWS operations fail with permission errors
**Root Cause**: Insufficient IAM permissions

**Solutions**:
1. **Required IAM policies**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "eks:*",
           "ec2:*",
           "iam:*",
           "s3:*"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

2. **Check resource-level permissions**
   - Verify access to specific VPCs, subnets
   - Check for resource tags or naming restrictions

### **Issue 3: Azure Authentication Fails**

#### **Problem**: "Invalid service principal" error
**Symptoms**: Azure-related jobs fail with authentication errors
**Root Cause**: Invalid or expired Azure service principal

**Solutions**:
1. **Verify GitHub secret**
   - Check `AZURE_CREDENTIALS` secret exists
   - Ensure JSON format is correct
   - Verify secret hasn't expired

2. **Test credentials locally**
   ```bash
   az login --service-principal \
     --username [clientId] \
     --password [clientSecret] \
     --tenant [tenantId]
   ```

3. **Check service principal permissions**
   ```bash
   az role assignment list --assignee [clientId]
   ```

#### **Problem**: "Insufficient permissions" error
**Symptoms**: Azure operations fail with permission errors
**Root Cause**: Service principal lacks required roles

**Solutions**:
1. **Required Azure roles**
   ```bash
   # Contributor role for resource management
   az role assignment create \
     --assignee [clientId] \
     --role Contributor \
     --scope /subscriptions/[subscriptionId]
   ```

2. **Check subscription access**
   ```bash
   az account show
   az account list
   ```

### **Issue 4: Multi-Cloud Deployment Fails**

#### **Problem**: EKS cluster creation fails
**Symptoms**: AWS EKS cluster creation times out or fails
**Root Cause**: VPC, subnet, or IAM configuration issues

**Solutions**:
1. **Check VPC configuration**
   ```bash
   aws ec2 describe-vpcs --vpc-ids [vpc-id]
   aws ec2 describe-subnets --subnet-ids [subnet-id]
   ```

2. **Verify IAM roles**
   ```bash
   aws iam get-role --role-name [role-name]
   aws iam list-attached-role-policies --role-name [role-name]
   ```

3. **Check resource limits**
   ```bash
   aws service-quotas get-service-quota \
     --service-code eks \
     --quota-code L-1194AF3C
   ```

#### **Problem**: AKS cluster creation fails
**Symptoms**: Azure AKS cluster creation fails
**Root Cause**: Resource group, VNet, or service principal issues

**Solutions**:
1. **Check resource group**
   ```bash
   az group show --name multi-cloud-elastic-rg
   az group create --name multi-cloud-elastic-rg --location "West US 2"
   ```

2. **Verify VNet configuration**
   ```bash
   az network vnet show --name [vnet-name] --resource-group [rg-name]
   ```

3. **Check service principal permissions**
   ```bash
   az role assignment list --assignee [clientId] --scope /subscriptions/[subscriptionId]
   ```

### **Issue 5: Cross-Cloud Communication Fails**

#### **Problem**: Elasticsearch nodes can't communicate
**Symptoms**: Elasticsearch cluster health shows red status
**Root Cause**: Network connectivity or security group issues

**Solutions**:
1. **Check security group rules**
   ```bash
   # AWS security groups
   aws ec2 describe-security-groups --group-ids [sg-id]
   
   # Azure NSGs
   az network nsg rule list --nsg-name [nsg-name] --resource-group [rg-name]
   ```

2. **Verify network peering**
   - Check if VPC peering is configured
   - Verify route tables are updated
   - Test DNS resolution between clouds

3. **Test connectivity**
   ```bash
   # From AWS to Azure
   kubectl exec -n elasticsearch deployment/elasticsearch-aws -- ping [azure-ip]
   
   # From Azure to AWS
   kubectl exec -n elasticsearch deployment/elasticsearch-azure -- ping [aws-ip]
   ```

### **Issue 6: Monitoring Stack Issues**

#### **Problem**: Prometheus can't scrape metrics
**Symptoms**: No metrics in Grafana dashboards
**Root Cause**: Service discovery or RBAC configuration issues

**Solutions**:
1. **Check service discovery**
   ```bash
   kubectl get endpoints -n monitoring
   kubectl get services -n monitoring
   ```

2. **Verify RBAC permissions**
   ```bash
   kubectl get clusterrolebinding | grep prometheus
   kubectl get clusterrole | grep prometheus
   ```

3. **Check Prometheus configuration**
   ```bash
   kubectl get configmap -n monitoring prometheus-server
   kubectl logs -n monitoring deployment/prometheus-server
   ```

## 🔧 Debug Commands

### **Infrastructure Debugging**
```bash
# Check Terraform state
terraform show
terraform state list
terraform plan -refresh-only

# Check AWS resources
aws eks list-clusters --region us-west-2
aws ec2 describe-instances --filters "Name=tag:Name,Values=*eks*"

# Check Azure resources
az aks list --resource-group multi-cloud-elastic-rg
az vm list --resource-group multi-cloud-elastic-rg
```

### **Kubernetes Debugging**
```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces

# Check pod logs
kubectl logs -n elasticsearch deployment/elasticsearch-aws
kubectl logs -n monitoring deployment/prometheus-server

# Check pod events
kubectl describe pod -n elasticsearch [pod-name]
kubectl get events --sort-by='.lastTimestamp'
```

### **Network Debugging**
```bash
# Check DNS resolution
kubectl exec -it -n elasticsearch deployment/elasticsearch-aws -- nslookup [service-name]

# Check network policies
kubectl get networkpolicies --all-namespaces
kubectl describe networkpolicy -n [namespace] [policy-name]

# Test connectivity
kubectl exec -it -n elasticsearch deployment/elasticsearch-aws -- curl -v [endpoint]
```

## 📊 Performance Issues

### **Slow Deployment**
**Symptoms**: CI/CD pipeline takes too long
**Solutions**:
1. **Optimize Terraform operations**
   - Use `-parallelism` flag
   - Enable Terraform caching
   - Use remote state storage

2. **Optimize GitHub Actions**
   - Use larger runners for compute-intensive jobs
   - Enable dependency caching
   - Parallel job execution

### **High Resource Usage**
**Symptoms**: Infrastructure costs are high
**Solutions**:
1. **Right-size instances**
   - Use spot instances for non-critical workloads
   - Enable auto-scaling
   - Monitor and optimize resource allocation

2. **Cost optimization**
   - Use reserved instances for production
   - Implement resource tagging
   - Regular cost reviews

## 🚨 Emergency Procedures

### **Infrastructure Rollback**
```bash
# Rollback to previous Terraform state
terraform plan -refresh-only
terraform apply -auto-approve

# Or use specific state file
terraform apply -state=terraform.tfstate.backup
```

### **Emergency Cleanup**
```bash
# Destroy specific resources
terraform destroy -target=module.aws_eks
terraform destroy -target=module.azure_aks

# Complete cleanup
terraform destroy -auto-approve
```

### **Data Recovery**
```bash
# Restore from backup
kubectl apply -f backup/elasticsearch-backup.yaml

# Verify data integrity
kubectl exec -n elasticsearch deployment/elasticsearch-aws -- curl -s localhost:9200/_cat/indices
```

## 📞 Getting Help

### **Documentation Resources**
- **Project Structure**: `.github/docs/PROJECT_STRUCTURE.md`
- **Deployment Guide**: `.github/docs/DEPLOYMENT_GUIDE.md`
- **GitHub Secrets**: `.github/SETUP_SECRETS.md`

### **External Resources**
- **Terraform Documentation**: https://www.terraform.io/docs
- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Azure AKS Documentation**: https://docs.microsoft.com/azure/aks/
- **Kubernetes Documentation**: https://kubernetes.io/docs/

### **Support Channels**
1. **GitHub Issues**: Create detailed issue with error logs
2. **GitHub Discussions**: Community support and questions
3. **Cloud Provider Support**: AWS Support, Azure Support
4. **Stack Overflow**: Tag with relevant technologies

---

**This troubleshooting guide covers the most common issues and provides step-by-step solutions for your multi-cloud infrastructure.** 🚀
