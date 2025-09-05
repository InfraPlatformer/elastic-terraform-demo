# Deployment Checklist - Infrastructure Improvements

## 🚀 Pre-Deployment Steps

### 1. Review Changes
- [ ] **Review Terraform Plan:** Run `terraform plan` to see all changes
- [ ] **Validate Configuration:** Check for any syntax errors with `terraform validate`
- [ ] **Review Security Groups:** Verify new security group configurations
- [ ] **Check IAM Policies:** Review enhanced IAM role policies

### 2. Backup Current State
- [ ] **Backup Terraform State:** Copy current state files
- [ ] **Document Current Status:** Note any running resources
- [ ] **Snapshot EBS Volumes:** If any persistent data exists

## 🔧 Deployment Steps

### 1. Apply Infrastructure Changes
```bash
# Review the plan first
terraform plan -out=tfplan-improvements

# Apply the changes
terraform apply tfplan-improvements
```

### 2. Monitor Deployment Progress
- [ ] **Watch EKS Cluster:** Monitor cluster update progress
- [ ] **Check Node Groups:** Verify node group health
- [ ] **Validate Security Groups:** Confirm new rules are applied
- [ ] **Test IAM Permissions:** Verify role policies are attached

### 3. Validate Improvements
```powershell
# Run the validation script
.\validate-infrastructure.ps1

# Check specific components
.\validate-infrastructure.ps1 -Environment staging -Verbose
```

## ✅ Post-Deployment Validation

### 1. Infrastructure Health Check
- [ ] **VPC Configuration:** All subnets and routing tables
- [ ] **EKS Cluster:** Active status and proper version
- [ ] **Node Groups:** All in ACTIVE status
- [ ] **Security Groups:** Proper rules and access
- [ ] **IAM Roles:** All policies attached correctly

### 2. Application Connectivity Test
- [ ] **Elasticsearch Access:** Test internal and external connectivity
- [ ] **Kibana Access:** Verify web interface accessibility
- [ ] **Monitoring Stack:** Check Grafana, Prometheus access
- [ ] **Cross-Service Communication:** Verify inter-service connectivity

### 3. Security Validation
- [ ] **Security Group Rules:** Confirm least-privilege access
- [ ] **IAM Permissions:** Verify no overly permissive policies
- [ ] **Network Isolation:** Test proper segmentation
- [ ] **VPC Endpoints:** Verify private connectivity

## 🔍 Troubleshooting Steps

### 1. If Node Groups Fail
```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name advanced-elastic-staging-aws \
  --nodegroup-name advanced-elastic-staging-aws-elasticsearch \
  --region us-west-2

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids <security-group-id> \
  --region us-west-2
```

### 2. If Security Groups Have Issues
```bash
# Verify security group rules
aws ec2 describe-security-group-rules \
  --filters "Name=group-id,Values=<security-group-id>" \
  --region us-west-2

# Check VPC routing
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --region us-west-2
```

### 3. If IAM Permissions Fail
```bash
# Check role policies
aws iam list-attached-role-policies \
  --role-name <role-name>

# Verify inline policies
aws iam list-role-policies \
  --role-name <role-name>
```

## 📊 Monitoring and Maintenance

### 1. Regular Health Checks
- [ ] **Daily:** Run validation script during business hours
- [ ] **Weekly:** Review security group rules and IAM policies
- [ ] **Monthly:** Audit resource tags and cost allocation
- [ ] **Quarterly:** Review and update IAM permissions

### 2. Performance Monitoring
- [ ] **EKS Metrics:** Monitor cluster and node performance
- [ ] **Network Performance:** Track security group rule effectiveness
- [ ] **Cost Monitoring:** Watch for unexpected charges
- [ ] **Security Events:** Monitor for unauthorized access attempts

### 3. Documentation Updates
- [ ] **Update Runbooks:** Document any new troubleshooting steps
- [ ] **Maintain Checklists:** Keep deployment procedures current
- [ ] **Version Control:** Track infrastructure changes
- [ ] **Knowledge Sharing:** Share lessons learned with team

## 🚨 Rollback Plan

### 1. If Critical Issues Occur
```bash
# Revert to previous state
terraform plan -out=tfplan-rollback
terraform apply tfplan-rollback

# Or use specific state file
terraform apply -state=terraform.tfstate.backup
```

### 2. Emergency Procedures
- [ ] **Stop Deployment:** Halt any ongoing Terraform operations
- [ ] **Assess Impact:** Determine scope of issues
- [ ] **Communicate:** Notify stakeholders of problems
- [ ] **Document Issues:** Record what went wrong for future reference

## 📋 Success Criteria

### 1. Infrastructure Health
- [ ] All health indicators show ✅ (green)
- [ ] No critical errors in validation script
- [ ] All resources in expected states
- [ ] Security groups properly configured

### 2. Application Functionality
- [ ] Elasticsearch responds to health checks
- [ ] Kibana interface loads correctly
- [ ] Monitoring stack provides metrics
- [ ] Cross-service communication works

### 3. Security Compliance
- [ ] No overly permissive security group rules
- [ ] IAM policies follow least-privilege principle
- [ ] Network segmentation is effective
- [ ] All resources properly tagged

## 🔗 Useful Commands

### 1. Quick Status Checks
```bash
# Cluster status
aws eks describe-cluster --name advanced-elastic-staging-aws --region us-west-2

# Node group status
aws eks list-nodegroups --cluster-name advanced-elastic-staging-aws --region us-west-2

# Security group check
aws ec2 describe-security-groups --filters "Name=group-name,Values=*elastic*" --region us-west-2
```

### 2. Terraform Operations
```bash
# Validate configuration
terraform validate

# Format code
terraform fmt

# Check plan
terraform plan

# Apply changes
terraform apply
```

### 3. Kubernetes Operations
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name advanced-elastic-staging-aws

# Check nodes
kubectl get nodes

# Check pods
kubectl get pods --all-namespaces
```

---

**Checklist Version:** 1.0  
**Created:** August 23, 2025  
**Next Review:** After deployment completion
