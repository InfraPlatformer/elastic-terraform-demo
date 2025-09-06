# 🚀 Production Deployment via Terraform

## Quick Start

### 1. Navigate to Production Directory
```bash
cd environments/production
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the Plan
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply
```

## Detailed Steps

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28

### Step 1: Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and Region (us-west-2)
```

### Step 2: Navigate to Production Environment
```bash
cd environments/production
```

### Step 3: Initialize Terraform
```bash
terraform init
```

### Step 4: Review Configuration
```bash
# Check what will be created
terraform plan

# Save the plan to a file for review
terraform plan -out=production.tfplan
```

### Step 5: Deploy Infrastructure
```bash
# Deploy with confirmation
terraform apply

# Or deploy with saved plan
terraform apply production.tfplan

# Or deploy without confirmation (use with caution)
terraform apply -auto-approve
```

### Step 6: Configure kubectl
```bash
# Get cluster name from outputs
terraform output cluster_name

# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name $(terraform output -raw cluster_name)
```

### Step 7: Verify Deployment
```bash
# Check cluster nodes
kubectl get nodes

# Check Elasticsearch pods
kubectl get pods -n elasticsearch

# Check Kibana pods
kubectl get pods -n kibana

# Check monitoring pods
kubectl get pods -n monitoring
```

## Accessing Services

### Elasticsearch
```bash
# Port forward to Elasticsearch
kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200

# Test Elasticsearch
curl http://localhost:9200/_cluster/health
```

### Kibana
```bash
# Port forward to Kibana
kubectl port-forward -n kibana svc/kibana 5601:5601

# Access Kibana at http://localhost:5601
```

### Grafana
```bash
# Port forward to Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Access Grafana at http://localhost:3000
```

### Prometheus
```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Access Prometheus at http://localhost:9090
```

## Terraform Commands Reference

### Basic Commands
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy (use with caution!)
terraform destroy
```

### Advanced Commands
```bash
# Show current state
terraform show

# List resources
terraform state list

# Import existing resource
terraform import aws_eks_cluster.main cluster-name

# Refresh state
terraform refresh

# Validate configuration
terraform validate

# Format code
terraform fmt
```

### Output Commands
```bash
# Show all outputs
terraform output

# Show specific output
terraform output cluster_name
terraform output elasticsearch_endpoint
terraform output kibana_endpoint
```

## Troubleshooting

### Common Issues

1. **Terraform init fails**
   ```bash
   # Clean and reinitialize
   rm -rf .terraform
   terraform init
   ```

2. **AWS credentials not found**
   ```bash
   # Check AWS configuration
   aws sts get-caller-identity
   
   # Configure if needed
   aws configure
   ```

3. **kubectl not configured**
   ```bash
   # Get cluster name
   terraform output cluster_name
   
   # Configure kubectl
   aws eks update-kubeconfig --region us-west-2 --name <cluster-name>
   ```

4. **Resources not ready**
   ```bash
   # Wait for resources to be ready
   kubectl get pods --all-namespaces
   
   # Check specific namespace
   kubectl get pods -n elasticsearch
   ```

### Useful Debugging Commands
```bash
# Check Terraform version
terraform version

# Check AWS CLI version
aws --version

# Check kubectl version
kubectl version --client

# Check cluster status
aws eks describe-cluster --name <cluster-name> --region us-west-2
```

## Production Best Practices

### 1. State Management
- Use remote state storage (S3 + DynamoDB)
- Enable state locking
- Regular state backups

### 2. Security
- Use IAM roles with least privilege
- Enable CloudTrail logging
- Regular security audits

### 3. Monitoring
- Set up CloudWatch alarms
- Monitor resource usage
- Track costs

### 4. Backup
- Regular Terraform state backups
- Document recovery procedures
- Test restore processes

## Cost Optimization

### 1. Resource Sizing
- Right-size instances based on usage
- Use spot instances for non-critical workloads
- Enable auto-scaling

### 2. Storage
- Use appropriate storage classes
- Implement lifecycle policies
- Regular cleanup of unused resources

### 3. Monitoring
- Track costs with AWS Cost Explorer
- Set up billing alerts
- Regular cost reviews

## Next Steps

1. **Configure Monitoring**
   - Set up Grafana dashboards
   - Configure alerting rules
   - Test monitoring endpoints

2. **Security Hardening**
   - Review security groups
   - Update IAM policies
   - Enable audit logging

3. **Backup Testing**
   - Test backup procedures
   - Verify restore processes
   - Document recovery steps

4. **Performance Tuning**
   - Monitor resource usage
   - Optimize configurations
   - Load testing

---

**Need Help?**
- Check the logs: `terraform apply` shows detailed output
- Review AWS CloudFormation events in AWS Console
- Check Kubernetes events: `kubectl get events --all-namespaces`

