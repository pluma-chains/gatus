# 🤖 Telegram Bot Integration for BCT Chain Monitoring

This document explains how to set up and use the Telegram bot integration for BCT Chain monitoring with Gatus.

## 📋 Overview

The Telegram integration provides:
- **🚨 Immediate Alerts**: Instant notifications when endpoints go down
- **✅ Recovery Notifications**: Alerts when endpoints come back online  
- **📊 Hourly Status Reports**: Comprehensive endpoint health summaries
- **📈 Daily/Midday Reports**: Special detailed reports twice per day
- **🎨 Rich Formatting**: Beautiful messages with emojis and markdown

## 🚀 Quick Setup

### Option 1: Automated Setup (Recommended)

Run the complete setup script:

```bash
./setup-telegram-integration.sh
```

This script will:
1. Guide you through creating a Telegram bot
2. Configure authentication tokens
3. Update Docker containers
4. Test the integration
5. Set up automated hourly reports

### Option 2: Manual Setup

If you prefer to set up manually:

```bash
# 1. Set up Telegram bot
./scripts/setup-telegram.sh

# 2. Set up automated reports (optional)
./scripts/setup-cron.sh

# 3. Restart containers
docker-compose down && docker-compose up -d
```

## 🔧 Prerequisites

- Docker and Docker Compose installed
- Telegram account
- BCT Chain Gatus monitoring system

## 📱 Creating a Telegram Bot

### Step 1: Create Bot with BotFather

1. Open Telegram and search for `@BotFather`
2. Send `/newbot` command
3. Choose a name: `BCT Chain Monitor`
4. Choose username: `bct_chain_monitor_bot` (must be unique)
5. Save the bot token (format: `123456789:ABCdef...`)

### Step 2: Get Your Chat ID

1. Start a conversation with your new bot
2. Send any message (e.g., "Hello")
3. Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
4. Find your chat ID in the JSON response: `"chat":{"id":YOUR_CHAT_ID}`

## ⚙️ Configuration

### Environment Variables

The integration uses these environment variables (stored in `.env`):

```bash
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=123456789:ABCdef1234ghIkl-zyx57W2v1u123ew11
TELEGRAM_CHAT_ID=123456789
```

### Gatus Configuration

The system automatically configures alerting in `config.yaml`:

```yaml
alerting:
  telegram:
    token: "${TELEGRAM_BOT_TOKEN}"
    id: "${TELEGRAM_CHAT_ID}"
    default-alert:
      description: "BCT Chain endpoint status change"
      send-on-resolved: true
      failure-threshold: 2
      success-threshold: 2

endpoints:
  - name: bct-rpc-main
    # ...existing config...
    alerts:
      - type: telegram
        description: "🔴 BCT Chain Main RPC is DOWN"
        send-on-resolved: true
        failure-threshold: 2
        success-threshold: 2
```

## 📨 Message Types

### 🚨 Immediate Alerts

Triggered when endpoints fail:

```
🔴 BCT Chain Main RPC is DOWN

⛑ Gatus
An alert for bct-rpc-main has been triggered:
—
    healthcheck failed 2 time(s) in a row
—

Description
🔴 BCT Chain Main RPC is DOWN

Condition results
❌ - [STATUS] == 200
❌ - [BODY].result != null
✅ - [RESPONSE_TIME] < 2000
```

### ✅ Recovery Notifications

Sent when endpoints recover:

```
✅ BCT Chain Main RPC RECOVERED

⛑ Gatus
An alert for bct-rpc-main has been resolved:
—
    healthcheck passing successfully 2 time(s) in a row
—

Description
🔴 BCT Chain Main RPC is DOWN

Condition results
✅ - [STATUS] == 200
✅ - [BODY].result != null
✅ - [RESPONSE_TIME] < 2000
```

### 📊 Hourly Status Reports

Comprehensive reports sent every hour:

```
📊 Hourly Status Report

🟢 BCT Chain Network Status

📈 Overall Health: 100%
⚡ Active Endpoints: 4/4
🕐 Report Time: 2025-06-09 15:00:00 UTC

━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Endpoint Status Details:

✅ bct-rpc-main
   Group: rpc-nodes
   Response: 245ms
   Uptime (7d): 99.8%

✅ bct-rpc-health
   Group: rpc-nodes
   Response: 189ms
   Uptime (7d): 99.9%

✅ bct-block-query
   Group: blockchain-data
   Response: 312ms
   Uptime (7d): 100%

✅ bct-ssl-certificate
   Group: security
   Response: 156ms
   Uptime (7d): 100%

🔗 Dashboard: View Live Status
📱 Bot: BCT Chain Monitor
🤖 Powered by: Gatus Monitoring

Next report in 1 hour
```

### 🌅 Special Reports

- **Daily Reports** (00:00): Comprehensive daily summary
- **Midday Reports** (12:00): Mid-day status check

