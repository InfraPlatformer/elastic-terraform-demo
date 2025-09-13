# 🛠️ Troubleshooting Guide

This guide helps you diagnose and resolve common issues when deploying and using the Elastic Stack on AWS.

## 📋 Table of Contents

- [Prerequisites Issues](#-prerequisites-issues)
- [Infrastructure Issues](#-infrastructure-issues)
- [Application Issues](#-application-issues)
- [Connectivity Issues](#-connectivity-issues)
- [Performance Issues](#-performance-issues)
- [Security Issues](#-security-issues)
- [Data Issues](#-data-issues)
- [Monitoring Issues](#-monitoring-issues)

## 🔧 Prerequisites Issues

### AWS CLI Not Configured

**Problem**: `aws: command not found` or `Unable to locate credentials`

**Solution**:
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure credentials
aws configure
# Enter your Access Key ID, Secret Access Key, and region
```

### Terraform Not Installed

**Problem**: `terraform: command not found`

**Solution**:
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### kubectl Not Installed

**Problem**: `kubectl: command not found`

**Solution**:
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

## 🏗️ Infrastructure Issues

### EKS Cluster Creation Fails

**Problem**: `Error creating EKS cluster: Insufficient capacity`

**Solution**:
1. Try a different availability zone
2. Use different instance types
3. Reduce the number of nodes initially

```bash
# Check available instance types in your region
aws ec2 describe-instance-type-offerings --location-type availability-zone --filters Name=instance-type,Values=t3.large --query 'InstanceTypeOfferings[].InstanceType' --output table
```

### VPC Creation Issues

**Problem**: `Error creating VPC: VPC limit exceeded`

**Solution**:
1. Delete unused VPCs
2. Request a limit increase
3. Use an existing VPC

```bash
# List existing VPCs
aws ec2 describe-vpcs --query 'Vpcs[].{VpcId:VpcId,State:State,CidrBlock:CidrBlock}' --output table

# Delete unused VPCs
aws ec2 delete-vpc --vpc-id vpc-xxxxxxxxx
```

### NAT Gateway Issues

**Problem**: `Error creating NAT Gateway: Insufficient capacity`

**Solution**:
1. Try different availability zones
2. Use a different region
3. Check your account limits

```bash
# Check NAT Gateway limits
aws service-quotas get-service-quota --service-code vpc --quota-code L-FE5A380F
```

## 📦 Application Issues

### Pods Not Starting

**Problem**: Pods stuck in `Pending` or `CrashLoopBackOff` state

**Diagnosis**:
```bash
# Check pod status
kubectl get pods --all-namespaces

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check pod logs
kubectl logs <pod-name> -n <namespace>
```

**Common Solutions**:

1. **Insufficient Resources**:
```bash
# Check node resources
kubectl top nodes

# Check pod resource requests
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Requests:"
```

2. **Image Pull Issues**:
```bash
# Check if image exists
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Events:"

# Fix image pull secrets if needed
kubectl create secret docker-registry regcred \
  --docker-server=<registry-server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>
```

3. **Storage Issues**:
```bash
# Check persistent volumes
kubectl get pv,pvc --all-namespaces

# Check storage class
kubectl get storageclass
```

### Elasticsearch Cluster Not Healthy

**Problem**: Cluster status is `yellow` or `red`

**Diagnosis**:
```bash
# Check cluster health
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/health

# Check cluster settings
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/settings
```

**Solutions**:

1. **Yellow Status** (usually normal for single-node clusters):
```bash
# This is expected for single-node clusters
# No action needed unless you need high availability
```

2. **Red Status**:
```bash
# Check for unassigned shards
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cat/shards?v

# Check cluster allocation
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/allocation/explain
```

### Kibana Not Loading

**Problem**: Kibana shows "Kibana server is not ready yet"

**Diagnosis**:
```bash
# Check Kibana logs
kubectl logs -n kibana deployment/kibana

# Check if Elasticsearch is accessible from Kibana
kubectl exec -n kibana deployment/kibana -- curl -s http://elasticsearch.elasticsearch.svc.cluster.local:9200
```

**Solutions**:

1. **Elasticsearch Connection Issues**:
```bash
# Check service connectivity
kubectl get svc -n elasticsearch

# Test internal connectivity
kubectl exec -n kibana deployment/kibana -- nslookup elasticsearch.elasticsearch.svc.cluster.local
```

2. **Configuration Issues**:
```bash
# Check Kibana configuration
kubectl get configmap -n kibana

# Update configuration if needed
kubectl edit configmap kibana-config -n kibana
```

## 🌐 Connectivity Issues

### Cannot Access Services

**Problem**: Cannot access Kibana, Grafana, or Elasticsearch from outside the cluster

**Diagnosis**:
```bash
# Check LoadBalancer services
kubectl get svc --all-namespaces

# Check ingress
kubectl get ingress --all-namespaces

# Check security groups
aws ec2 describe-security-groups --group-ids <security-group-id>
```

**Solutions**:

1. **LoadBalancer Not Created**:
```bash
# Check if LoadBalancer controller is installed
kubectl get pods -n kube-system | grep aws-load-balancer

# Install AWS Load Balancer Controller if missing
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name>
```

2. **Security Group Issues**:
```bash
# Update security group to allow traffic
aws ec2 authorize-security-group-ingress \
  --group-id <security-group-id> \
  --protocol tcp \
  --port 5601 \
  --cidr 0.0.0.0/0
```

### Port-Forward Not Working

**Problem**: `kubectl port-forward` fails or times out

**Solutions**:
```bash
# Check if pod is running
kubectl get pods -n <namespace>

# Try different local port
kubectl port-forward -n <namespace> svc/<service-name> 8080:5601

# Check if port is already in use
netstat -tulpn | grep :5601
```

## ⚡ Performance Issues

### Slow Query Performance

**Problem**: Elasticsearch queries are slow

**Diagnosis**:
```bash
# Check cluster performance
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_nodes/stats

# Check slow queries
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_nodes/stats/indices/search
```

**Solutions**:

1. **Increase Resources**:
```bash
# Update resource requests and limits
kubectl edit deployment elasticsearch -n elasticsearch
```

2. **Optimize Queries**:
```bash
# Use explain API to analyze queries
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/ecommerce-products/_search \
  -H "Content-Type: application/json" \
  -d '{"query":{"match_all":{}},"explain":true}'
```

### High Memory Usage

**Problem**: Pods are using too much memory

**Diagnosis**:
```bash
# Check memory usage
kubectl top pods --all-namespaces

# Check memory limits
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Limits:"
```

**Solutions**:

1. **Adjust Memory Limits**:
```bash
# Update memory limits
kubectl edit deployment <deployment-name> -n <namespace>
```

2. **Optimize Elasticsearch Settings**:
```bash
# Update Elasticsearch heap size
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/_cluster/settings" \
  -H "Content-Type: application/json" \
  -d '{"persistent":{"indices.memory.index_buffer_size":"20%"}}'
```

## 🔒 Security Issues

### Authentication Failures

**Problem**: Cannot authenticate with Elasticsearch or Kibana

**Diagnosis**:
```bash
# Check security settings
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_xpack/security/status

# Check user configuration
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_security/user
```

**Solutions**:

1. **Enable Security**:
```bash
# Enable X-Pack security
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/_cluster/settings" \
  -H "Content-Type: application/json" \
  -d '{"persistent":{"xpack.security.enabled":true}}'
```

2. **Create Users**:
```bash
# Create admin user
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X POST "localhost:9200/_security/user/admin" \
  -H "Content-Type: application/json" \
  -d '{"password":"admin123","roles":["superuser"]}'
```

### SSL/TLS Issues

**Problem**: SSL certificate errors

**Solutions**:
```bash
# Disable SSL for development
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/_cluster/settings" \
  -H "Content-Type: application/json" \
  -d '{"persistent":{"xpack.security.transport.ssl.enabled":false}}'
```

## 📊 Data Issues

### Data Not Loading

**Problem**: Sample data not appearing in Kibana

**Diagnosis**:
```bash
# Check if data exists
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cat/indices?v

# Check document count
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/ecommerce-products/_count
```

**Solutions**:

1. **Reload Sample Data**:
```bash
# Run the sample data script
./scripts/load-sample-data.sh
```

2. **Check Index Patterns**:
```bash
# Create index patterns in Kibana
curl -X POST "http://localhost:5601/api/saved_objects/index-pattern/ecommerce-products" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{"attributes":{"title":"ecommerce-products*","timeFieldName":"created_at"}}'
```

### Data Corruption

**Problem**: Data appears corrupted or incomplete

**Solutions**:
```bash
# Reindex data
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X POST "localhost:9200/_reindex" \
  -H "Content-Type: application/json" \
  -d '{"source":{"index":"ecommerce-products"},"dest":{"index":"ecommerce-products-new"}}'

# Delete and recreate index
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X DELETE "localhost:9200/ecommerce-products"
```

## 📈 Monitoring Issues

### Grafana Not Loading Dashboards

**Problem**: Grafana shows "No data source" errors

**Solutions**:
```bash
# Check data source configuration
kubectl exec -n monitoring deployment/grafana -- curl -s http://localhost:3000/api/datasources

# Restart Grafana
kubectl rollout restart deployment/grafana -n monitoring
```

### Prometheus Not Scraping

**Problem**: Prometheus not collecting metrics

**Diagnosis**:
```bash
# Check Prometheus targets
kubectl exec -n monitoring deployment/prometheus -- curl -s http://localhost:9090/api/v1/targets

# Check Prometheus configuration
kubectl get configmap prometheus-config -n monitoring -o yaml
```

**Solutions**:
```bash
# Update Prometheus configuration
kubectl edit configmap prometheus-config -n monitoring

# Restart Prometheus
kubectl rollout restart deployment/prometheus -n monitoring
```

## 🆘 Getting Help

### Log Collection

When reporting issues, collect the following logs:

```bash
# Collect all logs
kubectl logs --all-containers=true --all-namespaces=true > all-logs.txt

# Collect specific service logs
kubectl logs -n elasticsearch deployment/elasticsearch > elasticsearch-logs.txt
kubectl logs -n kibana deployment/kibana > kibana-logs.txt
kubectl logs -n monitoring deployment/grafana > grafana-logs.txt
```

### System Information

```bash
# Collect system information
kubectl get nodes -o wide > nodes.txt
kubectl get pods --all-namespaces -o wide > pods.txt
kubectl get svc --all-namespaces > services.txt
kubectl get pv,pvc --all-namespaces > storage.txt
```

### Cluster Status

```bash
# Collect cluster status
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/health > cluster-health.json
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/settings > cluster-settings.json
```

## 📞 Support Resources

- **GitHub Issues**: [Report bugs and request features](https://github.com/yourusername/elastic-terraform-aws/issues)
- **Documentation**: [Elasticsearch Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- **Community**: [Elastic Community](https://discuss.elastic.co/)
- **AWS Support**: [AWS Support Center](https://console.aws.amazon.com/support/)

---

**💡 Tip**: Always check the logs first - they usually contain the most helpful information for diagnosing issues!
