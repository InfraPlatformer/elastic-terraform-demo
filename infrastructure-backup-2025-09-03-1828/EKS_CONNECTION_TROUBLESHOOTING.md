# 🔌 EKS Connection Troubleshooting Guide

## Quick Fix Commands

### 1. Refresh EKS Token (Most Common Fix)
```powershell
aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-dev
```

### 2. Run the Auto-Refresh Script
```powershell
.\refresh-eks-connection.ps1
```

### 3. Manual Connection Test
```powershell
kubectl get nodes
```

## Permanent Solutions

### 1. AWS CLI Configuration
```powershell
# Set default region
aws configure set default.region us-west-2

# Verify configuration
aws configure list
```

### 2. EKS Cluster Access
```powershell
# Update cluster access
aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-dev

# Verify context
kubectl config current-context
```

### 3. Network Optimization
```powershell
# Set kubectl timeout
$env:KUBECTL_TIMEOUT = "30s"

# Use HTTP/2 (already configured in kubectl-config.yaml)
kubectl config set-cluster elasticsearch-cluster-dev --http2=true
```

## Common Issues & Solutions

### Issue: TLS Handshake Timeout
**Cause**: Expired or invalid authentication token
**Solution**: 
```powershell
aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-dev
```

### Issue: Connection Lost
**Cause**: Network instability or token expiration
**Solution**: 
```powershell
# Refresh token
aws eks get-token --cluster-name elasticsearch-cluster-dev --region us-west-2

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-dev
```

### Issue: HTTP/2 Client Connection Lost
**Cause**: HTTP/2 protocol issues
**Solution**: 
```powershell
# Force HTTP/1.1 (if HTTP/2 continues to fail)
kubectl config set-cluster elasticsearch-cluster-dev --http2=false
```

## Preventive Measures

### 1. Auto-Refresh Script
- Run `.\refresh-eks-connection.ps1` before important operations
- Schedule to run every 30 minutes during work hours

### 2. Environment Variables
```powershell
# Add to your PowerShell profile
$env:AWS_DEFAULT_REGION = "us-west-2"
$env:KUBECTL_TIMEOUT = "30s"
```

### 3. Regular Maintenance
```powershell
# Weekly token refresh
aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-dev

# Verify cluster health
kubectl cluster-info
```

## Monitoring & Alerts

### Check Cluster Health
```powershell
# Node status
kubectl get nodes

# Cluster info
kubectl cluster-info

# API server status
kubectl get apiservices
```

### Network Diagnostics
```powershell
# Test API server connectivity
kubectl version --client

# Check authentication
kubectl auth can-i get pods
```

## Emergency Procedures

### Complete Reset
```powershell
# 1. Clear kubeconfig
Remove-Item $env:USERPROFILE\.kube\config

# 2. Re-authenticate
aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-dev

# 3. Verify
kubectl get nodes
```

### Alternative Access Methods
```powershell
# Use AWS CLI directly
aws eks describe-cluster --region us-west-2 --name elasticsearch-cluster-dev

# Check cluster status
aws eks list-clusters --region us-west-2
```

## Support Resources

- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Kubernetes Troubleshooting**: https://kubernetes.io/docs/tasks/debug/
- **AWS Support**: If issues persist, contact AWS support

---

**Remember**: Most connection issues are resolved by refreshing the EKS token with `aws eks update-kubeconfig`
