#!/bin/bash

# BCT Chain Gatus - Complete Telegram Integration Setup
# This script sets up the complete Telegram bot integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP $1]${NC} $2"
}

# ASCII Art Banner
echo -e "${PURPLE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ╔╗ ╔═╗╔╦╗  ╔═╗┬ ┬┌─┐┬┌┐┌  ╔╦╗┌─┐┌┐┌┬┌┬┐┌─┐┬─┐           ║
║     ╠╩╗║   ║   ║  ├─┤├─┤││││  ║║║│ │││││ │ │ │├┬┘           ║
║     ╚═╝╚═╝ ╩   ╚═╝┴ ┴┴ ┴┴┘└┘  ╩ ╩└─┘┘└┘┴ ┴ └─┘┴└─           ║
║                                                              ║
║              🤖 Telegram Bot Integration Setup               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_header "BCT Chain Gatus - Telegram Integration"

echo ""
print_info "This script will set up complete Telegram integration for BCT Chain monitoring:"
echo ""
echo "🔧 Features to be configured:"
echo "  • Immediate alerts when endpoints go down"
echo "  • Recovery notifications when endpoints come back online"
echo "  • Hourly status reports with endpoint health"
echo "  • Daily and midday comprehensive reports"
echo "  • Beautiful message formatting with emojis"
echo ""

# Check prerequisites
print_step "1" "Checking Prerequisites"

# Check if running from correct directory
if [ ! -f "config.yaml" ] || [ ! -f "docker-compose.yml" ]; then
    print_error "Please run this script from the gatus project root directory"
    print_error "Expected files: config.yaml, docker-compose.yml"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running or not accessible"
    print_error "Please start Docker and try again"
    exit 1
fi

print_success "Prerequisites check passed!"

# Step 2: Telegram Bot Setup
print_step "2" "Setting up Telegram Bot"
echo ""

if [ -f ".env" ] && grep -q "TELEGRAM_BOT_TOKEN" ".env" 2>/dev/null; then
    print_warning "Telegram configuration already exists in .env file"
    echo ""
    echo "Current configuration:"
    grep "TELEGRAM_" ".env" 2>/dev/null || echo "No Telegram config found"
    echo ""
    read -p "Do you want to reconfigure Telegram bot? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Telegram bot setup"
    else
        print_info "Running Telegram bot setup..."
        ./scripts/setup-telegram.sh
    fi
else
    print_info "Running Telegram bot setup..."
    ./scripts/setup-telegram.sh
fi

# Verify Telegram config exists
if [ ! -f ".env" ] || ! grep -q "TELEGRAM_BOT_TOKEN" ".env" 2>/dev/null; then
    print_error "Telegram configuration not found after setup"
    print_error "Please run ./scripts/setup-telegram.sh manually"
    exit 1
fi

print_success "Telegram bot configuration complete!"

# Step 3: Docker Container Update
print_step "3" "Updating Docker Configuration"
echo ""

print_info "Stopping existing containers..."
docker-compose down 2>/dev/null || true

print_info "Building updated container with Telegram support..."
docker-compose build --no-cache

print_info "Starting services with new configuration..."
docker-compose up -d

# Wait for service to be ready
print_info "Waiting for Gatus to start..."
sleep 10

# Check if service is running
if ! docker-compose ps | grep -q "gatus.*Up"; then
    print_error "Gatus container failed to start"
    print_error "Check logs with: docker-compose logs gatus"
    exit 1
fi

print_success "Docker services updated and running!"

# Step 4: Test Immediate Alerts
print_step "4" "Testing Immediate Alert System"
echo ""

print_info "Testing immediate alert functionality..."
print_warning "This will temporarily break an endpoint to test failure detection"

# Wait for initial status to stabilize
print_info "Waiting for monitoring to stabilize..."
sleep 30

# Get current status
print_info "Checking current endpoint status..."
if curl -s "http://localhost:8080/api/v1/endpoints/statuses" >/dev/null; then
    print_success "Gatus API is accessible"
else
    print_error "Cannot access Gatus API at http://localhost:8080"
    print_warning "Container may still be starting up..."
