# Kibana Dashboard Creation Guide

## Quick Dashboard Setup for Sample Data

### 1. Index Pattern Setup
- **Index Name**: `sample-logs`
- **Time Field**: `@timestamp` or `timestamp`

### 2. Recommended Visualizations

#### A. Log Level Distribution (Pie Chart)
- **Visualization Type**: Pie Chart
- **Metrics**: Count
- **Buckets**: Terms aggregation on `level.keyword`
- **Title**: "Log Level Distribution"

#### B. Service Performance (Data Table)
- **Visualization Type**: Data Table
- **Metrics**: Average of `response_time`
- **Buckets**: Terms aggregation on `service.keyword`
- **Title**: "Average Response Time by Service"

#### C. Log Volume Over Time (Line Chart)
- **Visualization Type**: Line Chart
- **Metrics**: Count
- **Buckets**: Date Histogram on `@timestamp` (1 hour intervals)
- **Title**: "Log Volume Over Time"

#### D. Top Services (Horizontal Bar Chart)
- **Visualization Type**: Horizontal Bar Chart
- **Metrics**: Count
- **Buckets**: Terms aggregation on `service.keyword` (Top 10)
- **Title**: "Top Services by Log Count"

#### E. Error Rate by Service (Data Table)
- **Visualization Type**: Data Table
- **Metrics**: Count
- **Buckets**: 
  - Terms aggregation on `service.keyword`
  - Filters aggregation for `level.keyword` = "ERROR"
- **Title**: "Error Count by Service"

### 3. Dashboard Layout
```
┌─────────────────┬─────────────────┐
│ Log Level Dist  │ Service Perf    │
├─────────────────┼─────────────────┤
│ Log Volume      │                 │
│ Over Time       │ Top Services    │
├─────────────────┼─────────────────┤
│ Error Rate      │                 │
│ by Service      │                 │
└─────────────────┴─────────────────┘
```

### 4. Dashboard Settings
- **Title**: "Sample Logs Monitoring Dashboard"
- **Description**: "Real-time monitoring of sample application logs"
- **Time Range**: Last 24 hours
- **Auto-refresh**: 30 seconds

## Advanced Features

### Filters
- Add filters for specific services, log levels, or time ranges
- Use the filter bar at the top of the dashboard

### Drill-downs
- Click on pie chart segments to filter the entire dashboard
- Click on bar chart bars to focus on specific data

### Export Options
- Export dashboard as PDF
- Share dashboard URL
- Embed dashboard in other applications

## Troubleshooting

### If you don't see data:
1. Check that the index pattern is created correctly
2. Verify the time field is set properly
3. Adjust the time range in the top-right corner
4. Check that sample data was generated successfully

### If visualizations are empty:
1. Ensure the field names match exactly (case-sensitive)
2. Try using `.keyword` suffix for text fields
3. Check the field mapping in Index Management
