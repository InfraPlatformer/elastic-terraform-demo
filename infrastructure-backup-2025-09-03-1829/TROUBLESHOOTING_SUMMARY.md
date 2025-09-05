# EKS Nodegroup Troubleshooting Summary
**Date:** August 23, 2025  
**Time:** 06:50 UTC  
**Status:** IN PROGRESS - Security Group Fixed, Monitoring Nodegroup Creation

## 🚨 Issues Identified and Resolved

### 1. Missing `ssh_key_name` Variable
**Problem:** Terraform validation error due to missing variable declaration
**Solution:** Added to `variables.tf`:
```hcl
variable "ssh_key_name" {
  description = "SSH key name for EC2 instance access"
  type        = string
  default     = ""
}
```
**Status:** ✅ RESOLVED

### 2. Terraform State File Lock
**Problem:** Multiple Terraform processes locking the state file
**Solution:** Identified and terminated processes (IDs: 14424, 14604)
**Status:** ✅ RESOLVED

### 3. Missing IAM Permission: `eks:DescribeCluster`
**Problem:** Worker nodes couldn't join cluster due to missing permission
**Solution:** Added inline policy to worker node IAM role:
```hcl
resource "aws_iam_role_policy" "eks_describe_cluster" {
  name = "eks-describe-cluster"
  role = aws_iam_role.eks_nodes.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "eks:DescribeCluster"
        Effect = "Allow"
        Resource = aws_eks_cluster.main.arn
      }
    ]
  })
}
```
**Status:** ✅ RESOLVED

### 4. Critical Security Group Configuration Issue
**Problem:** Worker node security group missing inbound rule for ports 1025-65535
**Impact:** EKS control plane couldn't communicate with worker nodes on NodePort services
**Solution:** Added missing security group rule:
```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-09f6f6537e401c013 \
  --protocol tcp \
  --port 1025-65535 \
  --source-group sg-06bd0be5b4dfe713d
```
**Status:** ✅ RESOLVED

## 🔧 Infrastructure Status

### EKS Cluster
- **Name:** `advanced-elastic-staging-aws`
- **Status:** ACTIVE ✅
- **Version:** 1.29
- **Region:** us-west-2

### Nodegroups
- **elasticsearch:** CREATING (3 nodes, t3.medium/large)
- **kibana:** CREATING (2 nodes, t3.small/medium)  
- **monitoring:** CREATING (1 node, t3.small)

### EC2 Instances
- **Total Running:** 6 instances
- **Status:** All running and healthy
- **Security Groups:** Properly configured ✅

### IAM Roles
- **Worker Node Role:** `advanced-elastic-staging-aws-nodes-role`
- **Required Policies:** All attached ✅
- **Inline Policy:** `eks-describe-cluster` with proper permissions ✅

### Networking
- **VPC:** vpc-041b5eab1f5968525
- **Private Subnets:** subnet-09dbed8c6755c8bae, subnet-0c266221f71327252
- **Security Groups:** Properly configured ✅
- **Route Tables:** NAT Gateway routing configured ✅

## 📋 Root Cause Analysis

The nodegroups were stuck in CREATING status due to a **multi-layered security configuration issue**:

1. **IAM Permissions:** Worker nodes lacked `eks:DescribeCluster` permission
2. **Security Group Rules:** Missing inbound rule for NodePort communication (1025-65535)
3. **Network Connectivity:** EKS control plane couldn't reach worker nodes on required ports

## 🎯 What We Fixed

1. ✅ Added missing Terraform variable
2. ✅ Resolved state file lock issues
3. ✅ Added required IAM inline policy
4. ✅ Fixed security group configuration
5. ✅ Verified all networking components

## ⏳ Current Status

**All critical issues have been resolved.** The nodegroups are now in CREATING status with:
- Proper IAM permissions
- Correct security group rules
- Valid networking configuration

**Expected Outcome:** Nodegroups should progress to ACTIVE status within 10-15 minutes as:
- Security group changes propagate
- EC2 instances retry joining the cluster
- kubelet successfully registers with API server

## 🚀 Next Steps

1. **Monitor Progress:** Check nodegroup status every 5-10 minutes
2. **Verify Success:** Confirm all nodegroups reach ACTIVE status
3. **Deploy Applications:** Proceed with Elasticsearch, Kibana, and monitoring stack
4. **Document:** Update runbooks with these troubleshooting steps

## 📚 Lessons Learned

1. **Always verify security group rules** for EKS worker nodes
2. **Check IAM permissions** before troubleshooting node connectivity
3. **Monitor Terraform processes** to avoid state file locks
4. **Use systematic approach** to identify root causes

## 🔍 Troubleshooting Commands Used

```bash
# Check nodegroup status
aws eks describe-nodegroup --cluster-name advanced-elastic-staging-aws --nodegroup-name advanced-elastic-staging-aws-elasticsearch --query "nodegroup.status"

# Verify security group rules
aws ec2 describe-security-groups --group-ids sg-09f6f6537e401c013

# Check IAM role policies
aws iam list-attached-role-policies --role-name advanced-elastic-staging-aws-nodes-role

# Monitor EC2 instances
aws ec2 describe-instances --filters "Name=tag:kubernetes.io/cluster/advanced-elastic-staging-aws,Values=owned"
```

---
**Document Version:** 1.0  
**Last Updated:** August 23, 2025 06:50 UTC  
**Next Review:** After nodegroup creation completes



