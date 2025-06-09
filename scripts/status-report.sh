#!/bin/bash

# BCT Chain Gatus - Hourly Status Report Script
# This script sends hourly status reports to Telegram

set -e

# Load environment variables
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
fi

# Configuration
GATUS_URL="http://localhost:8080"
BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
CHAT_ID="${TELEGRAM_CHAT_ID}"

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Check if required variables are set
if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
    log_error "Telegram bot token or chat ID not configured!"
    log_error "Please run: ./scripts/setup-telegram.sh"
    exit 1
fi

# Function to send Telegram message
send_telegram_message() {
    local message="$1"
    local parse_mode="${2:-Markdown}"
    
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{
            \"chat_id\": \"${CHAT_ID}\",
            \"text\": \"${message}\",
            \"parse_mode\": \"${parse_mode}\"
        }" > /dev/null
    
    return $?
}

# Function to get endpoint status
get_gatus_status() {
    local response
    local retries=3
    
    for ((i=1; i<=retries; i++)); do
        response=$(curl -s --connect-timeout 10 --max-time 30 "${GATUS_URL}/api/v1/endpoints/statuses" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$response" ]; then
            echo "$response"
            return 0
        fi
        log_warning "Attempt $i failed, retrying..."
        sleep 5
    done
    
    log_error "Failed to fetch status from Gatus after $retries attempts"
    return 1
}

# Function to check if endpoint is healthy
is_endpoint_healthy() {
    local endpoint_data="$1"
    # Extract the last result success status
    echo "$endpoint_data" | grep -o '"success":[^,]*' | tail -1 | grep -q "true"
}

# Function to get response time
get_response_time() {
    local endpoint_data="$1"
    echo "$endpoint_data" | grep -o '"response-time":[0-9]*' | head -1 | cut -d':' -f2
}

# Function to format uptime percentage
get_uptime_percentage() {
    local endpoint_data="$1"
    local uptime_7d=$(echo "$endpoint_data" | grep -o '"7d":[0-9.]*' | cut -d':' -f2)
    echo "${uptime_7d:-0}"
}

# Main function to generate and send status report
generate_status_report() {
    log_info "Generating BCT Chain status report..."
    
    # Get current timestamp
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S UTC')
    local hour=$(date '+%H')
    
    # Determine report type
    local report_type="📊 Hourly Status Report"
    if [ "$hour" == "00" ]; then
        report_type="🌅 Daily Status Report"
    elif [ "$hour" == "12" ]; then
        report_type="🌞 Midday Status Report"
    fi
    
    # Get status data
    local status_data
    status_data=$(get_gatus_status)
    if [ $? -ne 0 ]; then
        log_error "Failed to get status data"
        send_telegram_message "❌ *BCT Chain Status Report Error*

Could not retrieve monitoring data from Gatus.

Time: \`${timestamp}\`
Status: MONITORING SYSTEM DOWN

Please check the Gatus service status."
        return 1
    fi
    
    # Parse endpoint data
    local healthy_count=0
    local total_count=0
    local endpoint_details=""
    local critical_issues=""
    
    # Extract endpoint information
    while IFS= read -r line; do
        if echo "$line" | grep -q '"name"'; then
            local name=$(echo "$line" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
            local group=$(echo "$line" | grep -o '"group":"[^"]*"' | cut -d'"' -f4 || echo "default")
            
            # Get the full endpoint data for this endpoint
            local endpoint_block=$(echo "$status_data" | grep -A 20 "\"name\":\"$name\"")
            
            if is_endpoint_healthy "$endpoint_block"; then
                local status_icon="✅"
                healthy_count=$((healthy_count + 1))
            else
                local status_icon="❌"
                critical_issues="${critical_issues}• ${name} (${group})\n"
            fi
            
            local response_time=$(get_response_time "$endpoint_block")
            local uptime=$(get_uptime_percentage "$endpoint_block")
            
            # Format response time
            if [ -n "$response_time" ] && [ "$response_time" -gt 0 ]; then
                response_time="${response_time}ms"
            else
                response_time="N/A"
            fi
            
            # Format uptime
            if [ -n "$uptime" ] && [ "$uptime" != "0" ]; then
                uptime="${uptime}%"
            else
                uptime="N/A"
            fi
            
            endpoint_details="${endpoint_details}${status_icon} *${name}*\n"
            endpoint_details="${endpoint_details}   Group: \`${group}\`\n"
            endpoint_details="${endpoint_details}   Response: \`${response_time}\`\n"
            endpoint_details="${endpoint_details}   Uptime (7d): \`${uptime}\`\n\n"
            
            total_count=$((total_count + 1))
        fi
    done < <(echo "$status_data" | grep '"name":')
    
    # Calculate overall health percentage
    local health_percentage=0
    if [ "$total_count" -gt 0 ]; then
        health_percentage=$((healthy_count * 100 / total_count))
    fi
    
    # Determine overall status
    local overall_status="🔴 CRITICAL"
    local status_emoji="🔴"
    if [ "$health_percentage" -eq 100 ]; then
        overall_status="🟢 ALL SYSTEMS OPERATIONAL"
        status_emoji="🟢"
    elif [ "$health_percentage" -ge 75 ]; then
        overall_status="🟡 PARTIAL OUTAGE"
        status_emoji="🟡"
    fi
    
    # Build the report message
    local message="${report_type}

${status_emoji} *BCT Chain Network Status*

📈 *Overall Health: ${health_percentage}%*
⚡ *Active Endpoints: ${healthy_count}/${total_count}*
🕐 *Report Time: \`${timestamp}\`*

━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 *Endpoint Status Details:*

${endpoint_details}"

    # Add critical issues section if any
    if [ -n "$critical_issues" ]; then
        message="${message}🚨 *Critical Issues:*
${critical_issues}
━━━━━━━━━━━━━━━━━━━━━━━━━━

"
    fi
    
    # Add footer
    message="${message}🔗 *Dashboard:* [View Live Status](http://localhost:8080)
📱 *Bot:* BCT Chain Monitor
🤖 *Powered by:* Gatus Monitoring

_Next report in 1 hour_"
    
    # Send the message
    log_info "Sending status report to Telegram..."
    if send_telegram_message "$message"; then
        log_success "Status report sent successfully!"
        log_info "Report summary: $healthy_count/$total_count endpoints healthy ($health_percentage%)"
    else
        log_error "Failed to send status report to Telegram!"
        return 1
    fi
}

# Function to test Telegram connectivity
test_telegram() {
    log_info "Testing Telegram connectivity..."
    
    local test_message="🔧 *BCT Chain Monitor Test*

This is a test message to verify Telegram connectivity.

Time: \`$(date '+%Y-%m-%d %H:%M:%S UTC')\`
Status: ✅ Connection Successful"
    
    if send_telegram_message "$test_message"; then
        log_success "Telegram test message sent successfully!"
        return 0
    else
        log_error "Failed to send test message to Telegram!"
        return 1
    fi
}

# Main execution
main() {
    case "${1:-report}" in
        "test")
            test_telegram
            ;;
        "report")
            generate_status_report
            ;;
        "help"|"-h"|"--help")
            echo "BCT Chain Gatus - Hourly Status Report Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  report    Generate and send status report (default)"
            echo "  test      Send test message to verify Telegram setup"
            echo "  help      Show this help message"
            echo ""
            echo "Environment variables required:"
            echo "  TELEGRAM_BOT_TOKEN    - Your Telegram bot token"
            echo "  TELEGRAM_CHAT_ID      - Your Telegram chat ID"
            echo ""
            echo "Example crontab entry for hourly reports:"
            echo "0 * * * * cd /path/to/gatus && ./scripts/status-report.sh report >> logs/status-report.log 2>&1"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information."
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
