#!/bin/bash

# BCT Chain Gatus - Telegram Bot Setup Script
# This script helps configure Telegram notifications for Gatus monitoring

set -e

echo "=========================================="
echo "BCT Chain Gatus - Telegram Bot Setup"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f "$ENV_FILE" ]; then
    print_info "Creating .env file for Telegram credentials..."
    touch "$ENV_FILE"
fi

echo ""
print_info "This script will help you set up Telegram notifications for BCT Chain monitoring."
echo ""

# Step 1: Create Telegram Bot
echo "=========================================="
echo "Step 1: Create a Telegram Bot"
echo "=========================================="
echo ""
print_info "To get started, you need to create a Telegram bot:"
echo "1. Open Telegram and search for @BotFather"
echo "2. Send /newbot command"
echo "3. Choose a name for your bot (e.g., 'BCT Chain Monitor')"
echo "4. Choose a username for your bot (e.g., 'bct_chain_monitor_bot')"
echo "5. BotFather will give you a bot token"
echo ""
echo -n "Enter your Telegram Bot Token: "
read -r BOT_TOKEN

if [ -z "$BOT_TOKEN" ]; then
    print_error "Bot token cannot be empty!"
    exit 1
fi

# Validate token format (basic check)
if [[ ! $BOT_TOKEN =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
    print_error "Invalid bot token format! Should be like: 123456789:ABCdefGHI..."
    exit 1
fi

print_success "Bot token received and validated!"

# Step 2: Get Chat ID
echo ""
echo "=========================================="
echo "Step 2: Get Your Chat ID"
echo "=========================================="
echo ""
print_info "Now we need to get your Chat ID:"
echo "1. Start a conversation with your bot"
echo "2. Send any message to your bot (e.g., 'Hello')"
echo "3. We'll fetch your Chat ID automatically..."
echo ""

print_info "Fetching Chat ID..."

# Get updates from Telegram API
TELEGRAM_API="https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"
RESPONSE=$(curl -s "$TELEGRAM_API")

# Extract Chat ID from response
CHAT_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$CHAT_ID" ]; then
    print_warning "Could not automatically detect Chat ID."
    echo ""
    print_info "Please manually get your Chat ID:"
    echo "1. Send a message to your bot first"
    echo "2. Visit: https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"
    echo "3. Look for 'chat':{'id':YOUR_CHAT_ID}"
    echo ""
    echo -n "Enter your Chat ID: "
    read -r CHAT_ID
fi

if [ -z "$CHAT_ID" ]; then
    print_error "Chat ID cannot be empty!"
    exit 1
fi

print_success "Chat ID obtained: $CHAT_ID"

# Step 3: Test the bot
echo ""
echo "=========================================="
echo "Step 3: Testing Bot Connection"
echo "=========================================="
echo ""

print_info "Sending test message..."

TEST_MESSAGE="🔧 BCT Chain Monitor Setup Complete!

✅ Bot connected successfully
📡 Monitoring BCT Chain RPC endpoints
🔔 Alerts are now active

This bot will notify you about:
• Endpoint failures and recoveries
• Hourly status reports
• SSL certificate expirations

BCT Chain Network Status: ONLINE"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "{
        \"chat_id\": \"${CHAT_ID}\",
        \"text\": \"${TEST_MESSAGE}\",
        \"parse_mode\": \"Markdown\"
    }" > /dev/null

if [ $? -eq 0 ]; then
    print_success "Test message sent successfully!"
else
    print_error "Failed to send test message. Please check your bot token and chat ID."
    exit 1
fi

# Step 4: Save credentials
echo ""
echo "=========================================="
echo "Step 4: Saving Configuration"
echo "=========================================="
echo ""

print_info "Saving Telegram credentials to .env file..."

# Remove existing Telegram config if present
grep -v "^TELEGRAM_" "$ENV_FILE" > "${ENV_FILE}.tmp" 2>/dev/null || touch "${ENV_FILE}.tmp"
mv "${ENV_FILE}.tmp" "$ENV_FILE"

# Add new Telegram config
cat >> "$ENV_FILE" << EOF

# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
TELEGRAM_CHAT_ID=${CHAT_ID}
EOF

print_success "Configuration saved to .env file!"

# Step 5: Display next steps
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_success "Telegram bot setup is complete!"
echo ""
print_info "Next steps:"
echo "1. Restart your Gatus container to load the new configuration"
echo "2. Check that alerts are working properly"
echo "3. Monitor your Telegram for status updates"
echo ""
print_info "Your bot will send:"
echo "• Immediate alerts when endpoints go down"
echo "• Recovery notifications when endpoints come back online"
echo "• Hourly status reports with all endpoint health"
echo ""
print_warning "Keep your .env file secure and don't commit it to version control!"
echo ""

# Optional: Show configuration summary
echo "Configuration Summary:"
echo "---------------------"
echo "Bot Token: ${BOT_TOKEN:0:10}..."
echo "Chat ID: $CHAT_ID"
echo "Environment file: $ENV_FILE"
echo ""
print_success "BCT Chain Telegram monitoring is ready! 🚀"
