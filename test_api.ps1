# PowerShell Test Script for Flask API
# This script tests all API endpoints on Windows

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Flask API Testing Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$BaseUrl = "http://localhost:5000"

# Function to test endpoint
function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Data,
        [string]$Description
    )
    
    Write-Host "Testing: $Description" -ForegroundColor Yellow
    Write-Host "Endpoint: $Method $Endpoint"
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $params = @{
            Uri = "$BaseUrl$Endpoint"
            Method = $Method
            Headers = $headers
        }
        
        if ($Data) {
            $params.Body = $Data
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "✓ Success" -ForegroundColor Green
        Write-Host "Response:" ($response | ConvertTo-Json -Depth 10)
    }
    catch {
        Write-Host "✗ Failed" -ForegroundColor Red
        Write-Host "Error: $_"
    }
    Write-Host ""
}

# Wait for service to be ready
Write-Host "Waiting for Flask app to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/health" -Method Get -ErrorAction Stop
        Write-Host "Flask app is ready!" -ForegroundColor Green
        break
    }
    catch {
        $attempt++
        Start-Sleep -Seconds 2
    }
}
Write-Host ""

# Test endpoints
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "1. General Endpoints" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Endpoint "/" -Description "Root endpoint"
Test-Endpoint -Method "GET" -Endpoint "/health" -Description "Health check"
Test-Endpoint -Method "GET" -Endpoint "/db-check" -Description "Database connectivity check"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "2. User Endpoints" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Endpoint "/api/users" -Description "Get all users"
Test-Endpoint -Method "GET" -Endpoint "/api/users/1" -Description "Get user by ID"
Test-Endpoint -Method "POST" -Endpoint "/api/users" -Data '{"username":"testuser123","email":"testuser123@example.com"}' -Description "Create new user"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "3. Product Endpoints" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Endpoint "/api/products" -Description "Get all products"
Test-Endpoint -Method "GET" -Endpoint "/api/products/1" -Description "Get product by ID"
Test-Endpoint -Method "POST" -Endpoint "/api/products" -Data '{"name":"Test Product","description":"A test product","price":49.99,"stock_quantity":100}' -Description "Create new product"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "4. Order Endpoints" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Endpoint "/api/orders" -Description "Get all orders"
Test-Endpoint -Method "POST" -Endpoint "/api/orders" -Data '{"user_id":1,"items":[{"product_id":1,"quantity":2}],"status":"pending"}' -Description "Create new order"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing Complete!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
