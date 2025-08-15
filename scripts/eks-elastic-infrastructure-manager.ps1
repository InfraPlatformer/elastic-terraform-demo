# Elastic and Terraform Deployment Script for PowerShell
# This script automates the deployment of Elasticsearch and Kibana on AWS EKS

param(
    [Parameter(Position=0)]
    [ValidateSet("deploy", "cleanup", "verify", "plan")]
    [string]$Command = "deploy"
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Error "AWS CLI is not installed. Please install it first."
        exit 1
    }
    
    # Check if Terraform is installed
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error "Terraform is not installed. Please install it first."
        exit 1
    }
    
    # Check if kubectl is installed
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-Error "kubectl is not installed. Please install it first."
        exit 1
    }
    
    # Check AWS credentials
    try {
        aws sts get-caller-identity | Out-Null
    }
    catch {
        Write-Error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    }
    
    Write-Success "All prerequisites are met!"
}

# Function to validate configuration
function Test-Configuration {
    Write-Status "Validating Terraform configuration..."
    
    # Navigate to the terraform directory from the scripts directory
    Set-Location "..\terraform"
    
    # Check if terraform.tfvars exists
    if (-not (Test-Path "terraform.tfvars")) {
        Write-Warning "terraform.tfvars not found. Creating from example..."
        if (Test-Path "terraform.tfvars.example") {
            Copy-Item terraform.tfvars.example terraform.tfvars
            Write-Warning "Please edit terraform.tfvars with your configuration before continuing."
            exit 1
        } else {
            Write-Error "terraform.tfvars.example not found. Please create terraform.tfvars manually."
            exit 1
        }
    }
    
    # Validate Terraform configuration
    try {
        terraform validate | Out-Null
    }
    catch {
        Write-Error "Terraform configuration validation failed."
        exit 1
    }
    
    Write-Success "Configuration validation passed!"
}

# Function to deploy infrastructure
function Deploy-Infrastructure {
    Write-Status "Deploying infrastructure..."
    
    # Navigate to the terraform directory from the scripts directory
    Set-Location "..\terraform"
    
    # Initialize Terraform
    Write-Status "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    Write-Status "Planning deployment..."
    terraform plan -out=tfplan
    
    # Ask for confirmation
    Write-Host ""
    Write-Warning "Review the plan above. Do you want to proceed with the deployment? (y/N)"
    $response = Read-Host
    if ($response -notmatch "^[Yy]$") {
        Write-Status "Deployment cancelled."
        exit 0
    }
    
    # Apply deployment
    Write-Status "Applying deployment..."
    terraform apply tfplan
    
    Write-Success "Infrastructure deployment completed!"
}

# Function to configure kubectl
function Set-KubectlConfig {
    Write-Status "Configuring kubectl..."
    
    # Ensure we're in the terraform directory
    if ((Get-Location).Path -notlike "*terraform*") {
        Set-Location "..\terraform"
    }
    
    # Get cluster name from terraform output
    $CLUSTER_NAME = terraform output -raw cluster_name
    $AWS_REGION = terraform output -raw aws_region 2>$null
    if (-not $AWS_REGION) { $AWS_REGION = "us-west-2" }
    
    # Update kubeconfig
    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
    
    Write-Success "kubectl configured for cluster: $CLUSTER_NAME"
}

# Function to verify deployment
function Test-Deployment {
    Write-Status "Verifying deployment..."
    
    # Wait for nodes to be ready
    Write-Status "Waiting for EKS nodes to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Check Elasticsearch pods
    Write-Status "Checking Elasticsearch pods..."
    kubectl wait --for=condition=Ready pods -l app=elasticsearch -n elasticsearch --timeout=600s
    
    # Check Kibana pods
    Write-Status "Checking Kibana pods..."
    kubectl wait --for=condition=Ready pods -l app=kibana -n kibana --timeout=300s
    
    Write-Success "Deployment verification completed!"
}

