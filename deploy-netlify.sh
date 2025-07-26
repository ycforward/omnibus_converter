#!/bin/bash

# Automated Netlify Deployment Script for OmnibusConverter Support Website

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Netlify CLI is installed
check_netlify_cli() {
    if ! command -v netlify &> /dev/null; then
        log_error "Netlify CLI is not installed. Installing now..."
        npm install -g netlify-cli
    fi
}

# Check if user is logged in to Netlify
check_netlify_auth() {
    if ! netlify status &> /dev/null; then
        log_warning "You are not logged in to Netlify. Please log in:"
        netlify login
    fi
}

# Deploy to Netlify
deploy_to_netlify() {
    log_info "Deploying to Netlify..."
    
    # Deploy directly using site ID from support_website directory
    log_info "Deploying files to existing site..."
    netlify deploy --prod --dir=support_website --site=41b3ff6d-e950-4453-87fe-eba0424eb2d4
}

# Show deployment info
show_deployment_info() {
    log_success "Deployment completed!"
    echo ""
    echo "🌐 Your support website is now live at:"
    echo "   https://omnibus-converter.netlify.app"
    echo ""
    echo "📧 Privacy Policy:"
    echo "   https://omnibus-converter.netlify.app/privacy.html"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Test the website by visiting the URL above"
    echo "   2. Set up email notifications in Netlify dashboard"
    echo "   3. Update your App Store Connect support URL"
    echo ""
    echo "🔧 To update the website in the future, just run this script again"
}

# Main deployment function
main() {
    log_info "Starting OmnibusConverter Support Website deployment to Netlify..."
    
    check_netlify_cli
    check_netlify_auth
    deploy_to_netlify
    show_deployment_info
}

# Run main function
main "$@" 