# Staging Environment

This directory contains the Terraform configuration for the staging environment of the multi-cloud Elasticsearch infrastructure.

## Overview

The staging environment provides a production-like setup for testing and validation before deploying to production. It includes:

- **EKS Cluster**: AWS EKS cluster with dedicated node groups for Elasticsearch
- **Networking**: VPC with private and public subnets, security groups, and VPC endpoints
- **Elasticsearch**: Multi-node Elasticsearch cluster deployed on AWS EKS
- **Monitoring**: Basic monitoring and logging capabilities

## Configuration

### Environment Variables

The staging environment is configured through `terraform.tfvars` with the following key settings:

- **Cluster Name**: `elasticsearch-cluster-staging`
- **EKS Version**: `1.28`
- **Node Groups**: 
  - Elasticsearch nodes: `t3.large` instances (3-5 nodes)
  - General nodes: `t3.medium` instances (2-3 nodes)
- **Elasticsearch**: 3 replicas with 4Gi memory and 2 CPU cores
- **Security**: SSL/TLS enabled
- **Backup**: Enabled with 14-day retention

### Resource Requirements

- **Memory**: 8Gi per Elasticsearch pod
- **CPU**: 4 cores per Elasticsearch pod
- **Storage**: 100GB per node for Elasticsearch, 50GB for general nodes

## Deployment

### Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. kubectl installed
4. Access to AWS EKS service

### Steps

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

4. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name elasticsearch-cluster-staging
   ```

5. **Verify deployment**:
   ```bash
   kubectl get nodes
   kubectl get pods -n elasticsearch
   ```

## Accessing Elasticsearch

### Internal Access

From within the cluster:
```bash
# Check Elasticsearch health
curl http://elasticsearch-aws.elasticsearch.svc.cluster.local:9200/_cluster/health

# List indices
curl http://elasticsearch-aws.elasticsearch.svc.cluster.local:9200/_cat/indices
```

### External Access

To access Elasticsearch from outside the cluster, you'll need to:

1. **Port forward the service**:
   ```bash
   kubectl port-forward -n elasticsearch svc/elasticsearch-aws 9200:9200
   ```

2. **Access via localhost**:
   ```bash
   curl http://localhost:9200/_cluster/health
   ```

## Monitoring

### Cluster Health

Check the Elasticsearch cluster health:
```bash
kubectl exec -n elasticsearch deployment/elasticsearch-aws -- curl -s http://localhost:9200/_cluster/health | jq
```

### Resource Usage

Monitor resource usage:
```bash
kubectl top pods -n elasticsearch
kubectl top nodes
```

### Logs

View Elasticsearch logs:
```bash
kubectl logs -n elasticsearch deployment/elasticsearch-aws
```

## Scaling

### Horizontal Pod Autoscaling

The Elasticsearch deployment supports horizontal pod autoscaling based on CPU and memory usage.

### Node Scaling

To scale the EKS node groups:

1. Update the `terraform.tfvars` file
2. Run `terraform plan` and `terraform apply`

## Security

### Network Security

- All Elasticsearch traffic is restricted to the cluster
- Security groups limit access to necessary ports only
- VPC endpoints provide secure access to AWS services

### TLS/SSL

- Elasticsearch is configured with TLS/SSL enabled
- Certificates are automatically generated and managed

## Backup and Recovery

### Automated Backups

- Backups are configured with 14-day retention
- Snapshots are stored in S3
- Backup schedule: Daily at 2 AM UTC

### Manual Backup

Create a manual backup:
```bash
kubectl exec -n elasticsearch deployment/elasticsearch-aws -- curl -X PUT "localhost:9200/_snapshot/backup_repo/manual_backup_$(date +%Y%m%d_%H%M%S)?wait_for_completion=true"
```

## Troubleshooting

### Common Issues

1. **Pod Pending**: Check node resources and taints
2. **Elasticsearch Unhealthy**: Check logs and cluster settings
3. **Network Issues**: Verify security groups and VPC configuration

### Debug Commands

```bash
# Check pod status
kubectl describe pod -n elasticsearch <pod-name>

# Check events
kubectl get events -n elasticsearch --sort-by='.lastTimestamp'

# Check cluster info
kubectl cluster-info
```

## Cleanup

To destroy the staging environment:

```bash
terraform destroy -var-file="terraform.tfvars"
```

**Warning**: This will permanently delete all resources in the staging environment.

## Cost Optimization

### Current Configuration

- Uses On-Demand instances for stability
- Auto-scaling enabled for cost efficiency
- Spot instances disabled for staging reliability

### Cost Reduction Options

1. **Enable Spot Instances**: Set `enable_spot_instances = true` in `terraform.tfvars`
2. **Reduce Node Count**: Lower `desired_size` in node group configurations
3. **Use Smaller Instances**: Change instance types to smaller sizes

## Support

For issues or questions about the staging environment:

1. Check the main project README
2. Review the troubleshooting documentation
3. Check Terraform and Kubernetes logs
4. Contact the infrastructure team

