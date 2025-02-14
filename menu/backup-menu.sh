#!/bin/bash
# Backup Management Menu Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:46:16 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Backup directory
BACKUP_DIR="/root/backup"
mkdir -p ${BACKUP_DIR}

# Function to display banner
show_banner() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           BACKUP MANAGEMENT MENU           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${GREEN}[1]${NC} Create Manual Backup"
    echo -e " ${GREEN}[2]${NC} Create Auto-Backup Schedule"
    echo -e " ${GREEN}[3]${NC} Restore from Backup"
    echo -e " ${GREEN}[4]${NC} List Backup Files"
    echo -e " ${GREEN}[5]${NC} Delete Backup Files"
    echo -e " ${GREEN}[6]${NC} Upload Backup to Google Drive"
    echo -e " ${GREEN}[7]${NC} Download Backup from Google Drive"
    echo -e " ${GREEN}[0]${NC} Back to Main Menu"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Current Version: 1.0.0"
    echo -e " Current Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Create backup function
create_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           CREATE MANUAL BACKUP           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Directories to backup
    echo -e "${YELLOW}Creating backup...${NC}"
    tar -czf ${BACKUP_DIR}/${BACKUP_NAME} \
        /etc/xray \
        /etc/nginx \
        /etc/php \
        /etc/passwd \
        /etc/shadow \
        /etc/gshadow \
        /etc/group \
        2>/dev/null
        
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup created successfully: ${BACKUP_NAME}${NC}"
    else
        echo -e "${RED}Backup creation failed${NC}"
    fi
    
    read -n 1 -s -r -p "Press any key to continue"
}

# List backup files
list_backups() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "              LIST BACKUP FILES              "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -d "${BACKUP_DIR}" ]; then
        echo -e "FILENAME                     SIZE         DATE"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        ls -lh ${BACKUP_DIR}/*.tar.gz 2>/dev/null | awk '{printf "%-25s %-12s %s %s %s\n", $9, $5, $6, $7, $8}'
    else
        echo -e "${RED}No backup files found${NC}"
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -n 1 -s -r -p "Press any key to continue"
}

# Restore from backup
restore_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           RESTORE FROM BACKUP           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    list_backups
    echo -e ""
    read -p "Enter backup filename to restore: " backup_file
    
    if [ -f "${BACKUP_DIR}/${backup_file}" ]; then
        echo -e "${YELLOW}Restoring backup...${NC}"
        tar -xzf "${BACKUP_DIR}/${backup_file}" -C /
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Backup restored successfully${NC}"
            # Restart services
            systemctl restart xray nginx php-fpm
        else
            echo -e "${RED}Backup restoration failed${NC}"
        fi
    else
        echo -e "${RED}Backup file not found${NC}"
    fi
    
    read -n 1 -s -r -p "Press any key to continue"
}

# Setup auto-backup
setup_autobackup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "         SETUP AUTO-BACKUP SCHEDULE         "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    read -p "Enter backup frequency (daily/weekly/monthly): " frequency
    
    case $frequency in
        daily)
            CRON="0 0 * * *"
            ;;
        weekly)
            CRON="0 0 * * 0"
            ;;
        monthly)
            CRON="0 0 1 * *"
            ;;
        *)
            echo -e "${RED}Invalid frequency${NC}"
            read -n 1 -s -r -p "Press any key to continue"
            return
            ;;
    esac
    
    # Create auto-backup script
    cat > /usr/local/bin/auto-backup << EOF
#!/bin/bash
BACKUP_DIR="${BACKUP_DIR}"
BACKUP_NAME="backup_\$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf \${BACKUP_DIR}/\${BACKUP_NAME} /etc/xray /etc/nginx /etc/php /etc/passwd /etc/shadow /etc/gshadow /etc/group 2>/dev/null
find \${BACKUP_DIR} -type f -mtime +7 -delete
EOF
    
    chmod +x /usr/local/bin/auto-backup
    
    # Add to crontab
    echo "${CRON} root /usr/local/bin/auto-backup" > /etc/cron.d/auto-backup
    
    echo -e "${GREEN}Auto-backup scheduled successfully${NC}"
    read -n 1 -s -r -p "Press any key to continue"
}

# Main menu loop
while true; do
    show_banner
    read -p "Select menu : " menu_option
    case $menu_option in
        1) create_backup ;;
        2) setup_autobackup ;;
        3) restore_backup ;;
        4) list_backups ;;
        5) delete_backups ;;
        6) upload_backup ;;
        7) download_backup ;;
        0) break ;;
        *) echo -e "${RED}Please enter a valid number [0-7]${NC}"
           sleep 1
           ;;
    esac