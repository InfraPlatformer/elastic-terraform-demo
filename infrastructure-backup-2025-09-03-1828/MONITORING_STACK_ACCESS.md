# 🚀 Complete Monitoring Stack Access Guide

This guide shows you how to access **Grafana**, **Prometheus**, and **Elasticsearch** after deployment.

## 🎯 **What You'll Get:**

- **🔍 Elasticsearch** - Data storage and search engine
- **📊 Kibana** - Data visualization and exploration
- **📈 Prometheus** - Metrics collection and storage
- **📊 Grafana** - Metrics visualization and dashboards

## 🚀 **Deploy Everything:**

```powershell
# Deploy the complete monitoring stack
.\deploy-complete-stack.ps1
```

## 🌐 **Access Your Services:**

### **1. Get LoadBalancer Endpoints:**
```bash
# Check all services and their endpoints
kubectl get svc -A

# Or check specific namespaces
kubectl get svc -n elasticsearch
kubectl get svc -n kibana
kubectl get svc -n monitoring
```

### **2. Access URLs:**

#### **🔍 Elasticsearch:**
```
http://<elasticsearch-lb-endpoint>:9200
```
- **Health Check:** `/_cluster/health`
- **Status:** `/_cat/indices?v`

#### **📊 Kibana:**
```
http://<kibana-lb-endpoint>:5601
```
- **Features:** Data visualization, search, dashboards
- **Sample Data:** Load sample data for testing

#### **📈 Prometheus:**
```
http://<prometheus-lb-endpoint>:9090
```
- **Targets:** `/targets`
- **Graph:** `/graph`
- **Alerts:** `/alerts`

#### **📊 Grafana:**
```
http://<grafana-lb-endpoint>:3000
```
- **Username:** `admin`
- **Password:** `admin123`

## 🔧 **Grafana Setup Steps:**

### **Step 1: Login to Grafana**
- URL: `http://<grafana-lb-endpoint>:3000`
- Username: `admin`
- Password: `admin123`

### **Step 2: Add Data Sources**

#### **Add Prometheus:**
1. Go to **Configuration** → **Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. URL: `http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090`
5. Click **Save & Test**

#### **Add Elasticsearch:**
1. Go to **Configuration** → **Data Sources**
2. Click **Add data source**
3. Select **Elasticsearch**
4. URL: `http://elasticsearch-elasticsearch.elasticsearch.svc.cluster.local:9200`
5. Click **Save & Test**

### **Step 3: Import Dashboards**

#### **Kubernetes Cluster Dashboard:**
1. Go to **+** → **Import**
2. Enter Dashboard ID: `724`
3. Select **Prometheus** as data source
4. Click **Import**

#### **Kubernetes Pods Dashboard:**
1. Go to **+** → **Import**
2. Enter Dashboard ID: `6417`
3. Select **Prometheus** as data source
4. Click **Import**

#### **Elasticsearch Overview Dashboard:**
1. Go to **+** → **Import**
2. Enter Dashboard ID: `725`
3. Select **Elasticsearch** as data source
4. Click **Import**

## 📊 **What You'll See:**

### **Grafana Dashboards:**
- **Kubernetes Cluster Overview** - Node metrics, cluster health
- **Kubernetes Pods** - Pod performance, resource usage
- **Elasticsearch Overview** - Index stats, cluster health

### **Prometheus Metrics:**
- **Node metrics** - CPU, memory, disk usage
- **Kubernetes metrics** - Pod, service, deployment stats
- **Custom metrics** - Application-specific data

### **Elasticsearch Data:**
- **Log data** - Application logs, system logs
- **Metrics data** - Performance metrics, business data
- **Search capabilities** - Full-text search, aggregations

## 🔍 **Useful Commands:**

### **Check Service Status:**
```bash
# Check all pods
kubectl get pods -A

# Check specific namespace
kubectl get pods -n monitoring
kubectl get pods -n elasticsearch
kubectl get pods -n kibana

# Check services
kubectl get svc -A
```

### **View Logs:**
```bash
# Elasticsearch logs
kubectl logs -n elasticsearch deployment/elasticsearch

# Kibana logs
kubectl logs -n kibana deployment/kibana

# Prometheus logs
kubectl logs -n monitoring deployment/prometheus-kube-prometheus-prometheus

# Grafana logs
kubectl logs -n monitoring deployment/grafana
```

### **Port Forward (for local access):**
```bash
# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Elasticsearch
kubectl port-forward -n elasticsearch svc/elasticsearch-elasticsearch 9200:9200

# Kibana
kubectl port-forward -n kibana svc/kibana 5601:5601
```

## 🎉 **Success Indicators:**

✅ **All pods are Running**
✅ **LoadBalancer services have external IPs**
✅ **Grafana accessible at port 3000**
✅ **Prometheus accessible at port 9090**
✅ **Elasticsearch accessible at port 9200**
✅ **Kibana accessible at port 5601**

## 🚨 **Troubleshooting:**

### **Pods not starting:**
```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### **Services not accessible:**
```bash
kubectl get svc -n <namespace>
kubectl describe svc <service-name> -n <namespace>
```

### **Storage issues:**
```bash
kubectl get pvc -A
kubectl describe pvc <pvc-name> -n <namespace>
```

## 🌟 **Next Steps:**

1. **Explore Grafana dashboards**
2. **Create custom dashboards**
3. **Set up alerts in Prometheus**
4. **Load sample data in Elasticsearch**
5. **Create visualizations in Kibana**

**Enjoy your complete monitoring stack! 🎯📊🚀**



