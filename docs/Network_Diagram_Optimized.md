# Cost-Optimized EKS Architecture for Elasticsearch & Kibana

## Network Architecture Overview

```
                                    AWS Cloud (us-west-2)
                                    ┌─────────────────────────────────────────────────────────┐
                                    │                                                         │
                                    │  ┌─────────────────────────────────────────────────┐    │
                                    │  │              VPC (10.0.0.0/16)                 │    │
                                    │  │                                                 │    │
                                    │  │  ┌─────────────────────────────────────────┐    │    │
                                    │  │  │         EKS Control Plane               │    │    │
                                    │  │  │      (Managed by AWS)                   │    │    │
                                    │  │  │                                         │    │    │
                                    │  │  │  • API Server                           │    │    │
                                    │  │  │  • Scheduler                           │    │    │
                                    │  │  │  • Controller Manager                   │    │    │
                                    │  │  │  • etcd                                │    │    │
                                    │  │  └─────────────────────────────────────────┘    │    │
                                    │  │                                                 │    │
                                    │  │  ┌─────────────────────────────────────────┐    │    │
                                    │  │  │           Public Subnet                 │    │    │
                                    │  │  │         (us-west-2a)                    │    │    │
                                    │  │  │                                         │    │    │
                                    │  │  │  ┌─────────────────────────────────┐    │    │    │
                                    │  │  │  │      Internet Gateway            │    │    │    │
                                    │  │  │  └─────────────────────────────────┘    │    │    │
                                    │  │  │                                         │    │    │
                                    │  │  │  ┌─────────────────────────────────┐    │    │    │
                                    │  │  │  │      NAT Gateway                 │    │    │    │    │
                                    │  │  │  │      (Elastic IP)                │    │    │    │
                                    │  │  │  └─────────────────────────────────┘    │    │    │
                                    │  │  └─────────────────────────────────────────┘    │    │
                                    │  │                                                 │    │
                                    │  │  ┌─────────────────────────────────────────┐    │    │
                                    │  │  │          Private Subnet                 │    │    │
                                    │  │  │         (us-west-2a)                    │    │    │
                                    │  │  │                                         │    │    │
                                    │  │  │  ┌─────────────────────────────────┐    │    │    │
                                    │  │  │  │      EKS Worker Node 1           │    │    │    │
                                    │  │  │  │      t3.medium                   │    │    │    │
                                    │  │  │  │      (Elasticsearch)             │    │    │    │
                                    │  │  │  │                                 │    │    │    │
                                    │  │  │  │  ┌─────────────────────────┐    │    │    │    │
                                    │  │  │  │  │   Elasticsearch Pod     │    │    │    │    │
                                    │  │  │  │  │   • Port 9200 (HTTP)    │    │    │    │    │
                                    │  │  │  │  │   • Port 9300 (TCP)     │    │    │    │    │
                                    │  │  │  │  │   • 50Gi Storage        │    │    │    │    │
                                    │  │  │  │  │   • 2Gi Memory          │    │    │    │    │
                                    │  │  │  │  │   • 1 CPU               │    │    │    │    │
                                    │  │  │  │  └─────────────────────────┘    │    │    │    │
                                    │  │  │  │                                 │    │    │    │
                                    │  │  │  │  ┌─────────────────────────┐    │    │    │    │
                                    │  │  │  │  │   EBS Volume            │    │    │    │    │
                                    │  │  │  │  │   (gp2, 50Gi)          │    │    │    │    │
                                    │  │  │  │  └─────────────────────────┘    │    │    │    │
                                    │  │  │  └─────────────────────────────────┘    │    │    │
                                    │  │  │                                         │    │    │
                                    │  │  │  ┌─────────────────────────────────┐    │    │    │
                                    │  │  │  │      EKS Worker Node 2           │    │    │    │
                                    │  │  │  │      t2.small                    │    │    │    │
                                    │  │  │  │      (Kibana + Monitoring)       │    │    │    │
                                    │  │  │  │                                 │    │    │    │
                                    │  │  │  │  ┌─────────────────────────┐    │    │    │    │
                                    │  │  │  │  │     Kibana Pod          │    │    │    │    │
                                    │  │  │  │  │   • Port 5601 (HTTP)    │    │    │    │    │
                                    │  │  │  │  │   • 5Gi Storage         │    │    │    │    │
                                    │  │  │  │  │   • 1Gi Memory          │    │    │    │    │
                                    │  │  │  │  │   • 0.5 CPU             │    │    │    │    │
                                    │  │  │  │  └─────────────────────────┘    │    │    │    │
                                    │  │  │  │                                 │    │    │    │
                                    │  │  │  │  ┌─────────────────────────┐    │    │    │    │
                                    │  │  │  │  │   Prometheus Pod        │    │    │    │    │
                                    │  │  │  │  │   • Port 9090 (HTTP)    │    │    │    │    │
                                    │  │  │  │  └─────────────────────────┘    │    │    │    │
                                    │  │  │  │                                 │    │    │    │
                                    │  │  │  │  ┌─────────────────────────┐    │    │    │    │
                                    │  │  │  │  │   Grafana Pod           │    │    │    │    │
                                    │  │  │  │  │   • Port 3000 (HTTP)    │    │    │    │    │
                                    │  │  │  │  └─────────────────────────┘    │    │    │    │
                                    │  │  │  └─────────────────────────────────┘    │    │    │
                                    │  │  └─────────────────────────────────────────┘    │    │
                                    │  │                                                 │    │
                                    │  │  ┌─────────────────────────────────────────┐    │    │
                                    │  │  │           Load Balancer                 │    │    │
                                    │  │  │        (Application Load Balancer)      │    │    │
                                    │  │  │                                         │    │    │
                                    │  │  │  • Kibana: Port 5601                    │    │    │
                                    │  │  │  • Grafana: Port 3000                   │    │    │
                                    │  │  │  • Prometheus: Port 9090                │    │    │
                                    │  │  └─────────────────────────────────────────┘    │    │
                                    │  └─────────────────────────────────────────────────┘    │
                                    │                                                         │
                                    └─────────────────────────────────────────────────────────┘
```