## 🛠️ Management Commands

### Testing and Debugging

```bash
# Test Telegram connectivity
./scripts/status-report.sh test

# Send manual status report
./scripts/status-report.sh report

# Check Docker logs
docker-compose logs gatus

# View status report logs
tail -f logs/status-report.log
```

### Cron Management

```bash
# View current cron jobs
crontab -l

# Edit cron jobs manually
crontab -e

# Remove all Gatus cron jobs
crontab -l | grep -v status-report.sh | crontab -
```

### Container Management

```bash
# Restart with new config
docker-compose restart

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# View container status
docker-compose ps
```

## 📁 File Structure

```
gatus/
├── .env                          # Environment variables (keep secure!)
├── config.yaml                   # Main Gatus configuration
├── docker-compose.yml            # Docker setup with Telegram env vars
├── setup-telegram-integration.sh # Complete setup script
├── logs/
│   └── status-report.log         # Status report logs
└── scripts/
    ├── setup-telegram.sh         # Bot configuration script
    ├── setup-cron.sh             # Cron automation script
    └── status-report.sh          # Status report generator
```

## 🔧 Troubleshooting

### Common Issues

#### 1. "Bot token not set" Error
```bash
# Check environment file
cat .env | grep TELEGRAM

# Reconfigure if needed
./scripts/setup-telegram.sh
```

#### 2. Messages Not Sending
```bash
# Test connectivity
./scripts/status-report.sh test

# Check bot token and chat ID
curl -s "https://api.telegram.org/bot<TOKEN>/getMe"
```

#### 3. Container Won't Start
```bash
# Check logs
docker-compose logs gatus

# Verify environment variables
docker-compose exec gatus env | grep TELEGRAM
```

#### 4. Cron Jobs Not Working
```bash
# Check cron status
systemctl status cron  # Linux
sudo launchctl list | grep cron  # macOS

# Check cron logs
tail -f /var/log/cron.log  # Linux
tail -f /var/log/system.log | grep cron  # macOS

# Test script manually
cd /path/to/gatus && ./scripts/status-report.sh report
```

### Debug Mode

Enable verbose logging:

```bash
# Set debug mode in environment
echo "GATUS_LOG_LEVEL=DEBUG" >> .env
docker-compose restart
```

### Logs

Check various log files:

```bash
# Gatus application logs
docker-compose logs -f gatus

# Status report logs
tail -f logs/status-report.log

# System cron logs (Linux)
tail -f /var/log/cron.log

# System cron logs (macOS)
tail -f /var/log/system.log | grep cron
```

## 🔐 Security Considerations

### Environment Variables
- Never commit `.env` file to version control
- Use strong, unique bot tokens
- Restrict bot permissions in Telegram
- Regularly rotate tokens if compromised

### Network Security
- Run containers with minimal privileges
- Use read-only filesystems where possible
- Monitor for unusual API activity
- Keep Docker images updated

### Access Control
- Limit who has access to bot commands
- Monitor chat logs for unauthorized access
- Use group chats with proper admin controls
- Consider webhook alternatives for high-security environments

## 📈 Customization

### Custom Alert Messages

Edit `config.yaml` to customize alert descriptions:

```yaml
endpoints:
  - name: custom-endpoint
    alerts:
      - type: telegram
        description: "🔥 Custom Alert Message Here"
        failure-threshold: 1
```

### Report Frequency

Modify cron schedule in `scripts/setup-cron.sh`:

```bash
# Every 30 minutes instead of hourly
CRON_ENTRY="*/30 * * * * cd $PROJECT_DIR && ./scripts/status-report.sh report"
```

### Message Formatting

Customize message templates in `scripts/status-report.sh`:

```bash
# Search for message variable assignments
message="${report_type}

${status_emoji} *Your Custom Header*
..."
```

## 🔄 Updates

### Updating the Integration

```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Test after update
./scripts/status-report.sh test
```

### Backup Configuration

```bash
# Backup environment file
cp .env .env.backup

# Backup configuration
cp config.yaml config.yaml.backup

# Backup cron jobs
crontab -l > crontab.backup
```

## 🆘 Support

### Getting Help

1. **Check logs first**: `tail -f logs/status-report.log`
2. **Test connectivity**: `./scripts/status-report.sh test`
3. **Verify configuration**: Check `.env` and `config.yaml`
4. **Review Docker logs**: `docker-compose logs gatus`

### Reporting Issues

When reporting issues, include:
- Error messages from logs
- Output of `docker-compose ps`
- Contents of `.env` (without tokens)
- Telegram bot configuration status

## 📚 Additional Resources

- [Gatus Documentation](https://gatus.io/)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Cron Expression Guide](https://crontab.guru/)

---

**🎉 Your BCT Chain monitoring system is now enhanced with comprehensive Telegram notifications!**
