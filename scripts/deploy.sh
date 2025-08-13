#!/bin/bash

# Elastic and Terraform Deployment Script
# This script automates the deployment of Elasticsearch and Kibana on AWS EKS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All prerequisites are met!"
}

# Function to validate configuration
validate_config() {
    print_status "Validating Terraform configuration..."
    
    cd terraform
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_warning "Please edit terraform.tfvars with your configuration before continuing."
        exit 1
    fi
    
    # Validate Terraform configuration
    if ! terraform validate; then
        print_error "Terraform configuration validation failed."
        exit 1
    fi
    
    print_success "Configuration validation passed!"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure..."
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    print_status "Planning deployment..."
    terraform plan -out=tfplan
    
    # Ask for confirmation
    echo
    print_warning "Review the plan above. Do you want to proceed with the deployment? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled."
        exit 0
    fi
    
    # Apply deployment
    print_status "Applying deployment..."
    terraform apply tfplan
    
    print_success "Infrastructure deployment completed!"
}

# Function to configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl..."
    
    # Get cluster name from terraform output
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-west-2")
    
    # Update kubeconfig
    aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
    
    print_success "kubectl configured for cluster: $CLUSTER_NAME"
}

# Function to verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    # Wait for nodes to be ready
    print_status "Waiting for EKS nodes to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Check Elasticsearch pods
    print_status "Checking Elasticsearch pods..."
    kubectl wait --for=condition=Ready pods -l app=elasticsearch -n elasticsearch --timeout=600s
    
    # Check Kibana pods
    print_status "Checking Kibana pods..."
    kubectl wait --for=condition=Ready pods -l app=kibana -n kibana --timeout=300s
    
    print_success "Deployment verification completed!"
}

# Function to display connection information
display_info() {
    print_status "Deployment completed successfully!"
    echo
    echo "=== Connection Information ==="
    echo
    
    # Get outputs
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    ELASTICSEARCH_URL=$(terraform output -raw elasticsearch_url 2>/dev/null || echo "Not available yet")
    KIBANA_URL=$(terraform output -raw kibana_url 2>/dev/null || echo "Not available yet")
    KIBANA_ALB_URL=$(terraform output -raw kibana_alb_url 2>/dev/null || echo "Not available yet")
    
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Elasticsearch URL: $ELASTICSEARCH_URL"
    echo "Kibana URL: $KIBANA_URL"
    echo "Kibana ALB URL: $KIBANA_ALB_URL"
    echo
    echo "=== Useful Commands ==="
    echo
    echo "Check cluster status:"
    echo "  kubectl cluster-info"
    echo
    echo "View Elasticsearch pods:"
    echo "  kubectl get pods -n elasticsearch"
    echo
    echo "View Kibana pods:"
    echo "  kubectl get pods -n kibana"
    echo
    echo "Access Elasticsearch:"
    echo "  kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200"
    echo
    echo "Access Kibana:"
    echo "  kubectl port-forward -n kibana svc/kibana 5601:5601"
    echo
    echo "View logs:"
    echo "  kubectl logs -n elasticsearch deployment/elasticsearch"
    echo "  kubectl logs -n kibana deployment/kibana"
    echo
    echo "=== Security Information ==="
    echo
    echo "Default credentials:"
    echo "  Username: elastic"
    echo "  Password: (check terraform.tfvars)"
    echo
    print_warning "Remember to change default passwords in production!"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    
    cd terraform
    
    # Ask for confirmation
    echo
    print_warning "This will destroy all infrastructure. Are you sure? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Cleanup cancelled."
        exit 0
    fi
    
    # Destroy infrastructure
    terraform destroy -auto-approve
    
    print_success "Cleanup completed!"
}

# Main script logic
main() {
    echo "=========================================="
    echo "  Elastic and Terraform Deployment Script"
    echo "=========================================="
    echo
    
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            validate_config
            deploy_infrastructure
            configure_kubectl
            verify_deployment
            display_info
            ;;
        "cleanup")
            cleanup
            ;;
        "verify")
            cd terraform
            configure_kubectl
            verify_deployment
            display_info
            ;;
        "plan")
            cd terraform
            check_prerequisites
            validate_config
            terraform init
            terraform plan
            ;;
        *)
            echo "Usage: $0 {deploy|cleanup|verify|plan}"
            echo
            echo "Commands:"
            echo "  deploy  - Deploy the complete infrastructure (default)"
            echo "  cleanup - Destroy all infrastructure"
            echo "  verify  - Verify existing deployment"
            echo "  plan    - Show deployment plan without applying"
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 