## Key Components

### **EKS Control Plane (Managed by AWS)**
- **API Server**: Handles all Kubernetes API requests
- **Scheduler**: Assigns pods to nodes
- **Controller Manager**: Manages cluster state
- **etcd**: Distributed key-value store

### **Worker Node 1 (t3.medium)**
- **Instance Type**: t3.medium (2 vCPU, 4 GiB RAM)
- **Purpose**: Elasticsearch primary node
- **Storage**: 50 GiB EBS gp2 volume
- **Ports**: 9200 (HTTP), 9300 (TCP)

### **Worker Node 2 (t2.small)**
- **Instance Type**: t2.small (1 vCPU, 2 GiB RAM)
- **Purpose**: Kibana + Monitoring stack
- **Components**: Kibana, Prometheus, Grafana
- **Ports**: 5601 (Kibana), 3000 (Grafana), 9090 (Prometheus)

### **Networking**
- **VPC**: 10.0.0.0/16
- **Public Subnet**: Internet access via NAT Gateway
- **Private Subnet**: Worker nodes for security
- **Load Balancer**: External access to services

### **Storage**
- **EBS Volumes**: gp2 storage for persistent data
- **Elasticsearch**: 50 GiB for data storage
- **Kibana**: 5 GiB for configuration and logs

## Cost Optimization Benefits

- **Reduced from 5 to 2 instances** = ~$73/month savings
- **Single replicas** = Faster deployment, lower complexity
- **Optimized instance types** = Right-sized for demo workloads
- **Reduced storage** = Lower EBS costs
- **Simplified architecture** = Easier troubleshooting

## Security Features

- **Private subnets** for worker nodes
- **NAT Gateway** for controlled internet access
- **Security groups** for port restrictions
- **IAM roles** for least privilege access
- **TLS encryption** enabled by default
