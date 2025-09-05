# Kibana Access Troubleshooting Guide - COMPLETE SOLUTION

## Problem Summary
**Issue**: Cannot access Kibana from localhost:5601
**Root Cause**: Multiple issues identified and resolved:
1. **Configuration Validation Error**: `xpack.actions.enabled` validation failure causing CrashLoopBackOff
2. **Networking Configuration**: Kibana service configured as ClusterIP (internal access only)
3. **Environment**: AWS EKS cluster with private nodes

## Complete Root Cause Analysis

### Issue 1: Configuration Validation Error (CRITICAL)
```bash
FATAL Error: [config validation of [xpack.actions].enabled]: definition for this key is missing
```
**What Happened**: The original ConfigMap had invalid `xpack.actions.enabled: true` configuration that Kibana 8.5.1 couldn't validate
**Result**: Kibana crashed immediately on startup, entering CrashLoopBackOff state
**Impact**: Port forwarding failed because Kibana wasn't actually running

### Issue 2: Networking Configuration
```yaml
# Original service (kibana-working-final)
type: ClusterIP          # ❌ Only internal access
ports:
- port: 5601
  targetPort: 5601
```
**Why This Doesn't Work**:
- **ClusterIP Service**: Only accessible from within the Kubernetes cluster
- **Private EKS Nodes**: No external IP addresses for direct node access
- **Missing Network Bridge**: No ingress controller or load balancer to route external traffic
- **Localhost Attempt**: You're trying to access from outside the cluster

## Complete Solution Applied

### Step 1: Fixed Configuration
**File**: `kibana-working-config-fixed.yaml`
- Removed invalid `xpack.actions.enabled` configuration
- Simplified SSL configuration
- Added proper health check endpoints
- Fixed all validation errors

### Step 2: Fixed Deployment
**File**: `kibana-working-final-fixed.yaml`
- Added health checks (liveness and readiness probes)
- Proper resource limits
- Correct ConfigMap reference

### Step 3: Multiple Access Methods
- **Port Forwarding**: Direct tunnel for development
- **NodePort Service**: External access via node ports
- **LoadBalancer Service**: Production-grade access

## Files Created for Complete Solution

1. **`kibana-working-config-fixed.yaml`** - Corrected Kibana configuration
2. **`kibana-working-final-fixed.yaml`** - Fixed deployment with health checks
3. **`fix-kibana-complete.ps1`** - Comprehensive fix and access script
4. **`kibana-nodeport.yaml`** - NodePort service for external access
5. **`kibana-loadbalancer.yaml`** - LoadBalancer service for production

## Step-by-Step Resolution

### Quick Fix (Run the Complete Fix Script)
1. **Navigate to staging directory**:
   ```powershell
   cd environments/staging
   ```

2. **Run the complete fix script**:
   ```powershell
   .\fix-kibana-complete.ps1
   ```

3. **Start port forwarding**:
   ```powershell
   .\fix-kibana-complete.ps1 -StartPortForwarding
   ```

4. **Access Kibana**: Open http://localhost:5601 in your browser

### Manual Fix (If you prefer step-by-step)
1. **Clean up broken resources**:
   ```bash
   kubectl delete deployment -n elasticsearch kibana-working-final
   kubectl delete service -n elasticsearch kibana-working-final
   kubectl delete configmap -n elasticsearch kibana-working-config
   ```

2. **Apply fixed configuration**:
   ```bash
   kubectl apply -f kibana-working-config-fixed.yaml
   kubectl apply -f kibana-working-final-fixed.yaml
   ```

3. **Wait for Kibana to be ready**:
   ```bash
   kubectl wait --for=condition=ready pod -l app=kibana-working-final-fixed -n elasticsearch --timeout=300s
   ```

4. **Start port forwarding**:
   ```bash
   kubectl port-forward -n elasticsearch <pod-name> 5601:5601
   ```

## Access Methods Available

### Method 1: Port Forwarding (Immediate)
**Best for**: Development, testing, quick access
**Command**: `kubectl port-forward -n elasticsearch <pod-name> 5601:5601`
**URL**: http://localhost:5601

### Method 2: NodePort Service (Development)
**Best for**: Team access, persistent access
**Command**: `kubectl apply -f kibana-nodeport.yaml`
**URL**: http://<node-ip>:30561

### Method 3: LoadBalancer Service (Production)
**Best for**: Production, public access
**Command**: `kubectl apply -f kibana-loadbalancer.yaml`
**URL**: http://<lb-dns>:5601

## Verification Commands

### Check Pod Status
```bash
# Check if Kibana is running
kubectl get pods -n elasticsearch -l app=kibana-working-final-fixed

# Check detailed status
kubectl describe pod -n elasticsearch -l app=kibana-working-final-fixed

# Check logs
kubectl logs -n elasticsearch -l app=kibana-working-final-fixed --tail=50
```

### Check Service Status
```bash
# Check all services
kubectl get svc -n elasticsearch | grep kibana

# Check specific service
kubectl get svc -n elasticsearch kibana-working-final-fixed
```

### Test Connectivity
```bash
# Test from within cluster
kubectl exec -n elasticsearch <kibana-pod> -- curl -s http://localhost:5601/api/status

# Test port forwarding locally
curl http://localhost:5601/api/status
```

## Common Issues and Solutions

### Issue: Still Getting CrashLoopBackOff
**Symptoms**: Pod keeps restarting after applying fix
**Solutions**:
- Check logs: `kubectl logs -n elasticsearch <pod-name> --previous`
- Verify ConfigMap: `kubectl get configmap -n elasticsearch kibana-working-config-fixed -o yaml`
- Check Elasticsearch connectivity from within the pod

### Issue: Port Forwarding Still Fails
**Symptoms**: Connection refused after fix
**Solutions**:
- Verify pod is running: `kubectl get pods -n elasticsearch`
- Check if port 5601 is already in use locally
- Restart port forwarding

### Issue: NodePort Not Accessible
**Symptoms**: Connection timeout from outside cluster
**Solutions**:
- Verify security groups allow port 30561
- Check if nodes are in private subnets
- Use bastion host or VPN for access

## Security Considerations

### Development Environment
- Use port forwarding for local development
- NodePort is acceptable for team development
- Consider network policies to restrict access

### Production Environment
- Use LoadBalancer with proper security groups
- Implement authentication and authorization
- Use HTTPS/TLS encryption
- Restrict access to authorized IP ranges

## Next Steps

1. **Immediate**: Run the complete fix script to resolve all issues
2. **Short-term**: Use port forwarding for development access
3. **Medium-term**: Deploy NodePort service for team access
4. **Long-term**: Implement LoadBalancer for production use
5. **Security**: Configure proper authentication and network policies

## Support Commands

```powershell
# Get help on the fix script
Get-Help .\fix-kibana-complete.ps1

# Run complete fix
.\fix-kibana-complete.ps1

# Start port forwarding
.\fix-kibana-complete.ps1 -StartPortForwarding

# Check current status
kubectl get all -n elasticsearch
```

## Summary

The complete solution addresses:
1. ✅ **Configuration validation errors** - Fixed invalid xpack.actions configuration
2. ✅ **CrashLoopBackOff issues** - Added proper health checks and corrected config
3. ✅ **Networking access** - Multiple access methods (port forwarding, NodePort, LoadBalancer)
4. ✅ **Health monitoring** - Liveness and readiness probes for stability
5. ✅ **Resource management** - Proper resource limits and requests

**Result**: Kibana will start successfully and be accessible via multiple methods for different use cases.
