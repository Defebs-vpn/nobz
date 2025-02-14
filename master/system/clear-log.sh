#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:53:22 UTC
# // Clear Log Files Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m            ⇱ Clear Logs ⇲               \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Backup logs before clearing
echo -e "Creating log backup..."
LOG_BACKUP="/root/log-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf $LOG_BACKUP /var/log/* /etc/xray/logs/*

# Clear logs
echo -e "Clearing system logs..."
truncate -s 0 /var/log/syslog
truncate -s 0 /var/log/auth.log
truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/messages

# Clear service logs
echo -e "Clearing service logs..."
truncate -s 0 /var/log/nginx/*.log
truncate -s 0 /var/log/xray/*.log
truncate -s 0 /var/log/openvpn/*.log

# Clear VPN logs
echo -e "Clearing VPN logs..."
truncate -s 0 /etc/xray/logs/*.log

# Restart rsyslog
systemctl restart rsyslog

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Logs have been cleared!"
echo -e "Backup saved to: $LOG_BACKUP"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"