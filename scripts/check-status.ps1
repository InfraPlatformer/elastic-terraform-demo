# Check Deployment Status Script
# This script helps troubleshoot deployment issues

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Deployment Status Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to terraform directory
Set-Location "..\terraform"

Write-Host "=== Terraform Status ===" -ForegroundColor Yellow
terraform state list | Select-String "elasticsearch"

Write-Host "`n=== Kubernetes Pods ===" -ForegroundColor Yellow
try {
    kubectl get pods -n elasticsearch
} catch {
    Write-Host "Error: kubectl not configured or cluster not ready" -ForegroundColor Red
}

Write-Host "`n=== Persistent Volume Claims ===" -ForegroundColor Yellow
try {
    kubectl get pvc -n elasticsearch
} catch {
    Write-Host "Error: kubectl not configured or cluster not ready" -ForegroundColor Red
}

Write-Host "`n=== Storage Classes ===" -ForegroundColor Yellow
try {
    kubectl get storageclass
} catch {
    Write-Host "Error: kubectl not configured or cluster not ready" -ForegroundColor Red
}

Write-Host "`n=== EKS Cluster Status ===" -ForegroundColor Yellow
try {
    aws eks describe-cluster --name $(terraform output -raw cluster_name) --region $(terraform output -raw aws_region) --query 'cluster.status' --output text
} catch {
    Write-Host "Error: AWS CLI not configured or cluster not found" -ForegroundColor Red
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Green
Write-Host "1. If pods are stuck, check: kubectl describe pod <pod-name> -n elasticsearch" -ForegroundColor White
Write-Host "2. If PVCs are pending, check: kubectl describe pvc <pvc-name> -n elasticsearch" -ForegroundColor White
Write-Host "3. To retry deployment: terraform apply" -ForegroundColor White
Write-Host "4. To destroy and start over: terraform destroy" -ForegroundColor White
