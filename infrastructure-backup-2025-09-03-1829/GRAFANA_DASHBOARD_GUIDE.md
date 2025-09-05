# 🎯 Grafana Elasticsearch Dashboard Guide

## 📊 **Access Your Grafana Dashboard**

**URL**: `http://a007b9692ccc543aea97874996577ba7-103818889.us-west-2.elb.amazonaws.com:3000`
- **Username**: `admin`
- **Password**: `admin123`

## 🚀 **Quick Start Steps**

### 1. **Login to Grafana**
1. Open the URL above in your browser
2. Enter username: `admin`
3. Enter password: `admin123`
4. Click "Log In"

### 2. **Access Your Dashboard**
1. Click the **"Dashboards"** icon (📊) in the left sidebar
2. Look for **"Elasticsearch Comprehensive Monitoring"**
3. Click on it to open your dashboard

## 📈 **Dashboard Panels Explained**

### **Top Row - Cluster Health**
- **Cluster Health Status**: Shows if cluster is Green/Yellow/Red
- **Number of Nodes**: Total nodes in cluster
- **Active Shards**: Number of active shards
- **Unassigned Shards**: Number of unassigned shards

### **Second Row - Memory Usage**
- **JVM Heap Usage %**: Java heap memory usage percentage
- **JVM Non-Heap Usage %**: Non-heap memory usage percentage

### **Third Row - Operations**
- **Index Operations Rate**: Rate of indexing operations per second
- **Search Operations Rate**: Rate of search operations per second

### **Fourth Row - Performance**
- **Query Time (ms)**: Average query response time
- **Disk Usage %**: Disk space usage percentage

### **Bottom Row - Data**
- **Document Count**: Total number of documents
- **Index Size (MB)**: Total size of all indices

## 🎛️ **Dashboard Controls**

### **Time Range**
- Click the time picker in the top-right corner
- Select "Last 1 hour" to see recent data
- Or set custom time range

### **Auto-Refresh**
- Click the refresh button (🔄) next to time picker
- Set to "30s" for live updates

### **Panel Interactions**
- **Hover**: See detailed values
- **Click**: Zoom into specific time ranges
- **Legend**: Click to show/hide specific metrics

## 🔧 **Customization Options**

### **Add New Panels**
1. Click **"Add panel"** button
2. Choose visualization type
3. Add Prometheus query
4. Configure display options
5. Save panel

### **Edit Existing Panels**
1. Click panel title → **"Edit"**
2. Modify queries or settings
3. Click **"Apply"** to save changes

### **Create New Dashboard**
1. Click **"New dashboard"** button
2. Add panels as needed
3. Save with descriptive name

## 📊 **Key Metrics to Monitor**

### **Critical Metrics**
- **Cluster Health**: Should be Green
- **JVM Heap Usage**: Keep below 85%
- **Disk Usage**: Keep below 90%
- **Query Time**: Monitor for performance issues

### **Performance Metrics**
- **Index Rate**: Shows data ingestion speed
- **Search Rate**: Shows query load
- **Document Count**: Shows data volume
- **Index Size**: Shows storage usage

## 🚨 **Alerting Setup**

### **Create Alerts**
1. Edit any panel
2. Go to **"Alert"** tab
3. Set threshold conditions
4. Configure notification channels
5. Save alert rule

### **Recommended Alerts**
- Cluster Health = Red
- JVM Heap Usage > 85%
- Disk Usage > 90%
- Query Time > 1000ms

## 💡 **Pro Tips**

1. **Use Variables**: Create dashboard variables for dynamic filtering
2. **Annotations**: Add annotations for important events
3. **Templates**: Save dashboard as template for reuse
4. **Sharing**: Use share button to export or embed dashboard
5. **Keyboard Shortcuts**: Use 'd' for dashboard view, 'e' for edit mode

## 🔗 **Related Dashboards**

- **Prometheus**: `http://ae2fd7b361e8148e789025e77d418857-490492219.us-west-2.elb.amazonaws.com:9090`
- **Kibana**: `http://a889eb0585d6249a5aebc367c2bd188b-264552843.us-west-2.elb.amazonaws.com:5601`
- **Elasticsearch**: `http://aba2ec55e0e98460e8f55e3a19b39718-980465324.us-west-2.elb.amazonaws.com:9200`

## 🆘 **Troubleshooting**

### **If Dashboard is Empty**
1. Check Prometheus is running
2. Verify Elasticsearch exporter is working
3. Check time range settings
4. Verify metric names in queries

### **If Panels Show "No Data"**
1. Check if metrics exist in Prometheus
2. Verify cluster name in queries
3. Adjust time range
4. Check for typos in metric names

Your Grafana dashboard is now ready for comprehensive Elasticsearch monitoring! 🎉
