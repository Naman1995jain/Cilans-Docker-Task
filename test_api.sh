#!/bin/bash

# Test script for Flask API
# This script tests all API endpoints

echo "======================================"
echo "Flask API Testing Script"
echo "======================================"
echo ""

BASE_URL="http://localhost:5000"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}Testing: ${description}${NC}"
    echo "Endpoint: ${method} ${endpoint}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X ${method} "${BASE_URL}${endpoint}")
    else
        response=$(curl -s -w "\n%{http_code}" -X ${method} "${BASE_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -d "${data}")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ Success (HTTP ${http_code})${NC}"
        echo "Response: ${body}" | jq '.' 2>/dev/null || echo "${body}"
    else
        echo -e "${RED}✗ Failed (HTTP ${http_code})${NC}"
        echo "Response: ${body}"
    fi
    echo ""
}

# Wait for service to be ready
echo "Waiting for Flask app to be ready..."
timeout 60 bash -c 'until curl -f http://localhost:5000/health 2>/dev/null; do sleep 2; done'
echo ""

# Test endpoints
echo "======================================"
echo "1. General Endpoints"
echo "======================================"
test_endpoint "GET" "/" "" "Root endpoint"
test_endpoint "GET" "/health" "" "Health check"
test_endpoint "GET" "/db-check" "" "Database connectivity check"

echo "======================================"
echo "2. User Endpoints"
echo "======================================"
test_endpoint "GET" "/api/users" "" "Get all users"
test_endpoint "GET" "/api/users/1" "" "Get user by ID"
test_endpoint "POST" "/api/users" '{"username":"testuser123","email":"testuser123@example.com"}' "Create new user"

echo "======================================"
echo "3. Product Endpoints"
echo "======================================"
test_endpoint "GET" "/api/products" "" "Get all products"
test_endpoint "GET" "/api/products/1" "" "Get product by ID"
test_endpoint "POST" "/api/products" '{"name":"Test Product","description":"A test product","price":49.99,"stock_quantity":100}' "Create new product"

echo "======================================"
echo "4. Order Endpoints"
echo "======================================"
test_endpoint "GET" "/api/orders" "" "Get all orders"
test_endpoint "POST" "/api/orders" '{"user_id":1,"items":[{"product_id":1,"quantity":2}],"status":"pending"}' "Create new order"

echo "======================================"
echo "Testing Complete!"
echo "======================================"
