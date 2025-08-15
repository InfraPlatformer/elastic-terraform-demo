# Deploy Elasticsearch and Kibana to EKS
Write-Host "🚀 Deploying Elasticsearch and Kibana to EKS Cluster..." -ForegroundColor Green

# Check if kubectl is available
try {
    kubectl version --client
} catch {
    Write-Host "❌ kubectl is not available. Please install kubectl first." -ForegroundColor Red
    exit 1
}

# Check cluster access
Write-Host "📋 Checking cluster access..." -ForegroundColor Yellow
kubectl cluster-info

# Wait for node groups to be ready
Write-Host "⏳ Waiting for node groups to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "Attempt $attempt/$maxAttempts - Checking node groups..." -ForegroundColor Cyan
    
    $elasticsearchStatus = aws eks describe-nodegroup --cluster-name elastic-demo-cluster --nodegroup-name elasticsearch-nodes --region us-west-2 --query 'nodegroup.status' --output text 2>$null
    $kibanaStatus = aws eks describe-nodegroup --cluster-name elastic-demo-cluster --nodegroup-name kibana-nodes --region us-west-2 --query 'nodegroup.status' --output text 2>$null
    
    Write-Host "Elasticsearch nodes: $elasticsearchStatus" -ForegroundColor White
    Write-Host "Kibana nodes: $kibanaStatus" -ForegroundColor White
    
    if ($elasticsearchStatus -eq "ACTIVE" -and $kibanaStatus -eq "ACTIVE") {
        Write-Host "✅ All node groups are ready!" -ForegroundColor Green
        break
    }
    
    if ($attempt -ge $maxAttempts) {
        Write-Host "❌ Timeout waiting for node groups. Please check AWS console." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "⏳ Waiting 30 seconds before next check..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
} while ($true)

# Check nodes
Write-Host "📊 Checking cluster nodes..." -ForegroundColor Yellow
kubectl get nodes

# Deploy Kubernetes resources
Write-Host "🚀 Deploying Kubernetes resources..." -ForegroundColor Green
kubectl apply -f deploy-k8s-resources.yaml

# Wait for deployments to be ready
Write-Host "⏳ Waiting for deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/elasticsearch -n elasticsearch
kubectl wait --for=condition=available --timeout=300s deployment/kibana -n kibana

# Check deployment status
Write-Host "📊 Checking deployment status..." -ForegroundColor Yellow
kubectl get deployments -n elasticsearch
kubectl get deployments -n kibana

# Check services
Write-Host "🔌 Checking services..." -ForegroundColor Yellow
kubectl get services -n elasticsearch
kubectl get services -n kibana

# Get external IP for Kibana
Write-Host "🌐 Getting external access information..." -ForegroundColor Yellow
$kibanaService = kubectl get service kibana-external -n kibana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null

if ($kibanaService) {
    Write-Host "✅ Kibana is accessible at: http://$kibanaService:5601" -ForegroundColor Green
} else {
    Write-Host "⏳ Kibana LoadBalancer is still provisioning..." -ForegroundColor Yellow
    Write-Host "Check with: kubectl get service kibana-external -n kibana" -ForegroundColor Cyan
}

# Check Elasticsearch health
Write-Host "🔍 Checking Elasticsearch health..." -ForegroundColor Yellow
Start-Sleep -Seconds 30  # Give Elasticsearch time to start
kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s http://localhost:9200/_cluster/health 2>$null

Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host "📋 Useful commands:" -ForegroundColor Cyan
Write-Host "  - Check pods: kubectl get pods -A" -ForegroundColor White
Write-Host "  - Check services: kubectl get services -A" -ForegroundColor White
Write-Host "  - Elasticsearch logs: kubectl logs -n elasticsearch deployment/elasticsearch" -ForegroundColor White
Write-Host "  - Kibana logs: kubectl logs -n kibana deployment/kibana" -ForegroundColor White