# Function to display connection information
function Show-ConnectionInfo {
    Write-Status "Deployment completed successfully!"
    Write-Host ""
    Write-Host "=== Connection Information ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Get outputs
    $CLUSTER_NAME = terraform output -raw cluster_name
    $ELASTICSEARCH_URL = terraform output -raw elasticsearch_url 2>$null
    if (-not $ELASTICSEARCH_URL) { $ELASTICSEARCH_URL = "Not available yet" }
    $KIBANA_URL = terraform output -raw kibana_url 2>$null
    if (-not $KIBANA_URL) { $KIBANA_URL = "Not available yet" }
    $KIBANA_ALB_URL = terraform output -raw kibana_alb_url 2>$null
    if (-not $KIBANA_ALB_URL) { $KIBANA_ALB_URL = "Not available yet" }
    
    Write-Host "Cluster Name: $CLUSTER_NAME"
    Write-Host "Elasticsearch URL: $ELASTICSEARCH_URL"
    Write-Host "Kibana URL: $KIBANA_URL"
    Write-Host "Kibana ALB URL: $KIBANA_ALB_URL"
    Write-Host ""
    Write-Host "=== Useful Commands ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Check cluster status:"
    Write-Host "  kubectl cluster-info"
    Write-Host ""
    Write-Host "View Elasticsearch pods:"
    Write-Host "  kubectl get pods -n elasticsearch"
    Write-Host ""
    Write-Host "View Kibana pods:"
    Write-Host "  kubectl get pods -n kibana"
    Write-Host ""
    Write-Host "Access Elasticsearch:"
    Write-Host "  kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200"
    Write-Host ""
    Write-Host "Access Kibana:"
    Write-Host "  kubectl port-forward -n kibana svc/kibana 5601:5601"
    Write-Host ""
    Write-Host "View logs:"
    Write-Host "  kubectl logs -n elasticsearch deployment/elasticsearch"
    Write-Host "  kubectl logs -n kibana deployment/kibana"
    Write-Host ""
    Write-Host "=== Security Information ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Default credentials:"
    Write-Host "  Username: elastic"
    Write-Host "  Password: (check terraform.tfvars)"
    Write-Host ""
    Write-Warning "Remember to change default passwords in production!"
}

# Function to cleanup
function Remove-Infrastructure {
    Write-Status "Cleaning up..."
    
    # Navigate to the terraform directory from the scripts directory
    Set-Location "..\terraform"
    
    # Ask for confirmation
    Write-Host ""
    Write-Warning "This will destroy all infrastructure. Are you sure? (y/N)"
    $response = Read-Host
    if ($response -notmatch "^[Yy]$") {
        Write-Status "Cleanup cancelled."
        exit 0
    }
    
    # Destroy infrastructure
    terraform destroy -auto-approve
    
    Write-Success "Cleanup completed!"
}

# Main script logic
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Elastic and Terraform Deployment Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    "deploy" {
        Test-Prerequisites
        Test-Configuration
        Deploy-Infrastructure
        Set-KubectlConfig
        Test-Deployment
        Show-ConnectionInfo
    }
    "cleanup" {
        Remove-Infrastructure
    }
    "verify" {
        Set-Location "..\terraform"
        Set-KubectlConfig
        Test-Deployment
        Show-ConnectionInfo
    }
    "plan" {
        Set-Location "..\terraform"
        Test-Prerequisites
        Test-Configuration
        terraform init
        terraform plan
    }
    default {
        Write-Host "Usage: .\deploy.ps1 {deploy|cleanup|verify|plan}" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Yellow
        Write-Host "  deploy  - Deploy the complete infrastructure (default)" -ForegroundColor Yellow
        Write-Host "  cleanup - Destroy all infrastructure" -ForegroundColor Yellow
        Write-Host "  verify  - Verify existing deployment" -ForegroundColor Yellow
        Write-Host "  plan    - Show deployment plan without applying" -ForegroundColor Yellow
        exit 1
    }
}
