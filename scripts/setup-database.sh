#!/bin/bash

# Database Security Setup Script for Gatus BCT Chain Monitor
# This script sets up SQLite database with security best practices

set -euo pipefail

# Configuration
DATA_DIR="./data"
DB_FILE="$DATA_DIR/gatus.db"
BACKUP_DIR="$DATA_DIR/backups"
LOG_FILE="$DATA_DIR/setup.log"

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

# Check if running as root (should not be)
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root for security reasons"
   exit 1
fi

# Create directories with proper permissions
log "Setting up directories..."
mkdir -p "$DATA_DIR" "$BACKUP_DIR"
chmod 750 "$DATA_DIR"
chmod 750 "$BACKUP_DIR"

# Create log file
touch "$LOG_FILE"
chmod 640 "$LOG_FILE"

log "Database setup completed successfully!"
log "Data directory: $DATA_DIR"
log "Database file will be created at: $DB_FILE"
log "Backups directory: $BACKUP_DIR"

# Security recommendations
log "Security recommendations:"
log "- Database file permissions will be set to 640 (owner read/write, group read)"
log "- Data directory permissions are set to 750 (owner full, group read/execute)"
log "- Run Docker container as non-root user (UID 1000)"
log "- Enable read-only filesystem with writable data volume"
log "- Regular backups are recommended (see backup script)"

echo ""
log "Setup complete! You can now start the Gatus container."
log "Run: docker-compose up -d"
