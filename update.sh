#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:33:03 UTC
# // XRAY Update Script

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
LOG_FILE="/var/log/xray/update.log"
BACKUP_DIR="/root/backup-before-update"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m          ⇱ UPDATE SCRIPT ⇲              \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
    echo -e "$1"
}

# Function to backup current installation
backup_current() {
    log_message "Creating backup of current installation..."
    mkdir -p $BACKUP_DIR
    
    # Backup configurations
    cp -r /etc/xray $BACKUP_DIR/
    cp -r /etc/nginx $BACKUP_DIR/
    cp -r /etc/stunnel $BACKUP_DIR/
    cp /etc/default/dropbear $BACKUP_DIR/
    
    # Create backup archive
    cd $BACKUP_DIR
    tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz *
    
    log_message "Backup created in $BACKUP_DIR"
}

# Function to update system packages
update_system() {
    log_message "Updating system packages..."
    apt update
    apt upgrade -y
    apt autoremove -y
    apt clean
}

# Function to update XRAY
update_xray() {
    log_message "Updating XRAY..."
    systemctl stop xray
    
    # Get latest version
    LATEST_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f 4)
    CURRENT_VERSION=$(xray -version | head -n1 | cut -d' ' -f2)
    
    if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
        log_message "New version available: $LATEST_VERSION"
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
        log_message "XRAY updated to version $LATEST_VERSION"
    else
        log_message "XRAY is already at the latest version"
    fi
    
    systemctl start xray
}

# Function to update scripts
update_scripts() {
    log_message "Updating scripts..."
    
    # Update utility scripts
    cp -r utils/* /etc/xray/utils/
    chmod +x /etc/xray/utils/*/*.sh
    
    # Update SSH scripts
    cp -r ssh/* /etc/xray/ssh/
    chmod +x /etc/xray/ssh/*/*.sh
    
    # Update menu scripts
    cp -r menu/* /etc/xray/menu/
    chmod +x /etc/xray/menu/*.sh
    
    log_message "Scripts updated successfully"
}

# Function to update configurations
update_configs() {
    log_message "Updating configurations..."
    
    # Update XRAY configs
    cp -r config/* /etc/xray/config/
    
    # Update NGINX configs
    cp -r nginx/* /etc/nginx/conf.d/
    
    # Restart services
    systemctl restart nginx
    systemctl restart xray
    
    log_message "Configurations updated successfully"
}

# Function to verify installation
verify_installation() {
    log_message "Verifying installation..."
    
    # Check services
    services=("xray" "nginx" "ssh" "dropbear" "stunnel4")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            log_message "$service: ${GREEN}Running${NC}"
        else
            log_message "$service: ${RED}Stopped${NC}"
            systemctl restart $service
        fi
    done
    
    # Check ports
    ports=(22 80 443 2052 2053)
    for port in "${ports[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            log_message "Port $port: ${GREEN}Open${NC}"
        else
            log_message "Port $port: ${RED}Closed${NC}"
        fi
    done
}

# Function to restore backup
restore_backup() {
    log_message "Available backups:"
    ls -1 $BACKUP_DIR/*.tar.gz 2>/dev/null
    
    read -p "Enter backup file name to restore (or press Enter to skip): " backup_file
    
    if [ -n "$backup_file" ] && [ -f "$BACKUP_DIR/$backup_file" ]; then
        log_message "Restoring backup..."
        cd $BACKUP_DIR
        tar -xzf "$backup_file"
        
        cp -r xray/* /etc/xray/
        cp -r nginx/* /etc/nginx/
        cp -r stunnel/* /etc/stunnel/
        cp dropbear /etc/default/
        
        systemctl restart xray nginx dropbear stunnel4
        log_message "Backup restored successfully"
    fi
}

# Main menu
while true; do
    echo -e "\n1. Update System Packages"
    echo -e "2. Update XRAY"
    echo -e "3. Update Scripts"
    echo -e "4. Update Configurations"
    echo -e "5. Backup Current Installation"
    echo -e "6. Restore from Backup"
    echo -e "7. Verify Installation"
    echo -e "8. Update All"
    echo -e "9. Exit"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Select option: " option
    
    case $option in
        1) update_system ;;
        2) update_xray ;;
        3) update_scripts ;;
        4) update_configs ;;
        5) backup_current ;;
        6) restore_backup ;;
        7) verify_installation ;;
        8)
            backup_current
            update_system
            update_xray
            update_scripts
            update_configs
            verify_installation
            ;;
        9) 
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo -e "Update completed!"
            echo -e "Created by: Defebs-vpn"
            echo -e "Created at: 2025-02-14 04:33:03 UTC"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            exit 0
            ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
done