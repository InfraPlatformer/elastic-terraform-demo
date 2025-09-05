# 🌐 Kibana Customer Access Guide

## 📋 Overview

This guide provides complete instructions for accessing Kibana in your Elasticsearch cluster. Kibana is deployed with multiple access options to suit different use cases and security requirements.

## 🚀 Quick Start

### Option 1: Port Forwarding (Recommended for Development)
**Best for**: Development, testing, secure access
**Cost**: Free
**Security**: High (local access only)

```bash
# Start port forwarding
kubectl port-forward -n elasticsearch kibana-production-<pod-id> 5601:5601

# Access Kibana
# URL: http://localhost:5601
```

### Option 2: LoadBalancer (Recommended for Production)
**Best for**: Production, team access, public access
**Cost**: ~$20/month (AWS LoadBalancer)
**Security**: Medium (publicly accessible)

```bash
# Get LoadBalancer URL
kubectl get svc -n elasticsearch kibana-loadbalancer

# Access Kibana
# URL: http://<loadbalancer-url>:5601
```

### Option 3: NodePort (Advanced)
**Best for**: Custom networking, VPN access
**Cost**: Free
**Security**: Configurable (requires security group setup)

```bash
# Get NodePort
kubectl get svc -n elasticsearch kibana-nodeport

# Access via any node IP on port 30561
# URL: http://<node-ip>:30561
```

## 🔐 Login Credentials

- **Username**: `elastic`
- **Password**: `FvpVTCwGVctECzqt`

## 📖 Detailed Instructions

### Method 1: Port Forwarding

1. **Start Port Forwarding**:
   ```bash
   # Get the Kibana pod name
   kubectl get pods -n elasticsearch -l app=kibana-production
   
   # Start port forwarding (replace <pod-name> with actual pod name)
   kubectl port-forward -n elasticsearch <pod-name> 5601:5601
   ```

2. **Access Kibana**:
   - Open your browser
   - Navigate to: `http://localhost:5601`
   - Login with the credentials above

3. **Stop Port Forwarding**:
   - Press `Ctrl+C` in the terminal

### Method 2: LoadBalancer (Public Access)

1. **Get LoadBalancer URL**:
   ```bash
   kubectl get svc -n elasticsearch kibana-loadbalancer
   ```

2. **Access Kibana**:
   - Open your browser
   - Navigate to: `http://<loadbalancer-url>:5601`
   - Login with the credentials above

3. **Note**: This creates a public endpoint that anyone can access

### Method 3: NodePort (Advanced)

1. **Get Node Information**:
   ```bash
   # Get node IPs
   kubectl get nodes -o wide
   
   # Get NodePort
   kubectl get svc -n elasticsearch kibana-nodeport
   ```

2. **Configure Security Groups** (Required):
   ```bash
   # Get cluster security group
   aws eks describe-cluster --name <cluster-name> --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text
   
   # Add inbound rule for port 30561
   aws ec2 authorize-security-group-ingress \
       --group-id <security-group-id> \
       --protocol tcp \
       --port 30561 \
       --cidr 0.0.0.0/0
   ```

3. **Access Kibana**:
   - Open your browser
   - Navigate to: `http://<node-ip>:30561`
   - Login with the credentials above

## 🛠️ Troubleshooting

### Kibana Not Accessible

1. **Check Pod Status**:
   ```bash
   kubectl get pods -n elasticsearch -l app=kibana-production
   ```

2. **Check Logs**:
   ```bash
   kubectl logs -n elasticsearch -l app=kibana-production
   ```

3. **Check Services**:
   ```bash
   kubectl get svc -n elasticsearch
   ```

### Port Forwarding Issues

1. **Verify Pod is Running**:
   ```bash
   kubectl get pods -n elasticsearch -l app=kibana-production
   ```

2. **Check Port Forwarding**:
   ```bash
   # Test if port forwarding is working
   curl http://localhost:5601/api/status
   ```

### LoadBalancer Issues

1. **Check LoadBalancer Status**:
   ```bash
   kubectl get svc -n elasticsearch kibana-loadbalancer
   ```

2. **Wait for External IP**:
   - LoadBalancer creation can take 2-5 minutes
   - Check AWS Console for LoadBalancer status

### NodePort Issues

1. **Verify Security Groups**:
   ```bash
   # Check if port 30561 is open
   aws ec2 describe-security-groups --group-ids <security-group-id>
   ```

2. **Test from Within Cluster**:
   ```bash
   kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://<node-ip>:30561/api/status
   ```

## 🔧 Management Commands

### Check Kibana Status
```bash
# Pod status
kubectl get pods -n elasticsearch -l app=kibana-production

# Service status
kubectl get svc -n elasticsearch

# Logs
kubectl logs -n elasticsearch -l app=kibana-production
```

### Restart Kibana
```bash
kubectl rollout restart deployment -n elasticsearch kibana-production
```

### Scale Kibana
```bash
# Scale to 2 replicas
kubectl scale deployment -n elasticsearch kibana-production --replicas=2
```

### Update Configuration
```bash
# Edit configuration
kubectl edit configmap -n elasticsearch kibana-production-config

# Restart to apply changes
kubectl rollout restart deployment -n elasticsearch kibana-production
```

## 🚨 Security Considerations

### Port Forwarding
- ✅ Most secure option
- ✅ No additional AWS costs
- ✅ Local access only
- ❌ Requires kubectl command

### LoadBalancer
- ⚠️ Publicly accessible
- ⚠️ Additional AWS costs (~$20/month)
- ✅ No kubectl required
- ✅ Team access friendly

### NodePort
- ⚠️ Requires security group configuration
- ✅ No additional AWS costs
- ✅ Flexible networking options
- ❌ More complex setup

## 📞 Support

If you encounter issues:

1. **Check the troubleshooting section above**
2. **Verify your kubectl configuration**: `kubectl config current-context`
3. **Check cluster connectivity**: `kubectl get nodes`
4. **Review Kibana logs**: `kubectl logs -n elasticsearch -l app=kibana-production`

## 🎯 Best Practices

1. **Development**: Use Port Forwarding
2. **Production**: Use LoadBalancer with proper security
3. **Team Access**: Use LoadBalancer
4. **Custom Networking**: Use NodePort with VPN
5. **Always**: Use strong passwords and consider SSL certificates for production

## 📊 Monitoring

### Health Checks
```bash
# Check Kibana health
curl http://localhost:5601/api/status

# Check Elasticsearch connection
curl http://localhost:5601/api/status?pretty
```

### Performance Monitoring
```bash
# Check resource usage
kubectl top pods -n elasticsearch

# Check events
kubectl get events -n elasticsearch --sort-by='.lastTimestamp'
```

---

**🎉 You're all set! Choose your preferred access method and start using Kibana!**

