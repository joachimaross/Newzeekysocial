#!/bin/bash

# Configuration Validation Script for Netlify Development Setup
# This script validates that all development configuration files are properly set up

echo "🔍 Validating Netlify Development Configuration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Track validation status
errors=0
warnings=0

echo -e "\n📁 Checking configuration files..."

# Check netlify.dev.toml exists and has correct structure
if [ -f "netlify.dev.toml" ]; then
    print_success "netlify.dev.toml exists"
    
    # Check key sections
    if grep -q "\[build\]" netlify.dev.toml; then
        print_success "Build configuration found"
    else
        print_error "Build configuration missing in netlify.dev.toml"
        ((errors++))
    fi
    
    if grep -q "FLUTTER_BUILD_MODE.*debug" netlify.dev.toml; then
        print_success "Debug build mode configured"
    else
        print_error "Debug build mode not configured"
        ((errors++))
    fi
    
    if grep -q "source-maps" netlify.dev.toml; then
        print_success "Source maps enabled for debugging"
    else
        print_warning "Source maps not explicitly enabled"
        ((warnings++))
    fi
else
    print_error "netlify.dev.toml missing"
    ((errors++))
fi

# Check production netlify.toml has been updated
if [ -f "netlify.toml" ]; then
    print_success "netlify.toml exists"
    
    if grep -q "Production Netlify configuration" netlify.toml; then
        print_success "Production configuration properly labeled"
    else
        print_warning "Production configuration should be labeled"
        ((warnings++))
    fi
    
    if grep -q "FIREBASE_API_KEY.*\${FIREBASE_API_KEY}" netlify.toml; then
        print_success "Environment variable references configured"
    else
        print_warning "Environment variables may not be properly referenced"
        ((warnings++))
    fi
else
    print_error "netlify.toml missing"
    ((errors++))
fi

# Check environment template
if [ -f ".env.development" ]; then
    print_success ".env.development template exists"
    
    if grep -q "FIREBASE_API_KEY" .env.development; then
        print_success "Firebase configuration template present"
    else
        print_error "Firebase configuration missing from template"
        ((errors++))
    fi
    
    if grep -q "development" .env.development; then
        print_success "Development environment properly indicated"
    else
        print_warning "Development environment not clearly indicated"
        ((warnings++))
    fi
else
    print_error ".env.development template missing"
    ((errors++))
fi

echo -e "\n🛠️ Checking deployment scripts..."

# Check deployment script
if [ -f "scripts/deploy-dev.sh" ]; then
    print_success "Deployment script exists"
    
    if [ -x "scripts/deploy-dev.sh" ]; then
        print_success "Deployment script is executable"
    else
        print_error "Deployment script is not executable"
        print_info "Run: chmod +x scripts/deploy-dev.sh"
        ((errors++))
    fi
else
    print_error "Deployment script missing"
    ((errors++))
fi

# Check package.json scripts
if [ -f "package.json" ]; then
    print_success "package.json exists"
    
    if grep -q "dev:netlify" package.json; then
        print_success "Development scripts configured"
    else
        print_error "Development scripts missing from package.json"
        ((errors++))
    fi
    
    if grep -q "build:dev" package.json; then
        print_success "Development build script configured"
    else
        print_warning "Development build script missing"
        ((warnings++))
    fi
else
    print_error "package.json missing"
    ((errors++))
fi

echo -e "\n⚙️ Checking Netlify functions..."

# Check functions directory
if [ -d "netlify/functions" ]; then
    print_success "Netlify functions directory exists"
    
    if [ -f "netlify/functions/dev-health.js" ]; then
        print_success "Health check function exists"
    else
        print_warning "Health check function missing"
        ((warnings++))
    fi
    
    if [ -f "netlify/functions/dev-config.js" ]; then
        print_success "Configuration validation function exists"
    else
        print_warning "Configuration validation function missing"
        ((warnings++))
    fi
else
    print_error "Netlify functions directory missing"
    ((errors++))
fi

echo -e "\n📖 Checking documentation..."

# Check documentation
if [ -f "DEVELOPMENT_DEPLOYMENT.md" ]; then
    print_success "Development deployment documentation exists"
else
    print_warning "Development deployment documentation missing"
    ((warnings++))
fi

# Check gitignore updates
if grep -q ".env.development" .gitignore; then
    print_success ".gitignore updated for development files"
else
    print_warning ".gitignore may need updates for development files"
    ((warnings++))
fi

echo -e "\n📊 Validation Summary"
echo "==================="

if [ $errors -eq 0 ]; then
    print_success "Configuration validation passed!"
    if [ $warnings -gt 0 ]; then
        print_warning "$warnings warnings found (non-critical)"
    fi
    echo -e "\n🚀 Ready to deploy to development environment!"
    echo -e "\nNext steps:"
    echo "1. Configure environment variables in Netlify site settings"
    echo "2. Run 'npm run dev:netlify' for local development"
    echo "3. Run './scripts/deploy-dev.sh' for deployment"
else
    print_error "$errors critical errors found"
    if [ $warnings -gt 0 ]; then
        print_warning "$warnings warnings found"
    fi
    echo -e "\n❌ Please fix the errors above before deploying"
    exit 1
fi