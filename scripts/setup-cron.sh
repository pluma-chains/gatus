#!/bin/bash

# BCT Chain Gatus - Cron Setup Script
# This script sets up automated hourly status reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

echo "=========================================="
echo "BCT Chain Gatus - Cron Setup"
echo "=========================================="

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"

print_info "Setting up automated status reports for BCT Chain monitoring..."
print_info "Project directory: $PROJECT_DIR"

# Create logs directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
    print_info "Creating logs directory..."
    mkdir -p "$LOG_DIR"
    chmod 755 "$LOG_DIR"
fi

# Check if .env file exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    print_error "Environment file not found at $PROJECT_DIR/.env"
    print_error "Please run ./scripts/setup-telegram.sh first to configure Telegram bot"
    exit 1
fi

# Check if status report script exists
STATUS_SCRIPT="$PROJECT_DIR/scripts/status-report.sh"
if [ ! -f "$STATUS_SCRIPT" ]; then
    print_error "Status report script not found at $STATUS_SCRIPT"
    exit 1
fi

# Make sure the script is executable
chmod +x "$STATUS_SCRIPT"

# Test Telegram connectivity
print_info "Testing Telegram connectivity..."
cd "$PROJECT_DIR"
if ./scripts/status-report.sh test; then
    print_success "Telegram connectivity verified!"
else
    print_error "Telegram connectivity test failed!"
    print_error "Please check your bot configuration and try again."
    exit 1
fi

# Create cron job entry
CRON_ENTRY="0 * * * * cd $PROJECT_DIR && ./scripts/status-report.sh report >> $LOG_DIR/status-report.log 2>&1"

print_info "Setting up cron job for hourly status reports..."

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "status-report.sh"; then
    print_warning "Cron job for status reports already exists!"
    print_info "Current cron job:"
    crontab -l 2>/dev/null | grep "status-report.sh"
    echo ""
    read -p "Do you want to replace the existing cron job? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing cron job. Setup cancelled."
        exit 0
    fi
    
    # Remove existing status-report cron jobs
    print_info "Removing existing status report cron jobs..."
    (crontab -l 2>/dev/null | grep -v "status-report.sh") | crontab -
fi

# Add new cron job
print_info "Adding new cron job..."
(crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -

# Verify cron job was added
if crontab -l 2>/dev/null | grep -q "status-report.sh"; then
    print_success "Cron job added successfully!"
    echo ""
    print_info "Cron job details:"
    echo "Schedule: Every hour (0 * * * *)"
    echo "Script: $STATUS_SCRIPT"
    echo "Log file: $LOG_DIR/status-report.log"
    echo "Command: $CRON_ENTRY"
else
    print_error "Failed to add cron job!"
    exit 1
fi

# Create log rotation configuration
print_info "Setting up log rotation..."

# Create logrotate configuration file
LOGROTATE_CONF="/tmp/gatus-status-report"
cat > "$LOGROTATE_CONF" << EOF
$LOG_DIR/status-report.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 $(whoami) $(whoami)
}
EOF

# Add logrotate configuration to system (requires sudo)
if command -v logrotate >/dev/null 2>&1; then
    if [ -w "/etc/logrotate.d" ] || sudo -n true 2>/dev/null; then
        print_info "Installing logrotate configuration..."
        if sudo cp "$LOGROTATE_CONF" "/etc/logrotate.d/gatus-status-report" 2>/dev/null; then
            print_success "Log rotation configured (requires sudo)"
        else
            print_warning "Could not install logrotate config (no sudo access)"
            print_info "Manual logrotate config created at: $LOGROTATE_CONF"
            print_info "You can manually install it with: sudo cp $LOGROTATE_CONF /etc/logrotate.d/"
        fi
    else
        print_warning "No sudo access for logrotate setup"
        print_info "Manual logrotate config created at: $LOGROTATE_CONF"
    fi
else
    print_warning "logrotate not found on system"
fi

rm -f "$LOGROTATE_CONF"

# Test the status report immediately
print_info "Testing status report generation..."
echo ""
cd "$PROJECT_DIR"
if ./scripts/status-report.sh report; then
    print_success "Test status report sent successfully!"
else
    print_warning "Test status report failed, but cron job is still set up"
    print_info "Check logs at: $LOG_DIR/status-report.log"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_success "Hourly status reports are now configured!"
echo ""
print_info "Configuration Summary:"
echo "• Status reports will be sent every hour"
echo "• Reports include endpoint health, response times, and uptime"
echo "• Logs are saved to: $LOG_DIR/status-report.log"
echo "• Special reports at midnight (daily) and noon (midday)"
echo ""
print_info "Management Commands:"
echo "• View cron jobs: crontab -l"
echo "• Remove cron job: crontab -e (then delete the line)"
echo "• View logs: tail -f $LOG_DIR/status-report.log"
echo "• Test report: cd $PROJECT_DIR && ./scripts/status-report.sh test"
echo "• Manual report: cd $PROJECT_DIR && ./scripts/status-report.sh report"
echo ""
print_info "Your Telegram bot will now send:"
echo "✅ Hourly status reports with all endpoint health"
echo "🚨 Immediate alerts when endpoints go down"
echo "✅ Recovery notifications when endpoints come back online"
echo ""
print_success "BCT Chain monitoring automation is ready! 🎉"
