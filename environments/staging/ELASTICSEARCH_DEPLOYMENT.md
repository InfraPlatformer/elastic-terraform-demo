# Elasticsearch Deployment Guide for Staging Environment

## Overview

The staging environment now has a fully functional EKS cluster with networking infrastructure. This guide will help you deploy Elasticsearch manually on the cluster.

## Prerequisites

- EKS cluster is running and accessible
- kubectl is configured for the cluster
- Helm is installed

## Step 1: Verify Cluster Access

```bash
# Verify cluster access
kubectl get nodes

# Should show 5 nodes (3 elasticsearch + 2 general)
```

## Step 2: Create Elasticsearch Namespace

```bash
kubectl create namespace elasticsearch
```

## Step 3: Add Elasticsearch Helm Repository

```bash
helm repo add elastic https://helm.elastic.co
helm repo update
```

## Step 4: Create Elasticsearch Values File

Create a file named `elasticsearch-values-staging.yaml`:

```yaml
# Elasticsearch Configuration for Staging
clusterName: "elasticsearch-staging"
nodeGroup: "default"

# Resource Configuration
resources:
  requests:
    cpu: "2000m"
    memory: "4Gi"
  limits:
    cpu: "4000m"
    memory: "8Gi"

# Replica Configuration
replicas: 3

# Storage Configuration
volumeClaimTemplate:
  spec:
    accessModes: ["ReadWriteOnce"]
    resources:
      requests:
        storage: 100Gi
    storageClassName: "gp2"

# Security Configuration
esConfig:
  elasticsearch.yml: |
    cluster.name: elasticsearch-staging
    node.name: ${HOSTNAME}
    network.host: 0.0.0.0
    discovery.seed_hosts: ["elasticsearch-staging-0", "elasticsearch-staging-1", "elasticsearch-staging-2"]
    cluster.initial_master_nodes: ["elasticsearch-staging-0", "elasticsearch-staging-1", "elasticsearch-staging-2"]
    xpack.security.enabled: false
    xpack.monitoring.enabled: true

# JVM Configuration
esJavaOpts: "-Xms2g -Xmx2g"

# Service Configuration
service:
  type: ClusterIP
  ports:
    - name: http
      port: 9200
      targetPort: 9200
    - name: transport
      port: 9300
      targetPort: 9300

# Node Selector for Elasticsearch nodes
nodeSelector:
  role: elasticsearch

# Anti-affinity for high availability
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - elasticsearch
        topologyKey: kubernetes.io/hostname
```

## Step 5: Deploy Elasticsearch

```bash
helm install elasticsearch-staging elastic/elasticsearch \
  --namespace elasticsearch \
  --values elasticsearch-values-staging.yaml \
  --version 8.11.0
```

## Step 6: Monitor Deployment

```bash
# Check pod status
kubectl get pods -n elasticsearch

# Check service
kubectl get svc -n elasticsearch

# Check logs
kubectl logs -n elasticsearch elasticsearch-staging-0
```

## Step 7: Verify Elasticsearch Health

```bash
# Port forward to access Elasticsearch
kubectl port-forward -n elasticsearch svc/elasticsearch-staging 9200:9200

# In another terminal, test the connection
curl http://localhost:9200/_cluster/health
```

## Step 8: Deploy Kibana (Optional)

```bash
# Create Kibana values file
cat > kibana-values-staging.yaml << EOF
elasticsearchHosts: "http://elasticsearch-staging:9200"
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
service:
  type: ClusterIP
EOF

# Deploy Kibana
helm install kibana-staging elastic/kibana \
  --namespace elasticsearch \
  --values kibana-values-staging.yaml \
  --version 8.11.0
```

## Step 9: Access Kibana

```bash
# Port forward Kibana
kubectl port-forward -n elasticsearch svc/kibana-staging 5601:5601

# Access Kibana at http://localhost:5601
```

## Troubleshooting

### Pod Stuck in Pending

```bash
# Check pod events
kubectl describe pod -n elasticsearch <pod-name>

# Check node resources
kubectl top nodes
```

### Elasticsearch Not Starting

```bash
# Check logs
kubectl logs -n elasticsearch elasticsearch-staging-0

# Check cluster health
kubectl exec -n elasticsearch elasticsearch-staging-0 -- curl -s http://localhost:9200/_cluster/health
```

### Storage Issues

```bash
# Check PVC status
kubectl get pvc -n elasticsearch

# Check storage class
kubectl get storageclass
```

## Cleanup

To remove Elasticsearch:

```bash
# Remove Helm releases
helm uninstall kibana-staging -n elasticsearch
helm uninstall elasticsearch-staging -n elasticsearch

# Remove namespace
kubectl delete namespace elasticsearch
```

## Next Steps

1. **Configure Index Templates**: Set up proper index templates for your data
2. **Set Up Monitoring**: Configure Elasticsearch monitoring and alerting
3. **Configure Backup**: Set up snapshot repositories for data backup
4. **Security**: Enable X-Pack security features for production use
5. **Scaling**: Monitor resource usage and scale as needed

## Useful Commands

```bash
# Check cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# List indices
curl -X GET "localhost:9200/_cat/indices?v"

# Get cluster stats
curl -X GET "localhost:9200/_cluster/stats?pretty"

# Check node stats
curl -X GET "localhost:9200/_nodes/stats?pretty"
```

## Configuration Notes

- **Security**: X-Pack security is disabled for staging. Enable for production.
- **Storage**: Uses AWS EBS gp2 storage class with 100GB per pod.
- **Resources**: Configured for staging workloads. Adjust for production.
- **Replicas**: 3 replicas for high availability.
- **Node Affinity**: Pods are scheduled on nodes with `role=elasticsearch` label.

