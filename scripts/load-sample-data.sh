#!/bin/bash

# Load Sample Data Script
# This script loads all sample data into Elasticsearch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ELASTICSEARCH_URL=${ELASTICSEARCH_URL:-"http://localhost:9200"}
SAMPLE_DATA_DIR=${SAMPLE_DATA_DIR:-"sample-data"}

echo -e "${BLUE}🚀 Loading Sample Data into Elasticsearch${NC}"
echo -e "${BLUE}Elasticsearch URL: ${ELASTICSEARCH_URL}${NC}"
echo -e "${BLUE}Sample Data Directory: ${SAMPLE_DATA_DIR}${NC}"
echo ""

# Function to check if Elasticsearch is available
check_elasticsearch() {
    echo -e "${YELLOW}🔍 Checking Elasticsearch availability...${NC}"
    if curl -s "${ELASTICSEARCH_URL}/_cluster/health" > /dev/null; then
        echo -e "${GREEN}✅ Elasticsearch is available${NC}"
    else
        echo -e "${RED}❌ Elasticsearch is not available at ${ELASTICSEARCH_URL}${NC}"
        echo -e "${YELLOW}Please ensure Elasticsearch is running and accessible${NC}"
        exit 1
    fi
}

# Function to load data from a file
load_data() {
    local file=$1
    local index_name=$2
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ File not found: $file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}📊 Loading $index_name data...${NC}"
    
    if curl -s -X POST "${ELASTICSEARCH_URL}/_bulk" \
        -H "Content-Type: application/json" \
        --data-binary "@$file" > /dev/null; then
        echo -e "${GREEN}✅ Successfully loaded $index_name data${NC}"
    else
        echo -e "${RED}❌ Failed to load $index_name data${NC}"
        return 1
    fi
}

# Function to create index patterns in Kibana
create_index_patterns() {
    local kibana_url=${KIBANA_URL:-"http://localhost:5601"}
    
    echo -e "${YELLOW}📋 Creating index patterns in Kibana...${NC}"
    
    # E-commerce products index pattern
    curl -s -X POST "${kibana_url}/api/saved_objects/index-pattern/ecommerce-products" \
        -H "kbn-xsrf: true" \
        -H "Content-Type: application/json" \
        -d '{"attributes":{"title":"ecommerce-products*","timeFieldName":"created_at"}}' > /dev/null
    
    # Web logs index pattern
    curl -s -X POST "${kibana_url}/api/saved_objects/index-pattern/web-logs" \
        -H "kbn-xsrf: true" \
        -H "Content-Type: application/json" \
        -d '{"attributes":{"title":"web-logs*","timeFieldName":"timestamp"}}' > /dev/null
    
    # Customer orders index pattern
    curl -s -X POST "${kibana_url}/api/saved_objects/index-pattern/customer-orders" \
        -H "kbn-xsrf: true" \
        -H "Content-Type: application/json" \
        -d '{"attributes":{"title":"customer-orders*","timeFieldName":"order_date"}}' > /dev/null
    
    # System metrics index pattern
    curl -s -X POST "${kibana_url}/api/saved_objects/index-pattern/system-metrics" \
        -H "kbn-xsrf: true" \
        -H "Content-Type: application/json" \
        -d '{"attributes":{"title":"system-metrics*","timeFieldName":"timestamp"}}' > /dev/null
    
    echo -e "${GREEN}✅ Index patterns created${NC}"
}

# Function to verify data was loaded
verify_data() {
    echo -e "${YELLOW}🔍 Verifying loaded data...${NC}"
    
    # Check indices
    echo -e "${BLUE}📊 Available indices:${NC}"
    curl -s "${ELASTICSEARCH_URL}/_cat/indices?v"
    
    echo ""
    echo -e "${BLUE}📈 Document counts:${NC}"
    echo -e "E-commerce Products: $(curl -s "${ELASTICSEARCH_URL}/ecommerce-products/_count" | jq -r '.count')"
    echo -e "Web Logs: $(curl -s "${ELASTICSEARCH_URL}/web-logs/_count" | jq -r '.count')"
    echo -e "Customer Orders: $(curl -s "${ELASTICSEARCH_URL}/customer-orders/_count" | jq -r '.count')"
    echo -e "System Metrics: $(curl -s "${ELASTICSEARCH_URL}/system-metrics/_count" | jq -r '.count')"
}

# Main execution
main() {
    echo -e "${BLUE}🎯 Starting sample data loading process...${NC}"
    echo ""
    
    # Check if Elasticsearch is available
    check_elasticsearch
    echo ""
    
    # Load sample data
    load_data "${SAMPLE_DATA_DIR}/ecommerce-products.json" "ecommerce-products"
    load_data "${SAMPLE_DATA_DIR}/web-logs.json" "web-logs"
    load_data "${SAMPLE_DATA_DIR}/customer-orders.json" "customer-orders"
    load_data "${SAMPLE_DATA_DIR}/system-metrics.json" "system-metrics"
    echo ""
    
    # Create index patterns (optional)
    if [ "$CREATE_INDEX_PATTERNS" = "true" ]; then
        create_index_patterns
        echo ""
    fi
    
    # Verify data
    verify_data
    echo ""
    
    echo -e "${GREEN}🎉 Sample data loading completed successfully!${NC}"
    echo -e "${BLUE}You can now access your data in Kibana at: ${KIBANA_URL:-http://localhost:5601}${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --elasticsearch-url)
            ELASTICSEARCH_URL="$2"
            shift 2
            ;;
        --kibana-url)
            KIBANA_URL="$2"
            shift 2
            ;;
        --sample-data-dir)
            SAMPLE_DATA_DIR="$2"
            shift 2
            ;;
        --create-index-patterns)
            CREATE_INDEX_PATTERNS="true"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --elasticsearch-url URL     Elasticsearch URL (default: http://localhost:9200)"
            echo "  --kibana-url URL            Kibana URL (default: http://localhost:5601)"
            echo "  --sample-data-dir DIR       Sample data directory (default: sample-data)"
            echo "  --create-index-patterns     Create index patterns in Kibana"
            echo "  --help                      Show this help message"
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
