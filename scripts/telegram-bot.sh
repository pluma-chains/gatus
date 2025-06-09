#!/bin/bash

# BCT Chain Telegram Bot Management Script
# This script helps manage the interactive Telegram bot service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if bot token is configured
check_bot_config() {
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        error "Environment file (.env) not found!"
        echo "Please run setup-telegram.sh first to configure the bot."
        exit 1
    fi
    
    source "$PROJECT_DIR/.env"
    
    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        error "Telegram bot not configured!"
        echo "Please run setup-telegram.sh first to configure the bot."
        exit 1
    fi
}

# Function to start the bot service
start_bot() {
    log "Starting BCT Chain Telegram Bot..."
    
    cd "$PROJECT_DIR"
    
    # Build and start the telegram bot service
    docker-compose build telegram-bot
    docker-compose up -d telegram-bot
    
    success "Telegram bot service started!"
    log "Bot container: gatus-telegram-bot"
    log "Monitoring chat ID: $TELEGRAM_CHAT_ID"
    echo ""
    echo "Available commands in Telegram:"
    echo "  /greeting - Show all available commands"
    echo "  /check - Quick health check"
    echo "  /status - Detailed status report"
    echo "  /health - System health summary"
    echo "  /uptime - Uptime statistics"
    echo "  /endpoints - List monitored endpoints"
    echo "  /ping - Test bot connectivity"
}

# Function to stop the bot service
stop_bot() {
    log "Stopping BCT Chain Telegram Bot..."
    
    cd "$PROJECT_DIR"
    docker-compose stop telegram-bot
    
    success "Telegram bot service stopped!"
}

# Function to restart the bot service
restart_bot() {
    log "Restarting BCT Chain Telegram Bot..."
    
    cd "$PROJECT_DIR"
    docker-compose restart telegram-bot
    
    success "Telegram bot service restarted!"
}

# Function to show bot logs
show_logs() {
    log "Showing Telegram bot logs..."
    echo "Press Ctrl+C to exit log view"
    echo ""
    
    cd "$PROJECT_DIR"
    docker-compose logs -f telegram-bot
}

# Function to show bot status
show_status() {
    log "Checking Telegram bot status..."
    
    cd "$PROJECT_DIR"
    
    # Check if container is running
    if docker-compose ps telegram-bot | grep -q "Up"; then
        success "Telegram bot is running"
        
        # Show container info
        echo ""
        echo "Container Status:"
        docker-compose ps telegram-bot
        
        # Show recent logs
        echo ""
        echo "Recent Logs (last 10 lines):"
        docker-compose logs --tail=10 telegram-bot
        
    else
        warning "Telegram bot is not running"
        echo "Use '$0 start' to start the bot"
    fi
}

# Function to test bot connectivity
test_bot() {
    log "Testing Telegram bot connectivity..."
    
    check_bot_config
    source "$PROJECT_DIR/.env"
    
    # Test bot API
    response=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe")
    
    if echo "$response" | grep -q '"ok":true'; then
        success "Bot token is valid!"
        
        # Extract bot info
        bot_name=$(echo "$response" | grep -o '"first_name":"[^"]*"' | cut -d'"' -f4)
        bot_username=$(echo "$response" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        
        echo "Bot Name: $bot_name"
        echo "Bot Username: @$bot_username"
        
        # Test sending a message
        log "Sending test message..."
        
        test_message="🧪 Test message from BCT Chain Monitoring Bot\\n\\nBot is configured and working correctly!\\n\\nUse /greeting to see all available commands."
        
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -H "Content-Type: application/json" \
            -d "{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${test_message}\", \"parse_mode\": \"HTML\"}" > /dev/null
        
        success "Test message sent to chat ID: $TELEGRAM_CHAT_ID"
        
    else
        error "Bot token is invalid or API is unreachable!"
        echo "Please check your TELEGRAM_BOT_TOKEN in .env file"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "BCT Chain Telegram Bot Management"
    echo "=================================="
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  start     - Start the Telegram bot service"
    echo "  stop      - Stop the Telegram bot service"
    echo "  restart   - Restart the Telegram bot service"
    echo "  status    - Show bot status and recent logs"
    echo "  logs      - Show live bot logs"
    echo "  test      - Test bot connectivity and send test message"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start    # Start the bot"
    echo "  $0 test     # Test bot connectivity"
    echo "  $0 logs     # View live logs"
    echo ""
    echo "Features:"
    echo "  • Interactive Telegram commands (/greeting, /check, /status)"
    echo "  • Real-time monitoring data"
    echo "  • Automatic health checks"
    echo "  • Comprehensive status reports"
    echo ""
}

# Main script logic
case "${1:-help}" in
    start)
        check_bot_config
        start_bot
        ;;
    stop)
        stop_bot
        ;;
    restart)
        restart_bot
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    test)
        test_bot
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