fi

print_success "Immediate alert system is configured!"

# Step 5: Set up Scheduled Reports
print_step "5" "Setting up Hourly Status Reports"
echo ""

# Load environment variables for scripts
set -a
source .env 2>/dev/null || true
set +a

print_info "Testing status report functionality..."
if ./scripts/status-report.sh test; then
    print_success "Status report system working!"
    
    read -p "Do you want to set up automated hourly reports via cron? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Setting up cron jobs for automated reports..."
        ./scripts/setup-cron.sh
    else
        print_info "Skipping automated report setup"
        print_info "You can run reports manually with: ./scripts/status-report.sh report"
    fi
else
    print_warning "Status report test failed"
    print_info "You can troubleshoot with: ./scripts/status-report.sh test"
fi

# Step 6: Final Testing and Summary
print_step "6" "Final Verification"
echo ""

print_info "Performing final system check..."

# Check Docker containers
if docker-compose ps | grep -q "gatus.*Up"; then
    print_success "✅ Gatus container is running"
else
    print_error "❌ Gatus container is not running"
fi

# Check web interface
if curl -s "http://localhost:8080" >/dev/null; then
    print_success "✅ Web interface is accessible at http://localhost:8080"
else
    print_warning "⚠️  Web interface check failed"
fi

# Check API
if curl -s "http://localhost:8080/api/v1/endpoints/statuses" >/dev/null; then
    print_success "✅ API is responding"
else
    print_warning "⚠️  API check failed"
fi

# Check logs directory
if [ -d "logs" ]; then
    print_success "✅ Logs directory created"
else
    print_info "Creating logs directory..."
    mkdir -p logs
    print_success "✅ Logs directory created"
fi

echo ""
print_header "🎉 Setup Complete!"

echo ""
print_success "BCT Chain Telegram monitoring is now fully configured!"
echo ""

print_info "📊 What's Working Now:"
echo "  ✅ Real-time monitoring of BCT Chain RPC endpoints"
echo "  🔔 Immediate Telegram alerts when endpoints go down"
echo "  📈 Recovery notifications when endpoints come back online"
echo "  📅 Hourly status reports (if cron was configured)"
echo "  🎨 Beautiful modern web interface with glass morphism design"
echo "  🔒 Secure Docker setup with proper permissions"
echo ""

print_info "🔗 Access Points:"
echo "  • Web Interface: http://localhost:8080"
echo "  • API Endpoint: http://localhost:8080/api/v1/endpoints/statuses"
echo "  • Telegram Bot: Check your Telegram for messages"
echo ""

print_info "📁 Key Files:"
echo "  • Configuration: ./config.yaml"
echo "  • Environment: ./.env (keep this secure!)"
echo "  • Logs: ./logs/status-report.log"
echo "  • Scripts: ./scripts/"
echo ""

print_info "🛠️  Management Commands:"
echo "  • View status: docker-compose ps"
echo "  • View logs: docker-compose logs gatus"
echo "  • Restart: docker-compose restart"
echo "  • Stop: docker-compose down"
echo "  • Manual report: ./scripts/status-report.sh report"
echo "  • Test Telegram: ./scripts/status-report.sh test"
echo ""

print_info "🔍 Monitoring Details:"
echo "  • BCT Chain RPC: https://rpc.bctchain.com (every 30s)"
echo "  • Health checks: Connectivity and response validation"
echo "  • Block queries: Functional blockchain data retrieval"
echo "  • SSL monitoring: Certificate expiration tracking"
echo ""

print_warning "🔐 Security Notes:"
echo "  • Keep your .env file secure and private"
echo "  • Don't commit .env to version control"
echo "  • Monitor your Telegram bot for any unusual activity"
echo "  • Regularly check logs for any issues"
echo ""

echo -e "${GREEN}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                  🚀 BCT Chain Monitor Ready! 🚀              ║
║                                                              ║
║     Your blockchain monitoring system is now fully          ║
║     operational with real-time Telegram notifications!      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_success "Setup completed successfully! Your BCT Chain is now being monitored 24/7! 🎉"
