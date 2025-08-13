# Cost Calculator: Elastic and Terraform Infrastructure

## 💰 Monthly Cost Breakdown

### Base Configuration (Default)

| Component | Instance Type | Count | Hours/Month | Cost/Hour | Monthly Cost |
|-----------|---------------|-------|-------------|-----------|--------------|
| **EKS Control Plane** | - | 1 | 730 | $0.10 | $73.00 |
| **Elasticsearch Nodes** | t3.medium | 3 | 730 | $0.0416 | $91.10 |
| **Kibana Nodes** | t3.small | 2 | 730 | $0.0208 | $30.37 |
| **Load Balancer** | - | 1 | 730 | $0.0225 | $16.43 |
| **EBS Storage** | gp3 | 500GB | 730 | $0.0001/GB | $36.50 |
| **S3 Storage** | Standard | 100GB | 730 | $0.023/GB | $2.30 |
| **Data Transfer** | - | 100GB | 730 | $0.09/GB | $9.00 |
| **NAT Gateway** | - | 3 | 730 | $0.045 | $98.55 |
| **Total** | | | | | **$357.25** |

### Cost Optimization Options

#### Option 1: Development Environment
| Component | Instance Type | Count | Monthly Cost |
|-----------|---------------|-------|--------------|
| EKS Control Plane | - | 1 | $73.00 |
| Elasticsearch Nodes | t3.small | 2 | $30.37 |
| Kibana Nodes | t3.small | 1 | $15.18 |
| Load Balancer | - | 1 | $16.43 |
| EBS Storage | gp3 | 200GB | $14.60 |
| S3 Storage | Standard | 50GB | $1.15 |
| Data Transfer | - | 50GB | $4.50 |
| NAT Gateway | - | 1 | $32.85 |
| **Total** | | | **$187.08** |

#### Option 2: Production Environment
| Component | Instance Type | Count | Monthly Cost |
|-----------|---------------|-------|--------------|
| EKS Control Plane | - | 1 | $73.00 |
| Elasticsearch Nodes | m5.large | 5 | $365.00 |
| Kibana Nodes | t3.medium | 3 | $91.10 |
| Load Balancer | - | 1 | $16.43 |
| EBS Storage | gp3 | 1000GB | $73.00 |
| S3 Storage | Standard | 500GB | $11.50 |
| Data Transfer | - | 200GB | $18.00 |
| NAT Gateway | - | 3 | $98.55 |
| **Total** | | | **$746.58** |

#### Option 3: High-Performance Environment
| Component | Instance Type | Count | Monthly Cost |
|-----------|---------------|-------|--------------|
| EKS Control Plane | - | 1 | $73.00 |
| Elasticsearch Nodes | r5.xlarge | 7 | $1,277.50 |
| Kibana Nodes | t3.large | 3 | $136.65 |
| Load Balancer | - | 1 | $16.43 |
| EBS Storage | gp3 | 2000GB | $146.00 |
| S3 Storage | Standard | 1000GB | $23.00 |
| Data Transfer | - | 500GB | $45.00 |
| NAT Gateway | - | 3 | $98.55 |
| **Total** | | | **$1,816.13** |

## 🎯 Cost Optimization Strategies

### 1. Instance Type Selection

#### Elasticsearch Nodes
- **t3.small** (2 vCPU, 2GB): $15.18/month - Development
- **t3.medium** (2 vCPU, 4GB): $30.37/month - Testing
- **m5.large** (2 vCPU, 8GB): $73.00/month - Production
- **r5.xlarge** (4 vCPU, 32GB): $182.50/month - High Performance

#### Kibana Nodes
- **t3.small** (2 vCPU, 2GB): $15.18/month - Light usage
- **t3.medium** (2 vCPU, 4GB): $30.37/month - Standard usage
- **t3.large** (2 vCPU, 8GB): $45.55/month - Heavy usage

### 2. Storage Optimization

#### EBS Volume Types
- **gp3** (General Purpose): $0.08/GB/month - Best for most workloads
- **io2** (Provisioned IOPS): $0.125/GB/month - High performance
- **st1** (Throughput Optimized): $0.045/GB/month - Big data workloads

