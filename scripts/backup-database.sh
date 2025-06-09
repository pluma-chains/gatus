#!/bin/bash

# SQLite Database Backup Script for Gatus BCT Chain Monitor
# This script creates secure backups of the SQLite database

set -euo pipefail

# Configuration
DATA_DIR="./data"
DB_FILE="$DATA_DIR/gatus.db"
BACKUP_DIR="$DATA_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/gatus_backup_$TIMESTAMP.db"
COMPRESSED_BACKUP="$BACKUP_FILE.gz"
LOG_FILE="$DATA_DIR/backup.log"

# Retention settings (days)
BACKUP_RETENTION_DAYS=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

# Check if database exists
if [[ ! -f "$DB_FILE" ]]; then
    error "Database file not found: $DB_FILE"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"
chmod 750 "$BACKUP_DIR"

log "Starting database backup..."

# Create backup using SQLite3 backup command for consistency
if command -v sqlite3 &> /dev/null; then
    log "Creating backup using sqlite3 backup command..."
    sqlite3 "$DB_FILE" ".backup '$BACKUP_FILE'"
else
    log "sqlite3 not found, using file copy..."
    cp "$DB_FILE" "$BACKUP_FILE"
fi

# Verify backup integrity
log "Verifying backup integrity..."
if sqlite3 "$BACKUP_FILE" "PRAGMA integrity_check;" | grep -q "ok"; then
    log "Backup integrity check passed"
else
    error "Backup integrity check failed"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Compress backup
log "Compressing backup..."
gzip "$BACKUP_FILE"

# Set secure permissions
chmod 640 "$COMPRESSED_BACKUP"

# Get backup size
BACKUP_SIZE=$(du -h "$COMPRESSED_BACKUP" | cut -f1)
log "Backup created successfully: $COMPRESSED_BACKUP (Size: $BACKUP_SIZE)"

# Clean up old backups
log "Cleaning up backups older than $BACKUP_RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "gatus_backup_*.db.gz" -type f -mtime +$BACKUP_RETENTION_DAYS -delete
REMAINING_BACKUPS=$(find "$BACKUP_DIR" -name "gatus_backup_*.db.gz" -type f | wc -l)
log "Backup cleanup completed. $REMAINING_BACKUPS backup(s) remaining."

# Database statistics
DB_SIZE=$(du -h "$DB_FILE" | cut -f1)
RECORD_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM endpoint_results;")
log "Database statistics:"
log "  - Database size: $DB_SIZE"
log "  - Total monitoring records: $RECORD_COUNT"

log "Backup process completed successfully!"

# Optional: Send notification about backup completion
# You can uncomment and configure this section for alerts
# curl -X POST "your-webhook-url" \
#   -H "Content-Type: application/json" \
#   -d "{\"text\":\"Gatus database backup completed successfully. Size: $BACKUP_SIZE, Records: $RECORD_COUNT\"}"
