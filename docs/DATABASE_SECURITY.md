# SQLite Database Security Configuration for Gatus BCT Chain Monitor

This document outlines the security best practices implemented for the SQLite database configuration in the Gatus BCT Chain monitoring system.

## 🔒 Security Features Implemented

### 1. Container Security

- **Non-root execution**: Container runs as user ID 1000 (gatus user)
- **Read-only filesystem**: Container filesystem is mounted read-only
- **No new privileges**: Prevents privilege escalation
- **Minimal attack surface**: Uses Alpine Linux base with only necessary packages

### 2. Database Security

- **Isolated data volume**: Database stored in secure Docker volume
- **File permissions**: Database files have restricted permissions (640)
- **Directory permissions**: Data directory restricted to owner and group (750)
- **WAL mode**: SQLite configured with Write-Ahead Logging for better performance and safety

### 3. Backup and Recovery

- **Automated backups**: Scheduled backup script with integrity verification
- **Compressed storage**: Backups are gzipped to save space
- **Retention policy**: Old backups automatically cleaned up (30-day default)
- **Integrity checks**: All backups verified for consistency

## 📁 Directory Structure

```
gatus/
├── data/                    # SQLite database and logs (gitignored)
│   ├── gatus.db            # Main SQLite database
│   ├── backups/            # Database backups
│   └── *.log               # Application logs
├── scripts/                # Database management scripts
│   ├── setup-database.sh   # Initial setup script
│   └── backup-database.sh  # Backup automation script
└── config.yaml            # Gatus configuration with SQLite settings
```

## 🚀 Quick Setup

1. **Initialize the database**:

   ```bash
   cd /path/to/gatus
   ./scripts/setup-database.sh
   ```

2. **Start the monitoring system**:

   ```bash
   docker-compose up -d
   ```

3. **Verify database creation**:
   ```bash
   ls -la data/
   ```

## 🔧 Configuration Details

### SQLite Settings in config.yaml:

```yaml
storage:
  type: sqlite
  path: /data/gatus.db
  caching: true # Enable write-through caching
  maximum-number-of-results: 200 # Increased for better history
  maximum-number-of-events: 100 # Increased for comprehensive logging
```

### Docker Security Settings:

```yaml
services:
  gatus:
    user: "1000:1000" # Non-root user
    security_opt:
      - no-new-privileges:true # Prevent privilege escalation
    read_only: true # Read-only container filesystem
    tmpfs: # Writable temporary filesystems
      - /tmp:noexec,nosuid,size=100m
      - /data:exec,nosuid,size=500m
```

## 📊 Database Management

### Manual Backup

```bash
./scripts/backup-database.sh
```

### Check Database Status

```bash
docker exec gatus-bct-monitor sqlite3 /data/gatus.db "PRAGMA integrity_check;"
```

### View Database Size

```bash
docker exec gatus-bct-monitor du -h /data/gatus.db
```

### Query Monitoring Records

```bash
docker exec gatus-bct-monitor sqlite3 /data/gatus.db "SELECT COUNT(*) FROM endpoint_results;"
```

## 🔐 Security Checklist

- ✅ Container runs as non-root user (UID 1000)
- ✅ Read-only container filesystem enabled
- ✅ Database files excluded from git (.gitignore)
- ✅ Proper file permissions (640 for DB, 750 for directories)
- ✅ No new privileges security option enabled
- ✅ Automated backup system with integrity checks
- ✅ Minimal container base (Alpine Linux)
- ✅ SQLite WAL mode enabled for performance and safety
- ✅ Write-through caching enabled
- ✅ Healthcheck configured for monitoring
- ✅ Resource limits via tmpfs

## 🛡️ Additional Security Recommendations

### 1. Network Security

- Place behind reverse proxy (nginx/traefik) with TLS
- Use firewall rules to restrict access
- Consider VPN access for sensitive monitoring data

### 2. Monitoring and Alerting

- Monitor disk space usage for database growth
- Set up alerts for backup failures
- Monitor database performance metrics

### 3. Backup Strategy

- Store backups in separate location/server
- Test backup restoration procedures regularly
- Consider encrypted backup storage for sensitive data

### 4. Access Control

- Implement authentication if exposing publicly
- Use strong passwords for any admin interfaces
- Regular security updates for base images

## 🔄 Automated Backup Setup

To set up automated daily backups via cron:

```bash
# Add to crontab (crontab -e)
0 2 * * * /path/to/gatus/scripts/backup-database.sh >> /var/log/gatus-backup.log 2>&1
```

## 📈 Performance Monitoring

The SQLite configuration includes performance optimizations:

- **WAL mode**: Better concurrent access
- **Write-through caching**: Faster read operations
- **Proper indexing**: Automatically created by Gatus
- **Regular cleanup**: Old data automatically purged

## 🆘 Troubleshooting

### Database Locked Errors

```bash
# Check for stuck processes
docker exec gatus-bct-monitor ps aux

# Restart container if needed
docker-compose restart gatus
```

### Disk Space Issues

```bash
# Check database size
docker exec gatus-bct-monitor du -sh /data/

# Check available space
df -h
```

### Backup Failures

Check the backup log:

```bash
cat data/backup.log
```

## 📞 Support

For issues related to:

- Database corruption: Check integrity and restore from backup
- Performance issues: Monitor query performance and disk I/O
- Security concerns: Review access logs and update configurations

This configuration provides a secure, performant, and maintainable SQLite setup for the BCT Chain monitoring system.
