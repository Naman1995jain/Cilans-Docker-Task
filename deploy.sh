#!/bin/bash

# Deployment helper script for self-hosted server
# This script helps set up and deploy the Flask application

set -e

echo "======================================"
echo "Flask App Deployment Helper"
echo "======================================"
echo ""

# Configuration
APP_DIR="$HOME/flask-app"
REPO_URL="${1:-}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Docker is installed
check_docker() {
    print_info "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "Install Docker with: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
        exit 1
    fi
    print_success "Docker is installed"
}

# Check if Docker Compose is installed
check_docker_compose() {
    print_info "Checking Docker Compose installation..."
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed"
        echo "Install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Create application directory
create_app_dir() {
    print_info "Creating application directory..."
    mkdir -p "$APP_DIR"
    cd "$APP_DIR"
    print_success "Application directory created: $APP_DIR"
}

# Clone or update repository
setup_repository() {
    if [ -z "$REPO_URL" ]; then
        print_error "Repository URL not provided"
        echo "Usage: ./deploy.sh <repository-url>"
        exit 1
    fi
    
    if [ -d .git ]; then
        print_info "Updating repository..."
        git pull origin main || git pull origin master
        print_success "Repository updated"
    else
        print_info "Cloning repository..."
        git clone "$REPO_URL" .
        print_success "Repository cloned"
    fi
}

# Create environment file
create_env_file() {
    print_info "Creating .env file..."
    
    if [ -f .env ]; then
        print_info ".env file already exists, skipping..."
        return
    fi
    
    read -p "Enter database user (default: postgres): " db_user
    db_user=${db_user:-postgres}
    
    read -sp "Enter database password (default: dragon): " db_password
    echo ""
    db_password=${db_password:-dragon}
    
    read -p "Enter Flask secret key (press enter for random): " secret_key
    if [ -z "$secret_key" ]; then
        secret_key=$(openssl rand -hex 32)
    fi
    
    cat > .env << EOF
# Flask configuration
FLASK_APP=run.py
FLASK_ENV=production
SECRET_KEY=$secret_key

# Database configuration
DB_USER=$db_user
DB_PASSWORD=$db_password
DB_HOST=postgres
DB_PORT=5432
DB_NAME=flaskdb

# Database URLs
DATABASE_URL=postgresql://$db_user:$db_password@postgres:5432/flaskdb
TEST_DATABASE_URL=postgresql://$db_user:$db_password@postgres:5432/testdb

# Application configuration
PORT=5000
EOF
    
    print_success ".env file created"
}

# Deploy application
deploy_app() {
    print_info "Stopping existing containers..."
    docker-compose down || true
    
    print_info "Building and starting containers..."
    docker-compose up -d --build
    
    print_success "Containers started"
}

# Wait for services
wait_for_services() {
    print_info "Waiting for services to be ready..."
    sleep 30
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Containers are running"
    else
        print_error "Containers failed to start"
        docker-compose logs
        exit 1
    fi
}

# Verify deployment
verify_deployment() {
    print_info "Verifying deployment..."
    
    # Test health endpoint
    if curl -f http://localhost:5000/health &> /dev/null; then
        print_success "Health check passed"
    else
        print_error "Health check failed"
        docker-compose logs flask-app
        exit 1
    fi
    
    # Test database connectivity
    if curl -f http://localhost:5000/db-check &> /dev/null; then
        print_success "Database check passed"
    else
        print_error "Database check failed"
        docker-compose logs
        exit 1
    fi
}

# Show status
show_status() {
    echo ""
    echo "======================================"
    echo "Deployment Status"
    echo "======================================"
    docker-compose ps
    echo ""
    echo "Application URL: http://localhost:5000"
    echo "Health Check: http://localhost:5000/health"
    echo "Database Check: http://localhost:5000/db-check"
    echo ""
    echo "View logs: docker-compose logs -f"
    echo "Stop app: docker-compose down"
    echo "Restart app: docker-compose restart"
    echo "======================================"
}

# Main deployment flow
main() {
    check_docker
    check_docker_compose
    create_app_dir
    
    if [ -n "$REPO_URL" ]; then
        setup_repository
    fi
    
    create_env_file
    deploy_app
    wait_for_services
    verify_deployment
    show_status
    
    print_success "Deployment completed successfully!"
}

# Run main function
main
