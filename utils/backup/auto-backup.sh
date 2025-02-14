#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:18:27 UTC
# // Auto Backup Script

# Configuration
BACKUP_DIR="/root/backup"
REMOTE_DIR="/backup"
MAX_BACKUPS=7
DATE=$(date +%Y%m%d-%H%M%S)
HOSTNAME=$(hostname)
BACKUP_NAME="backup-${HOSTNAME}-${DATE}"

# Load settings
source /etc/xray/config/backup.conf

# Create backup
create_backup() {
    # Create temp directory
    TMP_DIR=$(mktemp -d)
    
    # Copy files
    cp -r /etc/xray $TMP_DIR/
    cp -r /etc/nginx $TMP_DIR/
    cp -r /var/log/xray $TMP_DIR/
    
    # Create archive
    cd $TMP_DIR
    tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" *
    
    # Create checksum
    cd $BACKUP_DIR
    sha256sum "${BACKUP_NAME}.tar.gz" > "${BACKUP_NAME}.sha256"
    
    # Cleanup
    rm -rf $TMP_DIR
}

# Upload to remote (if configured)
upload_backup() {
    if [ -n "$REMOTE_HOST" ] && [ -n "$REMOTE_USER" ]; then
        scp "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
            "${BACKUP_DIR}/${BACKUP_NAME}.sha256" \
            "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
    fi
}

# Clean old backups
clean_backups() {
    # Local cleanup
    cd $BACKUP_DIR
    ls -t *.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
    ls -t *.sha256 | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
    
    # Remote cleanup (if configured)
    if [ -n "$REMOTE_HOST" ] && [ -n "$REMOTE_USER" ]; then
        ssh "${REMOTE_USER}@${REMOTE_HOST}" "cd ${REMOTE_DIR} && \
            ls -t *.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm && \
            ls -t *.sha256 | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm"
    fi
}

# Main process
echo "Starting auto backup at $(date)..."

# Create backup directory if not exists
mkdir -p $BACKUP_DIR

# Create backup
create_backup

# Upload if configured
if [ "$ENABLE_REMOTE" = "true" ]; then
    upload_backup
fi

# Clean old backups
clean_backups

echo "Auto backup completed at $(date)"