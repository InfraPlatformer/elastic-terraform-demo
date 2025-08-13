# Complete Elasticsearch and Kibana Deployment Script
# This script deploys the full infrastructure including EKS, Elasticsearch, Kibana, and monitoring

param(
    [string]$Environment = "demo",
    [string]$Region = "us-west-2",
    [switch]$SkipConfirmation,
    [switch]$Destroy
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info { Write-ColorOutput $args[0] $Colors.Info }
function Write-Success { Write-ColorOutput $args[0] $Colors.Success }
function Write-Warning { Write-ColorOutput $args[0] $Colors.Warning }
function Write-Error { Write-ColorOutput $args[0] $Colors.Error }

# Banner
Write-Info @"
╔══════════════════════════════════════════════════════════════╗
║           Elasticsearch & Kibana Terraform Deployment       ║
║                    Complete Infrastructure                   ║
╚══════════════════════════════════════════════════════════════╝
"@

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check if Terraform is installed
try {
    $terraformVersion = terraform version | Select-String "Terraform v"
    if ($terraformVersion) {
        Write-Success "✓ Terraform found: $terraformVersion"
    }
} catch {
    Write-Error "✗ Terraform not found. Please install Terraform first."
    exit 1
}

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version 2>$null
    if ($awsVersion) {
        Write-Success "✓ AWS CLI found: $awsVersion"
    }
} catch {
    Write-Error "✗ AWS CLI not found. Please install AWS CLI first."
    exit 1
}

# Check if kubectl is installed
try {
    $kubectlVersion = kubectl version --client 2>$null | Select-String "Client Version"
    if ($kubectlVersion) {
        Write-Success "✓ kubectl found: $kubectlVersion"
    }
} catch {
    Write-Error "✗ kubectl not found. Please install kubectl first."
    exit 1
}

# Check AWS credentials
Write-Info "Checking AWS credentials..."
try {
    $awsIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    if ($awsIdentity) {
        Write-Success "✓ AWS credentials valid for account: $($awsIdentity.Account)"
        Write-Info "  User: $($awsIdentity.Arn)"
    }
} catch {
    Write-Error "✗ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
}

# Set working directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$terraformDir = Join-Path $scriptDir ".." "terraform"
Set-Location $terraformDir

Write-Info "Working directory: $(Get-Location)"

# Check if terraform.tfvars exists, if not create from example
if (-not (Test-Path "terraform.tfvars")) {
    if (Test-Path "terraform.tfvars.example") {
        Write-Warning "terraform.tfvars not found. Creating from example..."
        Copy-Item "terraform.tfvars.example" "terraform.tfvars"
        Write-Info "Please edit terraform.tfvars with your configuration values."
        if (-not $SkipConfirmation) {
            Read-Host "Press Enter to continue after editing terraform.tfvars"
        }
    } else {
        Write-Error "terraform.tfvars not found and no example file available."
        exit 1
    }
}

# Initialize Terraform
Write-Info "Initializing Terraform..."
try {
    terraform init
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform init failed"
    }
    Write-Success "✓ Terraform initialized successfully"
} catch {
    Write-Error "✗ Terraform initialization failed: $_"
    exit 1
}

# Validate Terraform configuration
Write-Info "Validating Terraform configuration..."
try {
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform validation failed"
    }
    Write-Success "✓ Terraform configuration is valid"
} catch {
    Write-Error "✗ Terraform validation failed: $_"
    exit 1
}

# Plan Terraform deployment
Write-Info "Planning Terraform deployment..."
try {
    terraform plan -out=tfplan
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform plan failed"
    }
    Write-Success "✓ Terraform plan created successfully"
} catch {
    Write-Error "✗ Terraform plan failed: $_"
    exit 1
}

# Show plan summary
Write-Info "Plan Summary:"
terraform show tfplan | Select-String -Pattern "Plan:|  # |  \+ |  \- |  ~ " | ForEach-Object {
    $line = $_.ToString().Trim()
    if ($line -match "Plan:") {
        Write-Info $line
    } elseif ($line -match "  \+ ") {
        Write-Success $line
    } elseif ($line -match "  \- ") {
        Write-Warning $line
    } elseif ($line -match "  ~ ") {
        Write-Warning $line
    } else {
        Write-Info $line
    }
}

# Confirm deployment
if (-not $SkipConfirmation) {
    Write-Warning "This will create infrastructure that may incur costs."
    $confirmation = Read-Host "Do you want to proceed with the deployment? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Info "Deployment cancelled."
        exit 0
    }
}

# Apply Terraform configuration
Write-Info "Applying Terraform configuration..."
try {
    terraform apply tfplan
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform apply failed"
    }
    Write-Success "✓ Infrastructure deployed successfully!"
} catch {
    Write-Error "✗ Terraform deployment failed: $_"
    exit 1
}

