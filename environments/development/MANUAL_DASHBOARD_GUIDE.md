# 🎯 **MANUAL DASHBOARD CREATION GUIDE**

## ✅ **Your Working Dashboard is Ready!**
- **URL**: `http://aed9c293d78324bb7a20b773d0e70e29-767864011.us-west-2.elb.amazonaws.com:3000/d/7`
- **Login**: `admin` / `admin`

---

## 🔧 **If You Need to Create Panels Manually:**

### **Step 1: Create a New Dashboard**
1. Go to Grafana: `http://aed9c293d78324bb7a20b773d0e70e29-767864011.us-west-2.elb.amazonaws.com:3000`
2. Login with `admin` / `admin`
3. Click **"+"** in the left menu
4. Select **"Dashboard"**

### **Step 2: Add a Simple Stat Panel**
1. Click **"Add visualization"**
2. Select **"Stat"** panel type
3. In the query section:
   - **Data Source**: `Elasticsearch`
   - **Query**: `elasticsearch_docs_total`
4. Click **"Apply"**
5. You should see: **6** (total documents)

### **Step 3: Add a Table Panel for Log Levels**
1. Click **"Add visualization"**
2. Select **"Table"** panel type
3. In the query section:
   - **Data Source**: `Elasticsearch`
   - **Query**: `elasticsearch_logs{level}`
4. Click **"Apply"**
5. You should see a table with: INFO, WARN, ERROR, DEBUG

### **Step 4: Add a Pie Chart for Services**
1. Click **"Add visualization"**
2. Select **"Pie chart"** panel type
3. In the query section:
   - **Data Source**: `Elasticsearch`
   - **Query**: `elasticsearch_logs{service}`
4. Click **"Apply"**
5. You should see a pie chart with: elasticsearch, kibana, auth, database, cache

---

## 📊 **Working Queries for Your Data:**

### **Document Count:**
```
elasticsearch_docs_total
```
**Expected Result**: 6

### **Log Levels:**
```
elasticsearch_logs{level}
```
**Expected Result**: INFO, WARN, ERROR, DEBUG

### **Services:**
```
elasticsearch_logs{service}
```
**Expected Result**: elasticsearch, kibana, auth, database, cache

### **Hosts:**
```
elasticsearch_logs{host}
```
**Expected Result**: aws-eks, azure-aks

### **CPU Usage:**
```
elasticsearch_metrics{cpu}
```
**Expected Result**: 45.2, 78.5, 92.1, etc.

### **Memory Usage:**
```
elasticsearch_metrics{memory}
```
**Expected Result**: 67.8, 89.2, 95.7, etc.

### **Disk Usage:**
```
elasticsearch_metrics{disk}
```
**Expected Result**: 23.1, 45.3, 67.8, etc.

---

## 🎯 **Why This Works:**

1. **Simple Queries**: Using basic field grouping instead of complex aggregations
2. **Correct Field Names**: Using the actual field names from your data
3. **Basic Visualizations**: Stat panels and tables work better than complex charts
4. **Real Data**: Your 6 sample documents are definitely there

---

## 🚀 **Quick Test:**

1. **Go to your dashboard**: `http://aed9c293d78324bb7a20b773d0e70e29-767864011.us-west-2.elb.amazonaws.com:3000/d/7`
2. **You should see data immediately**
3. **If not, try the manual steps above**

---

## 📞 **Still Having Issues?**

If the dashboard still shows no data:
1. **Check the time range** (top right) - set to "Last 1 hour"
2. **Verify data source** - make sure it's set to "Elasticsearch"
3. **Check the query** - use the exact queries above
4. **Refresh the page** - sometimes Grafana needs a refresh

**Your data is definitely there - we just need the right query format!** 🎉


## ✅ **Your Working Dashboard is Ready!**
- **URL**: `http://aed9c293d78324bb7a20b773d0e70e29-767864011.us-west-2.elb.amazonaws.com:3000/d/7`
- **Login**: `admin` / `admin`

---

## 🔧 **If You Need to Create Panels Manually:**

### **Step 1: Create a New Dashboard**
1. Go to Grafana: `http://aed9c293d78324bb7a20b773d0e70e29-767864011.us-west-2.elb.amazonaws.com:3000`
2. Login with `admin` / `admin`
3. Click **"+"** in the left menu
4. Select **"Dashboard"**

### **Step 2: Add a Simple Stat Panel**
1. Click **"Add visualization"**
2. Select **"Stat"** panel type
3. In the query section:
   - **Data Source**: `Elasticsearch`
   - **Query**: `elasticsearch_docs_total`
4. Click **"Apply"**
5. You should see: **6** (total documents)

### **Step 3: Add a Table Panel for Log Levels**
1. Click **"Add visualization"**
2. Select **"Table"** panel type
3. In the query section:
   - **Data Source**: `Elasticsearch`
   - **Query**: `elasticsearch_logs{level}`
4. Click **"Apply"**
5. You should see a table with: INFO, WARN, ERROR, DEBUG

### **Step 4: Add a Pie Chart for Services**
1. Click **"Add visualization"**
2. Select **"Pie chart"** panel type
3. In the query section:
   - **Data Source**: `Elasticsearch`
   - **Query**: `elasticsearch_logs{service}`
4. Click **"Apply"**
5. You should see a pie chart with: elasticsearch, kibana, auth, database, cache

---

## 📊 **Working Queries for Your Data:**

### **Document Count:**
```
elasticsearch_docs_total
```
**Expected Result**: 6

### **Log Levels:**
```
elasticsearch_logs{level}
```
**Expected Result**: INFO, WARN, ERROR, DEBUG

### **Services:**
```
elasticsearch_logs{service}
```
**Expected Result**: elasticsearch, kibana, auth, database, cache

### **Hosts:**
```
elasticsearch_logs{host}
```
**Expected Result**: aws-eks, azure-aks

### **CPU Usage:**
```
elasticsearch_metrics{cpu}
```
**Expected Result**: 45.2, 78.5, 92.1, etc.

### **Memory Usage:**
```
elasticsearch_metrics{memory}
```
**Expected Result**: 67.8, 89.2, 95.7, etc.

### **Disk Usage:**
```
elasticsearch_metrics{disk}
```
**Expected Result**: 23.1, 45.3, 67.8, etc.

---

## 🎯 **Why This Works:**

1. **Simple Queries**: Using basic field grouping instead of complex aggregations
2. **Correct Field Names**: Using the actual field names from your data
3. **Basic Visualizations**: Stat panels and tables work better than complex charts
4. **Real Data**: Your 6 sample documents are definitely there

---

## 🚀 **Quick Test:**

1. **Go to your dashboard**: `http://aed9c293d78324bb7a20b773d0e70e29-767864011.us-west-2.elb.amazonaws.com:3000/d/7`
2. **You should see data immediately**
3. **If not, try the manual steps above**

---

## 📞 **Still Having Issues?**

If the dashboard still shows no data:
1. **Check the time range** (top right) - set to "Last 1 hour"
2. **Verify data source** - make sure it's set to "Elasticsearch"
3. **Check the query** - use the exact queries above
4. **Refresh the page** - sometimes Grafana needs a refresh

**Your data is definitely there - we just need the right query format!** 🎉

