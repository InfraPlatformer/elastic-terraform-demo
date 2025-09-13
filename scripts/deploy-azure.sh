#!/bin/bash

# Deploy Azure Infrastructure Script
# This script deploys the Elastic Stack on Azure AKS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${ENVIRONMENT:-"azure-staging"}
AZURE_REGION=${AZURE_REGION:-"West US 2"}
CLUSTER_NAME=${CLUSTER_NAME:-"elastic-aks"}
RESOURCE_GROUP=${RESOURCE_GROUP:-"elastic-stack-staging-rg"}

echo -e "${BLUE}🚀 Deploying Elastic Stack on Azure AKS${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Azure Region: ${AZURE_REGION}${NC}"
echo -e "${BLUE}Cluster Name: ${CLUSTER_NAME}${NC}"
echo -e "${BLUE}Resource Group: ${RESOURCE_GROUP}${NC}"
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI is not installed${NC}"
        echo -e "${YELLOW}Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${NC}"
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

# Function to check Azure credentials
check_azure_credentials() {
    echo -e "${YELLOW}🔍 Checking Azure credentials...${NC}"
    
    if az account show &> /dev/null; then
        echo -e "${GREEN}✅ Azure credentials are configured${NC}"
        echo -e "${BLUE}Current subscription: $(az account show --query name -o tsv)${NC}"
    else
        echo -e "${RED}❌ Azure credentials are not configured${NC}"
        echo -e "${YELLOW}Please run 'az login' to authenticate${NC}"
        exit 1
    fi
}

# Function to create resource group
create_resource_group() {
    echo -e "${YELLOW}🏗️ Creating Azure Resource Group...${NC}"
    
    if az group show --name "${RESOURCE_GROUP}" &> /dev/null; then
        echo -e "${BLUE}Resource group ${RESOURCE_GROUP} already exists${NC}"
    else
        az group create \
            --name "${RESOURCE_GROUP}" \
            --location "${AZURE_REGION}" \
            --tags Environment=staging Project=elastic-stack ManagedBy=terraform
        
        echo -e "${GREEN}✅ Resource group created successfully${NC}"
    fi
}

# Function to deploy infrastructure
deploy_infrastructure() {
    echo -e "${YELLOW}🏗️ Deploying Azure infrastructure...${NC}"
    
    cd "environments/${ENVIRONMENT}"
    
    # Initialize Terraform
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
    
    # Plan deployment
    echo -e "${BLUE}Planning deployment...${NC}"
    terraform plan -out=tfplan
    
    # Apply deployment
    echo -e "${BLUE}Applying deployment...${NC}"
    terraform apply tfplan
    
    cd ../..
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
}

# Function to configure kubectl
configure_kubectl() {
    echo -e "${YELLOW}⚙️ Configuring kubectl...${NC}"
    
    az aks get-credentials \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${CLUSTER_NAME}" \
        --overwrite-existing
    
    echo -e "${GREEN}✅ kubectl configured successfully${NC}"
}

# Function to verify deployment
verify_deployment() {
    echo -e "${YELLOW}🔍 Verifying deployment...${NC}"
    
    # Check cluster status
    echo -e "${BLUE}Checking AKS cluster status...${NC}"
    az aks show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${CLUSTER_NAME}" \
        --query "provisioningState" -o tsv
    
    # Check nodes
    echo -e "${BLUE}Checking cluster nodes...${NC}"
    kubectl get nodes
    
    # Check pods
    echo -e "${BLUE}Checking deployed pods...${NC}"
    kubectl get pods --all-namespaces
    
    # Check services
    echo -e "${BLUE}Checking services...${NC}"
    kubectl get services --all-namespaces
    
    echo -e "${GREEN}✅ Deployment verification completed${NC}"
}

# Function to get service URLs
get_service_urls() {
    echo -e "${YELLOW}🌐 Getting service URLs...${NC}"
    
    # Get Kibana URL
    KIBANA_IP=$(kubectl get service kibana -n kibana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -n "$KIBANA_IP" ]; then
        KIBANA_URL="http://${KIBANA_IP}:5601"
        echo -e "${GREEN}✅ Kibana URL: ${KIBANA_URL}${NC}"
    else
        echo -e "${YELLOW}⚠️ Kibana LoadBalancer not ready yet${NC}"
        KIBANA_URL="Use port-forward: kubectl port-forward -n kibana svc/kibana 5601:5601"
    fi
    
    # Get Grafana URL
    GRAFANA_IP=$(kubectl get service grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -n "$GRAFANA_IP" ]; then
        GRAFANA_URL="http://${GRAFANA_IP}:3000"
        echo -e "${GREEN}✅ Grafana URL: ${GRAFANA_URL}${NC}"
    else
        echo -e "${YELLOW}⚠️ Grafana LoadBalancer not ready yet${NC}"
        GRAFANA_URL="Use port-forward: kubectl port-forward -n monitoring svc/grafana 3000:3000"
    fi
    
    # Elasticsearch URL
    ELASTICSEARCH_URL="Use port-forward: kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200"
    echo -e "${BLUE}Elasticsearch URL: ${ELASTICSEARCH_URL}${NC}"
}

# Function to load sample data
load_sample_data() {
    echo -e "${YELLOW}📊 Loading sample data...${NC}"
    
    # Set up port-forward for Elasticsearch
    kubectl port-forward -n elasticsearch svc/elasticsearch 9200:9200 &
    sleep 10
    
    # Load sample data
    chmod +x scripts/load-sample-data.sh
    ./scripts/load-sample-data.sh --elasticsearch-url "http://localhost:9200" --create-index-patterns
    
    echo -e "${GREEN}✅ Sample data loaded successfully${NC}"
}

# Function to display access information
display_access_info() {
    echo -e "${GREEN}🎉 Azure deployment completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 Access Information:${NC}"
    echo -e "====================="
    echo -e "🔍 Elasticsearch: ${ELASTICSEARCH_URL}"
    echo -e "📊 Kibana: ${KIBANA_URL}"
    echo -e "📈 Grafana: ${GRAFANA_URL}"
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
    echo ""
    echo -e "${BLUE}💰 Estimated Monthly Cost:${NC}"
    echo -e "============================="
    echo -e "AKS Control Plane: Free"
    echo -e "Worker Nodes (3x Standard_D4s_v3): ~$360-600/month"
    echo -e "Application Gateway: ~$20-50/month"
    echo -e "Container Registry: ~$5/month"
    echo -e "Key Vault: ~$1/month"
    echo -e "Log Analytics: ~$10-30/month"
    echo -e "Total: ~$396-686/month"
}

# Main execution
main() {
    check_prerequisites
    check_azure_credentials
    create_resource_group
    deploy_infrastructure
    configure_kubectl
    verify_deployment
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
        --azure-region)
            AZURE_REGION="$2"
            shift 2
            ;;
        --cluster-name)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        --resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        --skip-sample-data)
            SKIP_SAMPLE_DATA="true"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --environment ENV        Environment name (default: azure-staging)"
            echo "  --azure-region REGION    Azure region (default: West US 2)"
            echo "  --cluster-name NAME      Cluster name (default: elastic-aks)"
            echo "  --resource-group NAME    Resource group name (default: elastic-stack-staging-rg)"
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
