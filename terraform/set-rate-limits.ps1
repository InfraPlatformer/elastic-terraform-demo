# Set environment variables to increase Kubernetes rate limits
Write-Host "Setting Kubernetes rate limit environment variables..."

# Increase Kubernetes client rate limits
$env:KUBERNETES_CLIENT_RATE_LIMIT_QPS = "100"
$env:KUBERNETES_CLIENT_RATE_LIMIT_BURST = "200"

# Increase Terraform parallelism for better resource creation
$env:TF_CLI_ARGS = "-parallelism=10"

# Set longer timeouts for Kubernetes operations
$env:KUBERNETES_CLIENT_TIMEOUT = "600"

Write-Host "Environment variables set:"
Write-Host "TF_CLI_ARGS: $env:TF_CLI_ARGS"
Write-Host "KUBERNETES_CLIENT_RATE_LIMIT_QPS: $env:KUBERNETES_CLIENT_RATE_LIMIT_QPS"
Write-Host "KUBERNETES_CLIENT_RATE_LIMIT_BURST: $env:KUBERNETES_CLIENT_RATE_LIMIT_BURST"
Write-Host "KUBERNETES_CLIENT_TIMEOUT: $env:KUBERNETES_CLIENT_RATE_LIMIT_BURST"

Write-Host "`nNow you can run terraform apply with increased rate limits!"
