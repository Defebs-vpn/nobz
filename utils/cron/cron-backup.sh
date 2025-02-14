#!/bin/bash
# Automatic Backup Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:54:23 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Directories
BACKUP_DIR="/root/backup"
LOG_FILE="/var/log/cron-backup.log"

# Create backup directory if not exists
mkdir -p ${BACKUP_DIR}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] $1" >> ${LOG_FILE}
}

# Cleanup old backups (keep last 7 days)
cleanup_old_backups() {
    log_message "Cleaning up old backups..."
    find ${BACKUP_DIR} -type f -name "*.tar.gz" -mtime +7 -delete
}

# Create backup
create_backup() {
    BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    log_message "Creating backup: ${BACKUP_NAME}"
    
    tar -czf ${BACKUP_DIR}/${BACKUP_NAME} \
        /etc/xray \
        /etc/nginx \
        /etc/stunnel \
        /etc/dropbear \
        /etc/squid \
        /etc/php \
        /etc/passwd \
        /etc/shadow \
        /etc/gshadow \
        /etc/group \
        2>/dev/null
        
    if [ $? -eq 0 ]; then
        log_message "Backup created successfully"
        
        # Calculate backup size
        SIZE=$(du -h ${BACKUP_DIR}/${BACKUP_NAME} | awk '{print $1}')
        log_message "Backup size: ${SIZE}"
        
        # Optional: Upload to remote storage
        # upload_to_remote ${BACKUP_DIR}/${BACKUP_NAME}
    else
        log_message "Backup creation failed"
    fi
}

# Optional: Upload to remote storage
upload_to_remote() {
    local file="$1"
    log_message "Uploading backup to remote storage..."
    
    # Add your upload logic here
    # Example: rclone copy "${file}" remote:backup/
}

# Main process
log_message "Starting automatic backup process"

# Check disk space
DISK_SPACE=$(df -h ${BACKUP_DIR} | awk '/\// {print $(NF-2)}' | sed 's/G//')
if [ $(echo "${DISK_SPACE} < 5" | bc) -eq 1 ]; then
    log_message "Warning: Low disk space (${DISK_SPACE}GB)"
    cleanup_old_backups
fi

# Create backup
create_backup

# Cleanup old backups
cleanup_old_backups

log_message "Backup process completed"