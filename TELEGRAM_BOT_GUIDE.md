# BCT Chain Telegram Bot - Complete Guide

## 🚀 Overview

The BCT Chain Telegram Bot is now fully integrated with your Docker Compose monitoring system. This interactive bot provides real-time monitoring capabilities through Telegram commands, making it easy to check your blockchain infrastructure status from anywhere.

## ✅ What's Completed

### 1. **Interactive Telegram Bot (`telegram-bot.py`)**

- **10 Interactive Commands** available for comprehensive monitoring
- **Real-time Integration** with Gatus API for live monitoring data
- **Security Features** - only responds to configured chat ID
- **Comprehensive Logging** for troubleshooting and monitoring
- **Auto-startup Notification** when bot comes online

### 2. **Containerized Deployment**

- **Custom Dockerfile** (`Dockerfile.telegram-bot`) with security best practices
- **Docker Compose Integration** with proper networking and dependencies
- **Health Checks** for bot connectivity monitoring
- **Non-root User** execution for enhanced security
- **Persistent Logging** with dedicated volume

### 3. **Bot Management Tools**

- **Management Script** (`scripts/telegram-bot.sh`) for easy bot control
- **Commands**: start, stop, restart, status, logs, test, help
- **Configuration Validation** and environment checking
- **Connectivity Testing** with comprehensive error handling

## 🤖 Available Bot Commands

### Status Commands

- `/greeting` - **Show all available commands and bot capabilities**
- `/check` - **Quick health check of all BCT Chain endpoints**
- `/status` - Detailed status report with response times
- `/health` - Overall system health summary with percentages
- `/uptime` - Uptime statistics for all monitored services
- `/endpoints` - List all monitored BCT Chain endpoints

### Alert Commands

- `/alerts` - Show recent alerts and incidents
- `/ping` - Test bot connectivity and response

### General Commands

- `/start` - Initialize bot and show greeting
- `/help` - Show help information

## 🔧 System Status

### Current Deployment Status: ✅ **RUNNING**

```bash
# Check system status
docker-compose ps
```

**Services Running:**

- ✅ **gatus-bct-monitor** - Main monitoring service (Port: 80)
- ✅ **gatus-telegram-bot** - Interactive Telegram bot
- 🌐 **Network**: `gatus-network` for inter-service communication
- 💾 **Volumes**: `telegram-logs` for bot logging

### Monitored Endpoints

Your bot monitors these BCT Chain endpoints:

- **🔗 BCT RPC Main** - Main RPC endpoint functionality
- **🏥 BCT RPC Health** - Health check endpoint status
- **🔍 BCT Block Query** - Blockchain data query service
- **🔒 BCT SSL Certificate** - SSL certificate validity

## 🎯 Quick Start Usage

### 1. **Basic Health Check**

Send `/check` to get instant status of all endpoints:

```
🔍 BCT Chain Quick Check

✅ Status: All Systems Operational
📊 Health: 4/4 endpoints healthy

🕐 Last Check: 2025-06-09 10:23:50 UTC
```

### 2. **Detailed Status Report**

Send `/status` for comprehensive information:

```
📊 BCT Chain Detailed Status Report

✅ bct-rpc-main (rpc-nodes)
   Response Time: 298ms
   Last Check: 2025-06-09T03:23:10

✅ bct-rpc-health (rpc-nodes)
   Response Time: 306ms
   Last Check: 2025-06-09T03:23:11
```

### 3. **Get All Commands**

Send `/greeting` to see all available commands and capabilities.

## 🛠️ Management Commands

### Using the Management Script

```bash
# Check bot status
./scripts/telegram-bot.sh status

# View recent logs
./scripts/telegram-bot.sh logs

# Test bot connectivity
./scripts/telegram-bot.sh test

# Restart bot service
./scripts/telegram-bot.sh restart

# Stop bot service
./scripts/telegram-bot.sh stop

# Start bot service
./scripts/telegram-bot.sh start
```

