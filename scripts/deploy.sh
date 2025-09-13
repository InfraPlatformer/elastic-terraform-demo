#!/bin/bash

# Deploy Script for Elastic Stack on AWS
# This script automates the deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${ENVIRONMENT:-"staging"}
AWS_REGION=${AWS_REGION:-"us-west-2"}
CLUSTER_NAME=${CLUSTER_NAME:-"elastic-stack-cluster"}

echo -e "${BLUE}🚀 Deploying Elastic Stack on AWS${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}AWS Region: ${AWS_REGION}${NC}"
echo -e "${BLUE}Cluster Name: ${CLUSTER_NAME}${NC}"
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed${NC}"
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform is not installed${NC}"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed${NC}"
        exit 1
    fi
    
    # Check Helm
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}❌ Helm is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites are installed${NC}"
}

# Function to check AWS credentials
check_aws_credentials() {
    echo -e "${YELLOW}🔍 Checking AWS credentials...${NC}"
    
    if aws sts get-caller-identity &> /dev/null; then
        echo -e "${GREEN}✅ AWS credentials are configured${NC}"
    else
        echo -e "${RED}❌ AWS credentials are not configured${NC}"
        echo -e "${YELLOW}Please run 'aws configure' to set up your credentials${NC}"
        exit 1
    fi
}

# Function to deploy infrastructure
deploy_infrastructure() {
    echo -e "${YELLOW}🏗️ Deploying infrastructure...${NC}"
    
    cd "environments/${ENVIRONMENT}"
    
    # Initialize Terraform
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
    
    # Plan deployment
    echo -e "${BLUE}Planning deployment...${NC}"
    terraform plan
    
    # Apply deployment
    echo -e "${BLUE}Applying deployment...${NC}"
    terraform apply -auto-approve
    
    cd ../..
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
}

# Function to configure kubectl
configure_kubectl() {
    echo -e "${YELLOW}⚙️ Configuring kubectl...${NC}"
    
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"
    
    echo -e "${GREEN}✅ kubectl configured successfully${NC}"
}

# Function to deploy applications
deploy_applications() {
    echo -e "${YELLOW}📦 Deploying applications...${NC}"
    
    # Deploy Elasticsearch
    echo -e "${BLUE}Deploying Elasticsearch...${NC}"
    kubectl apply -f k8s/elasticsearch/
    
    # Deploy Kibana
    echo -e "${BLUE}Deploying Kibana...${NC}"
    kubectl apply -f k8s/kibana/
    
    # Deploy Grafana
    echo -e "${BLUE}Deploying Grafana...${NC}"
    kubectl apply -f k8s/grafana/
    
    # Deploy Prometheus
    echo -e "${BLUE}Deploying Prometheus...${NC}"
    kubectl apply -f k8s/prometheus/
    
    echo -e "${GREEN}✅ Applications deployed successfully${NC}"
}

# Function to wait for deployments
wait_for_deployments() {
    echo -e "${YELLOW}⏳ Waiting for deployments to be ready...${NC}"
    
    # Wait for Elasticsearch
    kubectl wait --for=condition=available --timeout=300s deployment/elasticsearch -n elasticsearch
    
    # Wait for Kibana
    kubectl wait --for=condition=available --timeout=300s deployment/kibana -n kibana
    
    # Wait for Grafana
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring
    
    # Wait for Prometheus
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
    
    echo -e "${GREEN}✅ All deployments are ready${NC}"
}

# Function to get service URLs
get_service_urls() {
    echo -e "${YELLOW}🌐 Getting service URLs...${NC}"
    
    # Get Elasticsearch URL
    ELASTICSEARCH_URL=$(kubectl get service elasticsearch -n elasticsearch -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$ELASTICSEARCH_URL" ]; then
        ELASTICSEARCH_URL="localhost:9200"
        echo -e "${YELLOW}⚠️ Elasticsearch LoadBalancer not available, using port-forward${NC}"
    fi
    
    # Get Kibana URL
    KIBANA_URL=$(kubectl get service kibana -n kibana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$KIBANA_URL" ]; then
        KIBANA_URL="localhost:5601"
        echo -e "${YELLOW}⚠️ Kibana LoadBalancer not available, using port-forward${NC}"
    fi
    
    # Get Grafana URL
    GRAFANA_URL=$(kubectl get service grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$GRAFANA_URL" ]; then
        GRAFANA_URL="localhost:3000"
        echo -e "${YELLOW}⚠️ Grafana LoadBalancer not available, using port-forward${NC}"
    fi
    
    echo -e "${GREEN}✅ Service URLs retrieved${NC}"
}

# Function to load sample data
load_sample_data() {
    echo -e "${YELLOW}📊 Loading sample data...${NC}"
    
    # Set up port-forward if needed
    if [ "$ELASTICSEARCH_URL" = "localhost:9200" ]; then
        kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200 &
        sleep 10
    fi
    
    # Load sample data
    chmod +x scripts/load-sample-data.sh
    ./scripts/load-sample-data.sh --elasticsearch-url "http://${ELASTICSEARCH_URL}" --create-index-patterns
    
    echo -e "${GREEN}✅ Sample data loaded successfully${NC}"
}

# Function to display access information
display_access_info() {
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 Access Information:${NC}"
    echo -e "====================="
    echo -e "🔍 Elasticsearch: http://${ELASTICSEARCH_URL}"
    echo -e "📊 Kibana: http://${KIBANA_URL}"
    echo -e "📈 Grafana: http://${GRAFANA_URL}"
    echo ""
    echo -e "${BLUE}🔐 Default Credentials:${NC}"
    echo -e "========================"
    echo -e "Grafana: admin / admin123"
    echo -e "Elasticsearch: No authentication required"
    echo -e "Kibana: No authentication required"
    echo ""
    echo -e "${BLUE}📚 Next Steps:${NC}"
    echo -e "============="
    echo -e "1. Access Kibana to explore your data"
    echo -e "2. Create custom dashboards"
    echo -e "3. Set up monitoring alerts"
    echo -e "4. Explore the sample data"
}

# Main execution
main() {
    check_prerequisites
    check_aws_credentials
    deploy_infrastructure
    configure_kubectl
    deploy_applications
    wait_for_deployments
    get_service_urls
    load_sample_data
    display_access_info
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --aws-region)
            AWS_REGION="$2"
            shift 2
            ;;
        --cluster-name)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        --skip-sample-data)
            SKIP_SAMPLE_DATA="true"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --environment ENV        Environment name (default: staging)"
            echo "  --aws-region REGION      AWS region (default: us-west-2)"
            echo "  --cluster-name NAME      Cluster name (default: elastic-stack-cluster)"
            echo "  --skip-sample-data       Skip loading sample data"
            echo "  --help                   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main
