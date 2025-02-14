#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:18:27 UTC
# // Backup Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

# Configuration
BACKUP_DIR="/root/backup"
DATE=$(date +%Y%m%d-%H%M%S)
HOSTNAME=$(hostname)
BACKUP_NAME="backup-${HOSTNAME}-${DATE}"

# Paths to backup
XRAY_DIR="/etc/xray"
SSH_DIR="/etc/xray/ssh"
NGINX_DIR="/etc/nginx"
LOG_DIR="/var/log/xray"

# Create backup directory
mkdir -p $BACKUP_DIR

# Function to create backup
create_backup() {
    echo -e "Creating backup..."
    
    # Create temp directory
    TMP_DIR=$(mktemp -d)
    
    # Copy files to temp directory
    cp -r $XRAY_DIR $TMP_DIR/
    cp -r $SSH_DIR $TMP_DIR/
    cp -r $NGINX_DIR $TMP_DIR/
    cp -r $LOG_DIR $TMP_DIR/
    
    # Create backup archive
    cd $TMP_DIR
    tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" *
    
    # Create checksum
    cd $BACKUP_DIR
    sha256sum "${BACKUP_NAME}.tar.gz" > "${BACKUP_NAME}.sha256"
    
    # Cleanup
    rm -rf $TMP_DIR
    
    echo -e "${GREEN}Backup created: ${BACKUP_NAME}.tar.gz${NC}"
}

# Function to verify backup
verify_backup() {
    local backup_file="$1"
    local checksum_file="${backup_file%.*}.sha256"
    
    if [ -f "$backup_file" ] && [ -f "$checksum_file" ]; then
        echo -e "Verifying backup..."
        cd $BACKUP_DIR
        if sha256sum -c "$checksum_file"; then
            echo -e "${GREEN}Backup verified successfully${NC}"
            return 0
        else
            echo -e "${RED}Backup verification failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}Backup or checksum file not found${NC}"
        return 1
    fi
}

# Function to restore backup
restore_backup() {
    local backup_file="$1"
    
    if verify_backup "$backup_file"; then
        echo -e "Restoring backup..."
        
        # Create temp directory
        TMP_DIR=$(mktemp -d)
        
        # Extract backup
        tar -xzf "$backup_file" -C $TMP_DIR
        
        # Stop services
        systemctl stop xray nginx
        
        # Restore files
        cp -r $TMP_DIR/xray/* $XRAY_DIR/
        cp -r $TMP_DIR/ssh/* $SSH_DIR/
        cp -r $TMP_DIR/nginx/* $NGINX_DIR/
        cp -r $TMP_DIR/log/* $LOG_DIR/
        
        # Cleanup
        rm -rf $TMP_DIR
        
        # Restart services
        systemctl restart xray nginx
        
        echo -e "${GREEN}Backup restored successfully${NC}"
    fi
}

# Main menu
show_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m            ⇱ BACKUP MENU ⇲             \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "1. Create Backup"
    echo -e "2. List Backups"
    echo -e "3. Verify Backup"
    echo -e "4. Restore Backup"
    echo -e "5. Delete Backup"
    echo -e "6. Exit"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Select option: " option
    
    case $option in
        1) create_backup ;;
        2)
            echo -e "\nAvailable backups:"
            ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null || echo "No backups found"
            ;;
        3)
            echo -e "\nSelect backup to verify:"
            select backup in $BACKUP_DIR/*.tar.gz; do
                if [ -n "$backup" ]; then
                    verify_backup "$backup"
                    break
                else
                    echo -e "${RED}Invalid selection${NC}"
                fi
            done
            ;;
        4)
            echo -e "\nSelect backup to restore:"
            select backup in $BACKUP_DIR/*.tar.gz; do
                if [ -n "$backup" ]; then
                    restore_backup "$backup"
                    break
                else
                    echo -e "${RED}Invalid selection${NC}"
                fi
            done
            ;;
        5)
            echo -e "\nSelect backup to delete:"
            select backup in $BACKUP_DIR/*.tar.gz; do
                if [ -n "$backup" ]; then
                    rm -f "$backup" "${backup%.*}.sha256"
                    echo -e "${GREEN}Backup deleted${NC}"
                    break
                else
                    echo -e "${RED}Invalid selection${NC}"
                fi
            done
            ;;
        6) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}

# Run menu
while true; do
    show_menu
    read -p "Press enter to continue"
done