### Direct Docker Commands

```bash
# View all services
docker-compose ps

# Check bot logs
docker-compose logs telegram-bot

# Restart entire system
docker-compose restart

# Stop entire system
docker-compose down

# Start entire system
docker-compose up -d
```

## 🔧 Configuration Details

### Environment Variables

The bot uses these environment variables from your existing `.env` file:

- `TELEGRAM_BOT_TOKEN` - Your bot's API token
- `TELEGRAM_CHAT_ID` - Authorized chat ID for security
- `GATUS_API_URL` - Internal Gatus API endpoint (http://gatus:8080)

### Network Configuration

- **Network Name**: `gatus-network`
- **Communication**: Bot connects to Gatus internally via Docker network
- **External Access**: Gatus web interface available on port 80

### Logging

- **Bot Logs**: Stored in `/logs/telegram-bot.log` within container
- **Docker Logs**: Available via `docker-compose logs telegram-bot`
- **Log Rotation**: Automatic log management

## 🔐 Security Features

### Bot Security

- **Chat ID Restriction** - Only responds to configured chat
- **Input Validation** - All commands are validated
- **Error Handling** - Secure error responses
- **Rate Limiting** - Built-in Telegram API rate limiting

### Container Security

- **Non-root User** - Bot runs as user `botuser` (UID 1000)
- **Read-only Filesystem** - Container filesystem is read-only where possible
- **Health Checks** - Continuous monitoring of bot health
- **Network Isolation** - Private Docker network communication

## 🚨 Troubleshooting

### Bot Not Responding

1. Check bot status: `./scripts/telegram-bot.sh status`
2. View logs: `docker-compose logs telegram-bot`
3. Test connectivity: `./scripts/telegram-bot.sh test`
4. Restart if needed: `docker-compose restart telegram-bot`

### API Connection Issues

1. Verify Gatus is running: `curl http://localhost/health`
2. Check network connectivity: `docker network ls`
3. Review Gatus logs: `docker-compose logs gatus`

### Configuration Issues

1. Verify environment file: `cat .env`
2. Check Docker Compose: `docker-compose config`
3. Validate bot token: `./scripts/telegram-bot.sh test`

## 📊 Monitoring Integration

### Web Interface

- **URL**: http://localhost
- **Status Page**: Real-time dashboard of all endpoints
- **API Access**: http://localhost/api/v1/endpoints/statuses

### Telegram Integration

- **Interactive Commands** - Query status anytime via Telegram
- **Real-time Data** - Always current information from Gatus
- **Mobile Access** - Monitor from anywhere via Telegram app

## 🔄 Next Steps

Your BCT Chain monitoring system with Telegram bot is now fully operational! You can:

1. **Start Using Commands** - Send `/greeting` to your bot to begin
2. **Monitor Regularly** - Use `/check` for quick status updates
3. **Set Up Notifications** - Bot will alert on system issues
4. **Customize Alerts** - Modify `config.yaml` for specific alert conditions
5. **Scale Monitoring** - Add more endpoints to monitor additional services

## 📝 Files Modified/Created

### New Files

- `telegram-bot.py` - Main bot application
- `Dockerfile.telegram-bot` - Bot container configuration
- `scripts/telegram-bot.sh` - Bot management script
- `TELEGRAM_BOT_GUIDE.md` - This documentation

### Modified Files

- `docker-compose.yml` - Added telegram-bot service and network configuration

### Configuration Files

- `.env` - Contains bot credentials (already existed)
- `config.yaml` - Gatus monitoring configuration (already existed)

---

## 🎉 Success!

Your BCT Chain Telegram monitoring bot is now fully operational and ready to provide real-time blockchain infrastructure monitoring through interactive Telegram commands!

**Bot Status**: ✅ **ACTIVE AND MONITORING**
**System Health**: ✅ **ALL SYSTEMS OPERATIONAL**
**Ready for Commands**: ✅ **SEND /greeting TO START**