# Get outputs
Write-Info "Getting deployment outputs..."
try {
    $outputs = terraform output -json | ConvertFrom-Json
    Write-Success "✓ Deployment outputs retrieved"
} catch {
    Write-Warning "⚠ Could not retrieve outputs: $_"
}

# Update kubeconfig
Write-Info "Updating kubeconfig..."
try {
    $clusterName = $outputs.cluster_name.value
    aws eks update-kubeconfig --region $Region --name $clusterName
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to update kubeconfig"
    }
    Write-Success "✓ kubeconfig updated for cluster: $clusterName"
} catch {
    Write-Warning "⚠ Could not update kubeconfig: $_"
}

# Wait for pods to be ready
Write-Info "Waiting for pods to be ready..."
try {
    Write-Info "Waiting for Elasticsearch pods..."
    kubectl wait --for=condition=ready pod -l app=elasticsearch -n elasticsearch --timeout=600s
    Write-Success "✓ Elasticsearch pods are ready"
    
    Write-Info "Waiting for Kibana pods..."
    kubectl wait --for=condition=ready pod -l app=kibana -n kibana --timeout=300s
    Write-Success "✓ Kibana pods are ready"
    
    if ($outputs.monitoring_enabled.value -eq $true) {
        Write-Info "Waiting for monitoring pods..."
        kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
        kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s
        Write-Success "✓ Monitoring pods are ready"
    }
} catch {
    Write-Warning "⚠ Some pods may not be ready yet: $_"
}

# Show deployment status
Write-Info "Deployment Status:"
Write-Info "=================="

try {
    Write-Info "Elasticsearch:"
    kubectl get pods -n elasticsearch
    
    Write-Info "Kibana:"
    kubectl get pods -n kibana
    
    if ($outputs.monitoring_enabled.value -eq $true) {
        Write-Info "Monitoring:"
        kubectl get pods -n monitoring
    }
    
    Write-Info "Services:"
    kubectl get svc -A | Select-String -Pattern "elasticsearch|kibana|monitoring"
} catch {
    Write-Warning "⚠ Could not retrieve deployment status: $_"
}

# Display access information
Write-Info "Access Information:"
Write-Info "==================="

if ($outputs) {
    if ($outputs.elasticsearch_url.value) {
        Write-Info "Elasticsearch Internal: $($outputs.elasticsearch_url.value)"
    }
    if ($outputs.kibana_url.value) {
        Write-Info "Kibana Internal: $($outputs.kibana_url.value)"
    }
    if ($outputs.kibana_alb_url.value) {
        Write-Info "Kibana External (ALB): http://$($outputs.kibana_alb_url.value)"
    }
    if ($outputs.monitoring_enabled.value -eq $true) {
        if ($outputs.prometheus_url.value) {
            Write-Info "Prometheus: $($outputs.prometheus_url.value)"
        }
        if ($outputs.grafana_url.value) {
            Write-Info "Grafana: $($outputs.grafana_url.value)"
        }
    }
    if ($outputs.backup_enabled.value -eq $true) {
        Write-Info "Backup S3 Bucket: $($outputs.backup_s3_bucket.value)"
    }
}

# Display credentials
Write-Info "Credentials:"
Write-Info "============"
Write-Info "Kibana Username: elastic"
Write-Info "Kibana Password: $($outputs.kibana_password.value)"

# Display useful commands
Write-Info "Useful Commands:"
Write-Info "================="
Write-Info "Check cluster status: kubectl cluster-info"
Write-Info "Check Elasticsearch health: kubectl exec -n elasticsearch elasticsearch-0 -- curl -s http://localhost:9200/_cluster/health"
Write-Info "Check Kibana status: kubectl exec -n kibana kibana-0 -- curl -s http://localhost:5601/api/status"
Write-Info "View logs: kubectl logs -n elasticsearch -l app=elasticsearch"
Write-Info "Port forward Kibana: kubectl port-forward -n kibana svc/kibana 5601:5601"

# Display cost information
if ($outputs.estimated_monthly_cost.value) {
    Write-Info "Estimated Monthly Cost:"
    Write-Info "======================="
    $costs = $outputs.estimated_monthly_cost.value
    foreach ($cost in $costs.PSObject.Properties) {
        Write-Info "$($cost.Name): $($cost.Value)"
    }
}

Write-Success "🎉 Deployment completed successfully!"
Write-Info "Your Elasticsearch and Kibana infrastructure is now running on AWS EKS."
Write-Info "You can access Kibana through the Application Load Balancer URL provided above."