#### S3 Storage Classes
- **Standard**: $0.023/GB/month - Frequently accessed
- **IA (Infrequent Access)**: $0.0125/GB/month - Less frequently accessed
- **Glacier**: $0.004/GB/month - Long-term archival

### 3. Network Optimization

#### NAT Gateway Alternatives
- **NAT Gateway**: $0.045/hour - Managed service
- **NAT Instance**: ~$0.02/hour - Self-managed (saves ~$18/month per AZ)

#### Data Transfer
- **Inter-AZ**: $0.02/GB
- **Internet**: $0.09/GB
- **S3 Transfer**: Free within same region

## 📊 Cost Comparison by Use Case

### Development/Testing
- **Purpose**: Learning, testing, development
- **Traffic**: Low
- **Data**: < 100GB
- **Cost**: $150-250/month
- **Configuration**: 2 Elasticsearch nodes, 1 Kibana node

### Staging/QA
- **Purpose**: Pre-production testing
- **Traffic**: Medium
- **Data**: 100-500GB
- **Cost**: $300-500/month
- **Configuration**: 3 Elasticsearch nodes, 2 Kibana nodes

### Production
- **Purpose**: Live applications
- **Traffic**: High
- **Data**: 500GB-2TB
- **Cost**: $700-1200/month
- **Configuration**: 5+ Elasticsearch nodes, 3 Kibana nodes

### Enterprise
- **Purpose**: Large-scale applications
- **Traffic**: Very high
- **Data**: 2TB+
- **Cost**: $1500+/month
- **Configuration**: 7+ Elasticsearch nodes, 3+ Kibana nodes

## 💡 Cost-Saving Tips

### 1. Right-Size Resources
```hcl
# Start small, scale up as needed
node_groups = {
  elasticsearch = {
    instance_type = "t3.small"  # Start with small instances
    min_size      = 1           # Minimum nodes
    max_size      = 5           # Allow scaling
    desired_size  = 2           # Start with 2 nodes
  }
}
```

### 2. Use Spot Instances (Development)
```hcl
# For non-production environments
capacity_type = "SPOT"  # Can save 60-90% on compute costs
```

### 3. Implement Auto-Scaling
```hcl
# Scale down during off-hours
enable_autoscaling = true
min_replicas = 1
max_replicas = 5
```

### 4. Optimize Storage
```hcl
# Use appropriate storage classes
elasticsearch_storage_size = "100Gi"  # Start with smaller volumes
backup_retention_days = 7             # Reduce retention for dev
```

### 5. Multi-Environment Strategy
- **Development**: Use smaller instances, shorter retention
- **Staging**: Medium instances, moderate retention
- **Production**: Full-size instances, longer retention

## 🧮 Cost Calculator Script

```bash
#!/bin/bash
# Simple cost calculator

echo "Elastic and Terraform Cost Calculator"
echo "====================================="

# Get user inputs
read -p "Number of Elasticsearch nodes: " es_nodes
read -p "Elasticsearch instance type (t3.small/t3.medium/m5.large): " es_type
read -p "Number of Kibana nodes: " kibana_nodes
read -p "Storage size in GB: " storage_gb

# Calculate costs
case $es_type in
  "t3.small") es_cost=15.18 ;;
  "t3.medium") es_cost=30.37 ;;
  "m5.large") es_cost=73.00 ;;
  *) es_cost=30.37 ;;
esac

kibana_cost=15.18
storage_cost=$(echo "$storage_gb * 0.08" | bc)
total_cost=$(echo "$es_cost * $es_nodes + $kibana_cost * $kibana_nodes + $storage_cost + 150" | bc)

echo "Estimated monthly cost: $${total_cost}"
```

## 📈 Cost Monitoring

### AWS Cost Explorer
- Set up budgets and alerts
- Monitor daily/weekly/monthly costs
- Identify cost drivers

### Terraform Cost Estimation
```bash
# Use terraform cost estimation tools
terraform plan -out=tfplan
terraform show tfplan | grep -E "(cost|price)"
```

### Resource Tagging
```hcl
# Tag resources for cost allocation
common_tags = {
  Environment = "production"
  Project     = "elastic-stack"
  CostCenter  = "engineering"
  Owner       = "devops-team"
}
```

---

**Note**: All costs are estimates based on AWS US West (Oregon) region. Actual costs may vary based on usage, region, and AWS pricing changes.
