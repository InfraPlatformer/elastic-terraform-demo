# Elasticsearch & Kibana on AWS EKS with Terraform
## Infrastructure as Code Meetup Presentation

### **Presenter Bio**
**Alam Zaman**  
*Senior DevOps Engineer & Infrastructure Specialist*  
*Expertise: AWS, Kubernetes, Terraform, Elasticsearch, CI/CD*  
*Passion: Building scalable, cost-effective cloud infrastructure*  
*LinkedIn: [Your LinkedIn Profile]*

---

## **Agenda**
1. **Introduction & Architecture Overview** (10 min)
2. **Cost Optimization Strategy** (5 min)
3. **Terraform Implementation** (15 min)
4. **Live Demo: Infrastructure Deployment** (20 min)
5. **Accessing Dashboards & Monitoring** (10 min)
6. **Q&A & Discussion** (10 min)

---

## **1. Introduction & Architecture Overview**

### **What We're Building Today**
- **Elasticsearch 8.11.0** on AWS EKS
- **Kibana 8.11.0** for data visualization
- **Complete monitoring stack** (Prometheus, Grafana)
- **100% Infrastructure as Code** with Terraform

### **Why This Matters**
- **Real-world scenario**: Production-ready Elasticsearch deployment
- **Cost optimization**: From $193/month to $120/month (38% savings)
- **Best practices**: Security, monitoring, and scalability
- **Skills demonstration**: AWS, Kubernetes, Terraform, Elasticsearch

### **Architecture Highlights**
- **2-node EKS cluster** (vs traditional 5+ nodes)
- **Single-zone deployment** for cost efficiency
- **Integrated monitoring** and alerting
- **Security-first approach** with private subnets

---

## **2. Cost Optimization Strategy**

### **Before vs After**
| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| **Worker Nodes** | 5 instances | 2 instances | **$73/month** |
| **Elasticsearch** | 3 replicas, 100Gi | 1 replica, 50Gi | **$25/month** |
| **Kibana** | 2 replicas, 10Gi | 1 replica, 5Gi | **$8/month** |
| **Total Monthly** | **$193** | **$120** | **$73/month** |

### **Optimization Techniques**
- **Right-sized instances**: t3.medium for ES, t2.small for Kibana
- **Single replicas**: Perfect for demo/presentation workloads
- **Reduced storage**: Optimized for actual usage patterns
- **Simplified architecture**: Fewer moving parts = faster deployment

---

## **3. Terraform Implementation**

### **Key Terraform Modules**
- **VPC & Networking**: Custom VPC with public/private subnets
- **EKS Cluster**: Managed Kubernetes control plane
- **Node Groups**: Auto-scaling worker nodes
- **Elasticsearch**: StatefulSet with persistent storage
- **Kibana**: Deployment with monitoring stack
- **Monitoring**: Prometheus, Grafana, AlertManager

### **Configuration Highlights**
```hcl
# Cost-optimized node groups
node_groups = {
  elasticsearch = {
    instance_type = "t3.medium"  # 2 vCPU, 4 GiB RAM
    desired_size  = 1            # Single node for demo
  }
  kibana = {
    instance_type = "t2.small"   # 1 vCPU, 2 GiB RAM
    desired_size  = 1            # Single node for demo
  }
}
```

---

## **4. Live Demo: Infrastructure Deployment**

### **Deployment Process**
1. **Terraform Init** - Initialize providers and modules
2. **Terraform Plan** - Review infrastructure changes
3. **Terraform Apply** - Deploy infrastructure (~20 minutes)
4. **Verification** - Check cluster health and pod status

### **Expected Timeline**
- **EKS Cluster**: 10-15 minutes
- **Worker Nodes**: 5-8 minutes
- **Elasticsearch**: 3-5 minutes
- **Kibana + Monitoring**: 2-3 minutes
- **Total**: **20-25 minutes** (vs 30+ minutes before)

### **What to Watch For**
- **Node provisioning** and health checks
- **Storage volume** creation and binding
- **Pod scheduling** and container startup
- **Service endpoints** becoming available

---

## **5. Accessing Dashboards & Monitoring**

### **Service Endpoints**
| Service | Port | Purpose | Access |
|---------|------|---------|---------|
| **Elasticsearch** | 9200 | REST API | Internal cluster |
| **Kibana** | 5601 | Web UI | Load Balancer |
| **Grafana** | 3000 | Dashboards | Load Balancer |
| **Prometheus** | 9090 | Metrics | Load Balancer |

### **Dashboard Features**
- **Elasticsearch**: Cluster health, index management, search
- **Kibana**: Data visualization, log analysis, dashboards
- **Grafana**: Infrastructure metrics, custom dashboards
- **Prometheus**: Time-series data collection

---

## **6. Q&A & Discussion**

### **Common Questions**
- **Cost management** strategies for production
- **Scaling** from demo to production
- **Security** best practices
- **Monitoring** and alerting setup
- **Backup** and disaster recovery

### **Next Steps**
- **GitHub repository** with complete code
- **Documentation** and troubleshooting guides
- **Community** resources and support

---

## **Demo Environment Specifications**

### **Infrastructure Details**
- **Region**: us-west-2 (Oregon)
- **VPC**: 10.0.0.0/16 with 3 availability zones
- **EKS Version**: 1.29 (latest stable)
- **Node Types**: t3.medium + t2.small
- **Storage**: 55 GiB total (50Gi ES + 5Gi Kibana)

### **Software Versions**
- **Elasticsearch**: 8.11.0 (latest)
- **Kibana**: 8.11.0 (latest)
- **Prometheus**: Latest
- **Grafana**: Latest
- **Terraform**: 1.5+

### **Security Features**
- **TLS encryption** enabled
- **Private subnets** for worker nodes
- **IAM roles** with least privilege
- **Security groups** for port restrictions

---

## **Resources & Links**

### **Documentation**
- **Network Diagram**: [docs/Network_Diagram_Optimized.md](docs/Network_Diagram_Optimized.md)
- **README**: [README.md](README.md)
- **Terraform Config**: [terraform/](terraform/)

### **External Resources**
- **Elasticsearch**: [https://www.elastic.co/elasticsearch](https://www.elastic.co/elasticsearch)
- **AWS EKS**: [https://aws.amazon.com/eks/](https://aws.amazon.com/eks/)
- **Terraform**: [https://www.terraform.io/](https://www.terraform.io/)

### **Contact & Support**
- **GitHub**: [Your Repository]
- **LinkedIn**: [Your Profile]
- **Email**: [Your Email]

---

*Thank you for attending! Let's build amazing infrastructure together! 🚀*
