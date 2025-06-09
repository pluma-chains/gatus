#!/usr/bin/env python3
"""
BCT Chain Monitoring Telegram Bot
Interactive bot for monitoring BCT Chain status with commands
"""

import os
import sys
import json
import time
import requests
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/logs/telegram-bot.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class BCTChainTelegramBot:
    def __init__(self):
        self.bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
        self.chat_id = os.getenv('TELEGRAM_CHAT_ID')
        self.gatus_api_url = os.getenv('GATUS_API_URL', 'http://gatus:8080')
        
        if not self.bot_token or not self.chat_id:
            logger.error("Missing required environment variables: TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID")
            sys.exit(1)
            
        self.api_url = f"https://api.telegram.org/bot{self.bot_token}"
        self.last_update_id = 0
        
        # Command handlers
        self.commands = {
            '/start': self.cmd_start,
            '/greeting': self.cmd_greeting,
            '/help': self.cmd_help,
            '/check': self.cmd_check,
            '/status': self.cmd_status,
            '/health': self.cmd_health,
            '/uptime': self.cmd_uptime,
            '/endpoints': self.cmd_endpoints,
            '/alerts': self.cmd_alerts,
            '/ping': self.cmd_ping
        }
        
        logger.info("BCT Chain Telegram Bot initialized")

    def send_message(self, text: str, parse_mode: str = 'HTML') -> bool:
        """Send a message to the configured chat"""
        try:
            data = {
                'chat_id': self.chat_id,
                'text': text,
                'parse_mode': parse_mode
            }
            response = requests.post(f"{self.api_url}/sendMessage", json=data, timeout=10)
            response.raise_for_status()
            return True
        except Exception as e:
            logger.error(f"Failed to send message: {e}")
            return False

    def get_updates(self) -> List[Dict]:
        """Get updates from Telegram"""
        try:
            params = {
                'offset': self.last_update_id + 1,
                'timeout': 30,
                'limit': 100
            }
            response = requests.get(f"{self.api_url}/getUpdates", params=params, timeout=35)
            response.raise_for_status()
            
            data = response.json()
            if data['ok']:
                return data['result']
            return []
        except Exception as e:
            logger.error(f"Failed to get updates: {e}")
            return []

    def get_gatus_data(self) -> Optional[Dict]:
        """Fetch data from Gatus API"""
        try:
            response = requests.get(f"{self.gatus_api_url}/api/v1/endpoints/statuses", timeout=10)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Failed to fetch Gatus data: {e}")
            return None

    def cmd_start(self, message: Dict) -> str:
        """Handle /start command"""
        return self.cmd_greeting(message)

    def cmd_greeting(self, message: Dict) -> str:
        """Handle /greeting command - show all available commands"""
        return """🤖 <b>BCT Chain Monitoring Bot</b>

Welcome! I'm your BCT Chain monitoring assistant. Here are all available commands:

<b>📊 Status Commands:</b>
/check - Quick health check of all endpoints
/status - Detailed status report with response times
/health - Overall system health summary
/uptime - Uptime statistics for all services
/endpoints - List all monitored endpoints

<b>🔔 Alert Commands:</b>
/alerts - Show recent alerts and incidents

<b>ℹ️ General Commands:</b>
/greeting - Show this help message
/help - Show this help message
/ping - Test bot connectivity

<b>🔍 How to use:</b>
• Use /check for quick status overview
• Use /status for detailed monitoring data
• Bot automatically sends alerts when issues occur
• Reports are sent hourly with system health

<b>🌐 BCT Chain Endpoints Monitored:</b>
• Main RPC (https://rpc.bctchain.com)
• Health Check Endpoint
• Block Query Service
• SSL Certificate Status

Type any command to get started! 🚀"""

    def cmd_help(self, message: Dict) -> str:
        """Handle /help command"""
        return self.cmd_greeting(message)

    def cmd_check(self, message: Dict) -> str:
        """Handle /check command - quick status check"""
        data = self.get_gatus_data()
        if not data:
            return "❌ Unable to fetch monitoring data. Gatus API may be unavailable."

        healthy_count = 0
        total_count = len(data)
        issues = []

        for endpoint in data:
            name = endpoint.get('name', 'Unknown')
            results = endpoint.get('results', [])
            
            if results and results[0].get('success', False):
                healthy_count += 1
            else:
                issues.append(f"❌ {name}")

        if healthy_count == total_count:
            status_emoji = "✅"
            status_text = "All Systems Operational"
        elif healthy_count > total_count // 2:
            status_emoji = "⚠️"
            status_text = "Some Issues Detected"
        else:
            status_emoji = "🔴"
            status_text = "Multiple Systems Down"

        response = f"""🔍 <b>BCT Chain Quick Check</b>

{status_emoji} <b>Status:</b> {status_text}
📊 <b>Health:</b> {healthy_count}/{total_count} endpoints healthy

"""

        if issues:
            response += f"<b>Issues Found:</b>\n" + "\n".join(issues) + "\n\n"

        response += f"🕐 <b>Last Check:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}\n\nUse /status for detailed information"

        return response

    def cmd_status(self, message: Dict) -> str:
        """Handle /status command - detailed status report"""
        data = self.get_gatus_data()
        if not data:
            return "❌ Unable to fetch monitoring data. Gatus API may be unavailable."

        response = f"""📊 <b>BCT Chain Detailed Status Report</b>

🕐 <b>Generated:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

"""

        for endpoint in data:
            name = endpoint.get('name', 'Unknown')
            group = endpoint.get('group', 'Unknown')
            results = endpoint.get('results', [])
            
            if not results:
                response += f"❓ <b>{name}</b> ({group})\n   No data available\n\n"
                continue
                
            latest = results[0]
            success = latest.get('success', False)
            duration_ns = latest.get('duration', 0)
            duration_ms = duration_ns / 1_000_000 if duration_ns else 0
            timestamp = latest.get('timestamp', '')
            
            status_emoji = "✅" if success else "❌"
            
            response += f"""{status_emoji} <b>{name}</b> ({group})
   Response Time: {duration_ms:.0f}ms
   Last Check: {timestamp[:19] if timestamp else 'Unknown'}
   
"""

        response += "\nUse /health for summary or /uptime for statistics"
        return response

    def cmd_health(self, message: Dict) -> str:
        """Handle /health command - system health summary"""
        data = self.get_gatus_data()
        if not data:
            return "❌ Unable to fetch monitoring data. Gatus API may be unavailable."

        total_endpoints = len(data)
        healthy_endpoints = 0
        total_response_time = 0
        response_count = 0

        groups = {}

        for endpoint in data:
            name = endpoint.get('name', 'Unknown')
            group = endpoint.get('group', 'Unknown')
            results = endpoint.get('results', [])
            
            if group not in groups:
                groups[group] = {'total': 0, 'healthy': 0}
            groups[group]['total'] += 1
            
            if results:
                latest = results[0]
                if latest.get('success', False):
                    healthy_endpoints += 1
                    groups[group]['healthy'] += 1
                    
                duration_ns = latest.get('duration', 0)
                if duration_ns:
                    total_response_time += duration_ns / 1_000_000
                    response_count += 1

        overall_health = (healthy_endpoints / total_endpoints * 100) if total_endpoints > 0 else 0
        avg_response_time = (total_response_time / response_count) if response_count > 0 else 0

        if overall_health == 100:
            health_emoji = "🟢"
            health_status = "Excellent"
        elif overall_health >= 75:
            health_emoji = "🟡"
            health_status = "Good"
        elif overall_health >= 50:
            health_emoji = "🟠"
            health_status = "Fair"
        else:
            health_emoji = "🔴"
            health_status = "Poor"

        response = f"""🏥 <b>BCT Chain System Health</b>

{health_emoji} <b>Overall Health:</b> {health_status} ({overall_health:.1f}%)
⚡ <b>Average Response:</b> {avg_response_time:.0f}ms
📊 <b>Endpoints:</b> {healthy_endpoints}/{total_endpoints} healthy

<b>Group Status:</b>
"""

        for group_name, group_data in groups.items():
            group_health = (group_data['healthy'] / group_data['total'] * 100) if group_data['total'] > 0 else 0
            group_emoji = "✅" if group_health == 100 else "⚠️" if group_health >= 50 else "❌"
            response += f"{group_emoji} {group_name}: {group_data['healthy']}/{group_data['total']} ({group_health:.0f}%)\n"

        response += f"\n🕐 <b>Report Time:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}"

        return response

    def cmd_uptime(self, message: Dict) -> str:
        """Handle /uptime command - uptime statistics"""
        data = self.get_gatus_data()
        if not data:
            return "❌ Unable to fetch monitoring data. Gatus API may be unavailable."

        response = f"""📈 <b>BCT Chain Uptime Statistics</b>

🕐 <b>Generated:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

"""

        for endpoint in data:
            name = endpoint.get('name', 'Unknown')
            results = endpoint.get('results', [])
            
            if not results:
                response += f"❓ <b>{name}</b>\n   No uptime data available\n\n"
                continue
                
            # Calculate uptime from recent results
            total_checks = len(results)
            successful_checks = sum(1 for r in results if r.get('success', False))
            uptime_percentage = (successful_checks / total_checks * 100) if total_checks > 0 else 0
            
            uptime_emoji = "🟢" if uptime_percentage >= 99 else "🟡" if uptime_percentage >= 95 else "🔴"
            
            response += f"""{uptime_emoji} <b>{name}</b>
   Uptime: {uptime_percentage:.2f}%
   Checks: {successful_checks}/{total_checks}
   
"""

        response += "\nNote: Statistics based on recent monitoring data"
        return response

    def cmd_endpoints(self, message: Dict) -> str:
        """Handle /endpoints command - list all monitored endpoints"""
        data = self.get_gatus_data()
        if not data:
            return "❌ Unable to fetch monitoring data. Gatus API may be unavailable."

        response = f"""🔗 <b>BCT Chain Monitored Endpoints</b>

🕐 <b>Generated:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

"""

        groups = {}
        for endpoint in data:
            name = endpoint.get('name', 'Unknown')
            group = endpoint.get('group', 'Unknown')
            
            if group not in groups:
                groups[group] = []
            groups[group].append(name)

        for group_name, endpoints in groups.items():
            response += f"<b>📂 {group_name}:</b>\n"
            for endpoint in endpoints:
                response += f"   • {endpoint}\n"
            response += "\n"

        response += f"<b>Total:</b> {len(data)} endpoints across {len(groups)} groups"
        return response

    def cmd_alerts(self, message: Dict) -> str:
        """Handle /alerts command - show recent alerts"""
        return """🔔 <b>BCT Chain Alert System</b>

<b>Alert Configuration:</b>
✅ Immediate alerts for endpoint failures
✅ Recovery notifications when services restore
✅ Hourly status reports
✅ SSL certificate expiration warnings

<b>Recent Activity:</b>
This bot automatically sends alerts when:
• Endpoints become unresponsive
• Response times exceed thresholds
• SSL certificates are expiring
• Services recover from failures

Use /check or /status to see current system state.

<b>Alert History:</b>
Check your chat history for recent alerts and notifications."""

    def cmd_ping(self, message: Dict) -> str:
        """Handle /ping command - test connectivity"""
        return f"""🏓 <b>Pong!</b>

✅ Bot is online and responsive
🤖 BCT Chain Monitoring Bot v1.0
🕐 Server Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}
🌐 Connected to BCT Chain monitoring system

Use /check to verify endpoint health!"""

    def process_message(self, message: Dict):
        """Process incoming message"""
        try:
            chat_id = message['chat']['id']
            text = message.get('text', '').strip()
            
            # Only respond to messages in our configured chat
            if str(chat_id) != str(self.chat_id):
                logger.warning(f"Received message from unauthorized chat: {chat_id}")
                return
            
            logger.info(f"Processing command: {text}")
            
            # Find and execute command
            command = text.split()[0].lower() if text else ''
            
            if command in self.commands:
                response = self.commands[command](message)
                self.send_message(response)
            elif text.startswith('/'):
                # Unknown command
                response = f"❓ Unknown command: {command}\n\nUse /greeting to see all available commands."
                self.send_message(response)
            else:
                # Not a command, provide helpful response
                response = "👋 Hi! I'm your BCT Chain monitoring bot.\n\nUse /greeting to see all available commands or /check for a quick status update."
                self.send_message(response)
                
        except Exception as e:
            logger.error(f"Error processing message: {e}")

    def run(self):
        """Main bot loop"""
        logger.info("Starting Telegram bot...")
        
        # Send startup notification
        startup_message = """🤖 <b>BCT Chain Monitoring Bot Started</b>

✅ Bot is now online and ready!
🔍 Monitoring BCT Chain endpoints
🔔 Alerts and reports active

Use /greeting to see all available commands."""
        
        self.send_message(startup_message)
        
        while True:
            try:
                updates = self.get_updates()
                
                for update in updates:
                    self.last_update_id = update['update_id']
                    
                    if 'message' in update:
                        self.process_message(update['message'])
                
                time.sleep(1)  # Small delay to prevent API hammering
                
            except KeyboardInterrupt:
                logger.info("Bot stopping...")
                break
            except Exception as e:
                logger.error(f"Error in main loop: {e}")
                time.sleep(5)  # Wait before retrying

if __name__ == "__main__":
    bot = BCTChainTelegramBot()
    bot.run()
