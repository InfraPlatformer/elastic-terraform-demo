#!/bin/bash

# Cross-Cloud Communication Setup Script
# This script sets up cross-cluster search between AWS and Azure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_CLUSTER=${AWS_CLUSTER:-"elastic-stack-cluster"}
AWS_REGION=${AWS_REGION:-"us-west-2"}
AZURE_CLUSTER=${AZURE_CLUSTER:-"elastic-aks"}
AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP:-"elastic-stack-staging-rg"}

echo -e "${BLUE}🌐 Setting up Cross-Cloud Communication${NC}"
echo -e "${BLUE}AWS Cluster: ${AWS_CLUSTER} (${AWS_REGION})${NC}"
echo -e "${BLUE}Azure Cluster: ${AZURE_CLUSTER} (${AZURE_RESOURCE_GROUP})${NC}"
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed${NC}"
        exit 1
    fi
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI is not installed${NC}"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites are installed${NC}"
}

# Function to configure AWS kubectl
configure_aws_kubectl() {
    echo -e "${YELLOW}⚙️ Configuring AWS kubectl...${NC}"
    
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${AWS_CLUSTER}"
    
    # Verify connection
    if kubectl get nodes &> /dev/null; then
        echo -e "${GREEN}✅ AWS cluster connection successful${NC}"
    else
        echo -e "${RED}❌ Failed to connect to AWS cluster${NC}"
        exit 1
    fi
}

# Function to configure Azure kubectl
configure_azure_kubectl() {
    echo -e "${YELLOW}⚙️ Configuring Azure kubectl...${NC}"
    
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${AZURE_CLUSTER}" \
        --overwrite-existing
    
    # Verify connection
    if kubectl get nodes &> /dev/null; then
        echo -e "${GREEN}✅ Azure cluster connection successful${NC}"
    else
        echo -e "${RED}❌ Failed to connect to Azure cluster${NC}"
        exit 1
    fi
}

# Function to get AWS Elasticsearch endpoint
get_aws_elasticsearch_endpoint() {
    echo -e "${YELLOW}🔍 Getting AWS Elasticsearch endpoint...${NC}"
    
    # Switch to AWS context
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${AWS_CLUSTER}"
    
    # Get Elasticsearch service
    AWS_ELASTICSEARCH_ENDPOINT=$(kubectl get service elasticsearch -n elasticsearch -o jsonpath='{.spec.clusterIP}')
    
    if [ -n "$AWS_ELASTICSEARCH_ENDPOINT" ]; then
        echo -e "${GREEN}✅ AWS Elasticsearch endpoint: ${AWS_ELASTICSEARCH_ENDPOINT}${NC}"
    else
        echo -e "${RED}❌ Failed to get AWS Elasticsearch endpoint${NC}"
        exit 1
    fi
}

# Function to get Azure Elasticsearch endpoint
get_azure_elasticsearch_endpoint() {
    echo -e "${YELLOW}🔍 Getting Azure Elasticsearch endpoint...${NC}"
    
    # Switch to Azure context
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${AZURE_CLUSTER}" \
        --overwrite-existing
    
    # Get Elasticsearch service
    AZURE_ELASTICSEARCH_ENDPOINT=$(kubectl get service elasticsearch -n elasticsearch -o jsonpath='{.spec.clusterIP}')
    
    if [ -n "$AZURE_ELASTICSEARCH_ENDPOINT" ]; then
        echo -e "${GREEN}✅ Azure Elasticsearch endpoint: ${AZURE_ELASTICSEARCH_ENDPOINT}${NC}"
    else
        echo -e "${RED}❌ Failed to get Azure Elasticsearch endpoint${NC}"
        exit 1
    fi
}

# Function to configure cross-cluster search
configure_cross_cluster_search() {
    echo -e "${YELLOW}🔗 Configuring cross-cluster search...${NC}"
    
    # Create cross-cluster search configuration
    cat > cross-cluster-search.json << EOF
{
  "persistent": {
    "cluster.remote.aws_cluster.seeds": ["${AWS_ELASTICSEARCH_ENDPOINT}:9300"],
    "cluster.remote.azure_cluster.seeds": ["${AZURE_ELASTICSEARCH_ENDPOINT}:9300"]
  }
}
EOF
    
    echo -e "${BLUE}Cross-cluster search configuration created${NC}"
    cat cross-cluster-search.json
}

# Function to apply cross-cluster search to AWS
apply_cross_cluster_search_aws() {
    echo -e "${YELLOW}🔗 Applying cross-cluster search to AWS...${NC}"
    
    # Switch to AWS context
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${AWS_CLUSTER}"
    
    # Apply configuration
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/_cluster/settings" \
        -H "Content-Type: application/json" \
        -d @cross-cluster-search.json
    
    echo -e "${GREEN}✅ Cross-cluster search applied to AWS${NC}"
}

# Function to apply cross-cluster search to Azure
apply_cross_cluster_search_azure() {
    echo -e "${YELLOW}🔗 Applying cross-cluster search to Azure...${NC}"
    
    # Switch to Azure context
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${AZURE_CLUSTER}" \
        --overwrite-existing
    
    # Apply configuration
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/_cluster/settings" \
        -H "Content-Type: application/json" \
        -d @cross-cluster-search.json
    
    echo -e "${GREEN}✅ Cross-cluster search applied to Azure${NC}"
}

