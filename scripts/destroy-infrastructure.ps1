# Infrastructure Destruction Script
# This script safely destroys the Elasticsearch and Kibana infrastructure

param(
    [string]$Region = "us-west-2",
    [switch]$SkipConfirmation
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
Write-Warning @"
╔══════════════════════════════════════════════════════════════╗
║              ⚠️  INFRASTRUCTURE DESTRUCTION ⚠️              ║
║                    Elasticsearch & Kibana                   ║
╚══════════════════════════════════════════════════════════════╝
"@

# Set working directory
$scriptDir = Split-Path -Parent $MyInvocation.MyInvocationName
$terraformDir = Join-Path $scriptDir ".." "terraform"
Set-Location $terraformDir

Write-Info "Working directory: $(Get-Location)"

# Check if terraform state exists
if (-not (Test-Path "terraform.tfstate")) {
    Write-Error "No Terraform state found. Infrastructure may already be destroyed or not deployed."
    exit 1
}

# Get current infrastructure info
Write-Info "Getting current infrastructure information..."
try {
    $outputs = terraform output -json 2>$null | ConvertFrom-Json
    if ($outputs) {
        Write-Info "Current infrastructure:"
        if ($outputs.cluster_name.value) {
            Write-Info "  EKS Cluster: $($outputs.cluster_name.value)"
        }
        if ($outputs.kibana_alb_url.value) {
            Write-Info "  Kibana ALB: $($outputs.kibana_alb_url.value)"
        }
        if ($outputs.backup_s3_bucket.value -and $outputs.backup_s3_bucket.value -ne "N/A") {
            Write-Info "  S3 Backup Bucket: $($outputs.backup_s3_bucket.value)"
        }
    }
} catch {
    Write-Warning "Could not retrieve infrastructure information"
}

# Final confirmation
if (-not $SkipConfirmation) {
    Write-Warning "⚠️  WARNING: This will PERMANENTLY DELETE all infrastructure!"
    Write-Warning "This includes:"
    Write-Warning "  - EKS cluster and all nodes"
    Write-Warning "  - Elasticsearch and Kibana deployments"
    Write-Warning "  - VPC, subnets, and security groups"
    Write-Warning "  - Load balancers and S3 buckets"
    Write-Warning "  - ALL DATA will be lost!"
    
    $confirmation = Read-Host "Type 'DESTROY' to confirm deletion"
    if ($confirmation -ne "DESTROY") {
        Write-Info "Destruction cancelled. Infrastructure remains intact."
        exit 0
    }
    
    $finalConfirmation = Read-Host "Are you absolutely sure? Type 'YES' to proceed"
    if ($finalConfirmation -ne "YES") {
        Write-Info "Destruction cancelled. Infrastructure remains intact."
        exit 0
    }
}

Write-Warning "🚨 Starting infrastructure destruction..."

# Destroy infrastructure
Write-Info "Running terraform destroy..."
try {
    terraform destroy -auto-approve
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform destroy failed"
    }
    Write-Success "✓ Infrastructure destroyed successfully!"
} catch {
    Write-Error "✗ Infrastructure destruction failed: $_"
    Write-Info "You may need to manually clean up some resources."
    exit 1
}

# Clean up local files
Write-Info "Cleaning up local files..."
try {
    $filesToRemove = @(
        "terraform.tfstate*",
        "tfplan*",
        ".terraform*"
    )
    
    foreach ($pattern in $filesToRemove) {
        Get-ChildItem -Path . -Name $pattern -Force | ForEach-Object {
            Remove-Item $_ -Force -Recurse
            Write-Info "  Removed: $_"
        }
    }
    
    Write-Success "✓ Local files cleaned up"
} catch {
    Write-Warning "⚠ Could not clean up all local files: $_"
}

# Final status
Write-Success "🎉 Infrastructure destruction completed!"
Write-Info "All AWS resources have been removed."
Write-Info "You can redeploy later using: .\deploy-complete.ps1"
Write-Info "Have a great day! 👋"

