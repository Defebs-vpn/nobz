#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:35:25 UTC
# // XRAY Uninstall Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Log file
LOG_FILE="/var/log/xray/uninstall.log"
BACKUP_DIR="/root/backup-before-uninstall"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m         ⇱ UNINSTALL SCRIPT ⇲            \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
    echo -e "$1"
}

# Function to backup configurations
backup_configs() {
    log_message "Creating backup before uninstall..."
    mkdir -p $BACKUP_DIR
    
    # Backup configurations
    cp -r /etc/xray $BACKUP_DIR/
    cp -r /etc/nginx/conf.d $BACKUP_DIR/
    cp -r /etc/stunnel $BACKUP_DIR/
    cp /etc/default/dropbear $BACKUP_DIR/
    
    # Create backup archive
    cd $BACKUP_DIR
    tar -czf backup-before-uninstall-$(date +%Y%m%d-%H%M%S).tar.gz *
    
    log_message "Backup created in $BACKUP_DIR"
}

# Function to remove XRAY
remove_xray() {
    log_message "Removing XRAY..."
    systemctl stop xray
    systemctl disable xray
    
    # Remove XRAY binary and configurations
    rm -rf /usr/local/bin/xray
    rm -rf /etc/xray
    rm -rf /var/log/xray
    rm -f /etc/systemd/system/xray.service
    rm -f /etc/systemd/system/xray@.service
    
    systemctl daemon-reload
    log_message "XRAY removed"
}

# Function to remove SSH and related services
remove_ssh_services() {
    log_message "Removing SSH related services..."
    
    # Stop and disable services
    systemctl stop ssh dropbear stunnel4
    systemctl disable ssh dropbear stunnel4
    
    # Remove packages
    apt remove -y openssh-server dropbear stunnel4
    apt purge -y openssh-server dropbear stunnel4
    
    # Remove configurations
    rm -rf /etc/ssh
    rm -rf /etc/dropbear
    rm -rf /etc/stunnel
    rm -f /etc/default/dropbear
    
    log_message "SSH services removed"
}

# Function to remove NGINX
remove_nginx() {
    log_message "Removing NGINX..."
    systemctl stop nginx
    systemctl disable nginx
    
    apt remove -y nginx
    apt purge -y nginx
    
    rm -rf /etc/nginx
    rm -rf /var/www/html
    
    log_message "NGINX removed"
}

# Function to remove acme.sh
remove_acme() {
    log_message "Removing acme.sh..."
    if [ -f ~/.acme.sh/acme.sh ]; then
        ~/.acme.sh/acme.sh --uninstall
        rm -rf ~/.acme.sh
    fi
    log_message "acme.sh removed"
}

# Function to remove additional components
remove_additional() {
    log_message "Removing additional components..."
    
    # Remove Python packages
    pip3 uninstall -y websocket-client
    
    # Remove cron jobs
    crontab -r
    
    # Remove logs
    rm -rf /var/log/xray
    rm -rf /var/log/nginx
    
    log_message "Additional components removed"
}

# Function to clean system
clean_system() {
    log_message "Cleaning system..."
    
    # Remove dependencies
    apt autoremove -y
    apt clean
    
    # Reset BBR settings
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    sysctl -p
    
    log_message "System cleaned"
}

# Main uninstall process
read -p "Do you want to backup configurations before uninstall? (y/n): " backup_choice
if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    backup_configs
fi

echo -e "\n${RED}Warning: This will completely remove XRAY and all related services!${NC}"
read -p "Are you sure you want to continue? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    remove_xray
    remove_ssh_services
    remove_nginx
    remove_acme
    remove_additional
    clean_system
    
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m      ⇱ UNINSTALL COMPLETED ⇲           \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "All components have been removed"
    if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
        echo -e "Backup saved in: $BACKUP_DIR"
    fi
    echo -e "Created by: Defebs-vpn"
    echo -e "Created at: 2025-02-14 04:35:25 UTC"
    echo -e "Log file: $LOG_FILE"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Please reboot your system!"
else
    echo -e "Uninstall cancelled"
    exit 0
fi