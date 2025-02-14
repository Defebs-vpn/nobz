#!/bin/bash
# Automatic Server Reboot Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:54:23 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Log file
LOG_FILE="/var/log/cron-auto-reboot.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] $1" >> ${LOG_FILE}
}

# Check system load
LOAD=$(cat /proc/loadavg | awk '{print $1}')
MEMORY=$(free -m | awk '/Mem:/ {printf "%.2f", $3/$2*100}')
DISK=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//')

log_message "System status before reboot:"
log_message "Load Average: $LOAD"
log_message "Memory Usage: ${MEMORY}%"
log_message "Disk Usage: ${DISK}%"

# Gracefully stop services
log_message "Stopping services..."
systemctl stop nginx
systemctl stop xray
systemctl stop dropbear
systemctl stop stunnel4
systemctl stop squid

# Sync filesystem
log_message "Syncing filesystem..."
sync

# Reboot system
log_message "Initiating system reboot..."
shutdown -r now