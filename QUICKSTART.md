# 🚀 Quick Start Guide

Get your Elastic Stack running on AWS in under 10 minutes!

## ⚡ Prerequisites

Before you begin, ensure you have:

- **AWS CLI** installed and configured
- **Terraform** >= 1.0 installed
- **kubectl** installed
- **Git** installed
- **AWS Account** with appropriate permissions

## 🎯 One-Command Deployment

```bash
# Clone the repository
git clone https://github.com/yourusername/elastic-terraform-aws.git
cd elastic-terraform-aws

# Make scripts executable
chmod +x scripts/*.sh

# Deploy everything with one command
./scripts/deploy.sh
```

That's it! The script will:
- ✅ Deploy AWS infrastructure (EKS, VPC, etc.)
- ✅ Install Elasticsearch, Kibana, and Grafana
- ✅ Load sample data
- ✅ Create dashboards
- ✅ Display access URLs

## 🔍 Manual Step-by-Step

If you prefer to run each step manually:

### 1. Deploy Infrastructure

```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name elastic-stack-cluster
```

### 3. Deploy Applications

```bash
kubectl apply -f k8s/elasticsearch/
kubectl apply -f k8s/kibana/
kubectl apply -f k8s/grafana/
kubectl apply -f k8s/prometheus/
```

### 4. Load Sample Data

```bash
./scripts/load-sample-data.sh
```

## 🌐 Access Your Services

After deployment, you'll get URLs like:

- **Kibana**: `http://your-kibana-loadbalancer-url:5601`
- **Grafana**: `http://your-grafana-loadbalancer-url:3000`
- **Elasticsearch**: `http://your-elasticsearch-internal-url:9200`

## 📊 Sample Data Included

The deployment automatically loads:

- **E-commerce Products** (10 products)
- **Web Application Logs** (10 log entries)
- **Customer Orders** (5 orders)
- **System Metrics** (10 metric records)

## 🎨 Pre-built Dashboards

Ready-to-use dashboards:

- **E-commerce Overview** - Product analytics
- **Application Monitoring** - Log analysis
- **System Health** - Infrastructure metrics
- **Sales Analytics** - Revenue tracking

## 🛠️ Troubleshooting

If something goes wrong:

```bash
# Check pod status
kubectl get pods --all-namespaces

# Check logs
kubectl logs -n elasticsearch deployment/elasticsearch
kubectl logs -n kibana deployment/kibana

# Check service URLs
kubectl get svc --all-namespaces
```

For more detailed troubleshooting, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## 🧹 Cleanup

To destroy everything and avoid AWS charges:

```bash
cd environments/staging
terraform destroy
```

## 🎉 What's Next?

1. **Explore Kibana** - Create custom visualizations
2. **Set up Alerts** - Configure monitoring alerts
3. **Add Your Data** - Load your own data
4. **Customize Dashboards** - Build custom dashboards
5. **Scale Up** - Add more nodes or increase resources

## 📚 Learn More

- [Full Documentation](README.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- [Sample Data](sample-data/)
- [Dashboard Examples](dashboards/)

---

**⭐ Enjoy your Elastic Stack on AWS!**