# Function to test cross-cluster search
test_cross_cluster_search() {
    echo -e "${YELLOW}🧪 Testing cross-cluster search...${NC}"
    
    # Test from AWS
    echo -e "${BLUE}Testing from AWS cluster...${NC}"
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${AWS_CLUSTER}"
    
    # Check remote clusters
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s "localhost:9200/_remote/info"
    
    # Test from Azure
    echo -e "${BLUE}Testing from Azure cluster...${NC}"
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${AZURE_CLUSTER}" \
        --overwrite-existing
    
    # Check remote clusters
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s "localhost:9200/_remote/info"
    
    echo -e "${GREEN}✅ Cross-cluster search test completed${NC}"
}

# Function to create cross-cluster indices
create_cross_cluster_indices() {
    echo -e "${YELLOW}📊 Creating cross-cluster indices...${NC}"
    
    # Create index on AWS
    echo -e "${BLUE}Creating index on AWS...${NC}"
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${AWS_CLUSTER}"
    
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/aws-data" \
        -H "Content-Type: application/json" \
        -d '{"settings":{"number_of_shards":1,"number_of_replicas":0}}'
    
    # Create index on Azure
    echo -e "${BLUE}Creating index on Azure...${NC}"
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${AZURE_CLUSTER}" \
        --overwrite-existing
    
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X PUT "localhost:9200/azure-data" \
        -H "Content-Type: application/json" \
        -d '{"settings":{"number_of_shards":1,"number_of_replicas":0}}'
    
    echo -e "${GREEN}✅ Cross-cluster indices created${NC}"
}

# Function to test cross-cluster queries
test_cross_cluster_queries() {
    echo -e "${YELLOW}🔍 Testing cross-cluster queries...${NC}"
    
    # Test query from AWS to Azure
    echo -e "${BLUE}Testing query from AWS to Azure...${NC}"
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${AWS_CLUSTER}"
    
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X GET "localhost:9200/azure_cluster:azure-data/_search" \
        -H "Content-Type: application/json" \
        -d '{"query":{"match_all":{}}}'
    
    # Test query from Azure to AWS
    echo -e "${BLUE}Testing query from Azure to AWS...${NC}"
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${AZURE_CLUSTER}" \
        --overwrite-existing
    
    kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X GET "localhost:9200/aws_cluster:aws-data/_search" \
        -H "Content-Type: application/json" \
        -d '{"query":{"match_all":{}}}'
    
    echo -e "${GREEN}✅ Cross-cluster queries test completed${NC}"
}

# Function to display cross-cloud information
display_cross_cloud_info() {
    echo -e "${GREEN}🎉 Cross-cloud communication setup completed!${NC}"
    echo ""
    echo -e "${BLUE}📋 Cross-Cloud Information:${NC}"
    echo -e "=========================="
    echo -e "🌐 AWS Cluster: ${AWS_CLUSTER} (${AWS_REGION})"
    echo -e "🌐 Azure Cluster: ${AZURE_CLUSTER} (${AZURE_RESOURCE_GROUP})"
    echo -e "🔗 Cross-cluster search: Enabled"
    echo -e "📊 Cross-cluster indices: aws-data, azure-data"
    echo ""
    echo -e "${BLUE}🔍 Test Commands:${NC}"
    echo -e "=================="
    echo -e "Check remote clusters:"
    echo -e "  kubectl exec -n elasticsearch deployment/elasticsearch -- curl -s 'localhost:9200/_remote/info'"
    echo ""
    echo -e "Query cross-cluster data:"
    echo -e "  # From AWS to Azure:"
    echo -e "  kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X GET 'localhost:9200/azure_cluster:azure-data/_search'"
    echo -e "  # From Azure to AWS:"
    echo -e "  kubectl exec -n elasticsearch deployment/elasticsearch -- curl -X GET 'localhost:9200/aws_cluster:aws-data/_search'"
    echo ""
    echo -e "${BLUE}📚 Next Steps:${NC}"
    echo -e "============="
    echo -e "1. Set up data replication between clusters"
    echo -e "2. Configure cross-cluster monitoring"
    echo -e "3. Set up cross-cluster backup and recovery"
    echo -e "4. Implement cross-cluster security policies"
}

# Main execution
main() {
    check_prerequisites
    configure_aws_kubectl
    configure_azure_kubectl
    get_aws_elasticsearch_endpoint
    get_azure_elasticsearch_endpoint
    configure_cross_cluster_search
    apply_cross_cluster_search_aws
    apply_cross_cluster_search_azure
    test_cross_cluster_search
    create_cross_cluster_indices
    test_cross_cluster_queries
    display_cross_cloud_info
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --aws-cluster)
            AWS_CLUSTER="$2"
            shift 2
            ;;
        --aws-region)
            AWS_REGION="$2"
            shift 2
            ;;
        --azure-cluster)
            AZURE_CLUSTER="$2"
            shift 2
            ;;
        --azure-resource-group)
            AZURE_RESOURCE_GROUP="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --aws-cluster NAME         AWS cluster name (default: elastic-stack-cluster)"
            echo "  --aws-region REGION        AWS region (default: us-west-2)"
            echo "  --azure-cluster NAME       Azure cluster name (default: elastic-aks)"
            echo "  --azure-resource-group RG  Azure resource group (default: elastic-stack-staging-rg)"
            echo "  --help                     Show this help message"
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
