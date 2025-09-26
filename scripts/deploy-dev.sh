#!/bin/bash

# Development Deployment Script for Zeeky Social on Netlify
# This script helps deploy the Flutter web app to Netlify in development mode

set -e  # Exit on any error

echo "🚀 Starting Zeeky Social Development Deployment..."

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

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v netlify &> /dev/null; then
        print_warning "Netlify CLI is not installed. Installing..."
        npm install -g netlify-cli
    fi
    
    print_success "Dependencies check complete"
}

# Validate environment variables
validate_env() {
    print_status "Validating environment variables..."
    
    # Check if .env.development exists
    if [ ! -f ".env.development" ]; then
        print_warning ".env.development file not found. Creating template..."
        cp .env.example .env.development
        print_warning "Please edit .env.development with your development configuration"
    fi
    
    # Check for required Firebase configuration
    required_vars=("FIREBASE_API_KEY" "FIREBASE_AUTH_DOMAIN" "FIREBASE_PROJECT_ID" "FIREBASE_STORAGE_BUCKET" "FIREBASE_MESSAGING_SENDER_ID" "FIREBASE_APP_ID")
    
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        print_warning "Missing environment variables: ${missing_vars[*]}"
        print_warning "Make sure to set these in your Netlify site settings or .env.development file"
    else
        print_success "Environment variables validation complete"
    fi
}

# Clean and prepare for build
clean_build() {
    print_status "Cleaning previous build..."
    
    if [ -d "build" ]; then
        rm -rf build
        print_success "Cleaned build directory"
    fi
    
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    print_success "Build preparation complete"
}

# Build Flutter web app for development
build_app() {
    print_status "Building Flutter web app for development..."
    
    # Build with debug mode and source maps for development
    flutter build web \
        --debug \
        --web-renderer html \
        --source-maps \
        --dart-define=FLUTTER_WEB_USE_SKIA=false \
        --dart-define=FLUTTER_WEB_DEBUG=true
    
    if [ $? -eq 0 ]; then
        print_success "Flutter build completed successfully"
    else
        print_error "Flutter build failed"
        exit 1
    fi
}

# Deploy to Netlify
deploy_to_netlify() {
    print_status "Deploying to Netlify..."
    
    # Check if this is a preview deployment or production
    if [ "$1" = "preview" ]; then
        print_status "Deploying as preview..."
        netlify deploy --config-path netlify.dev.toml --dir build/web
    elif [ "$1" = "production" ]; then
        print_status "Deploying to production..."
        netlify deploy --config-path netlify.dev.toml --dir build/web --prod
    else
        print_status "Deploying as draft..."
        netlify deploy --config-path netlify.dev.toml --dir build/web
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Deployment completed successfully"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Run development server locally
run_local_dev() {
    print_status "Starting local development server..."
    
    # Use Netlify Dev for local development with functions
    netlify dev --config netlify.dev.toml
}

# Main deployment logic
main() {
    case "$1" in
        "local")
            print_status "Starting local development mode..."
            check_dependencies
            validate_env
            run_local_dev
            ;;
        "preview")
            print_status "Starting preview deployment..."
            check_dependencies
            validate_env
            clean_build
            build_app
            deploy_to_netlify "preview"
            ;;
        "production")
            print_status "Starting production deployment..."
            check_dependencies
            validate_env
            clean_build
            
            # Use production build for production deployment
            flutter build web --release --web-renderer html
            deploy_to_netlify "production"
            ;;
        *)
            print_status "Starting draft deployment..."
            check_dependencies
            validate_env
            clean_build
            build_app
            deploy_to_netlify "draft"
            ;;
    esac
}

# Display usage information
usage() {
    echo "Usage: $0 [local|preview|production]"
    echo ""
    echo "Options:"
    echo "  local      Start local development server with Netlify Dev"
    echo "  preview    Deploy as preview (branch deployment)"
    echo "  production Deploy to production"
    echo "  (no args)  Deploy as draft"
    echo ""
    echo "Examples:"
    echo "  $0 local      # Start local dev server"
    echo "  $0 preview    # Deploy preview"
    echo "  $0 production # Deploy to production"
}

# Check command line arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
fi

# Run main function
main "$1"

print_success "🎉 Deployment script completed!"