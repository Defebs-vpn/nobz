#!/bin/bash
# Backup Restore Utility
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:50:53 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m"

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Directories
BACKUP_DIR="/root/backup"
TEMP_DIR="/tmp/restore_temp"
LOG_FILE="/var/log/restore.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> ${LOG_FILE}
    echo -e "$1"
}

# Function to check required files
check_requirements() {
    log_message "${YELLOW}Checking requirements...${NC}"
    
    if [ ! -d "${BACKUP_DIR}" ]; then
        log_message "${RED}Backup directory not found${NC}"
        exit 1
    fi
    
    which tar > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log_message "${RED}tar is not installed${NC}"
        exit 1
    }
}

# Function to verify backup file
verify_backup() {
    local backup_file="$1"
    
    log_message "${YELLOW}Verifying backup file: ${backup_file}${NC}"
    
    if [ ! -f "${backup_file}" ]; then
        log_message "${RED}Backup file not found${NC}"
        return 1
    }
    
    # Check if file is a valid tar.gz
    tar -tzf "${backup_file}" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log_message "${RED}Invalid backup file format${NC}"
        return 1
    }
    
    return 0
}

# Function to stop services
stop_services() {
    log_message "${YELLOW}Stopping services...${NC}"
    
    services=("nginx" "xray" "dropbear" "stunnel4" "squid" "php-fpm")
    
    for service in "${services[@]}"; do
        systemctl stop ${service} 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "${GREEN}Stopped ${service}${NC}"
        else
            log_message "${YELLOW}Failed to stop ${service}${NC}"
        fi
    done
}

# Function to start services
start_services() {
    log_message "${YELLOW}Starting services...${NC}"
    
    services=("nginx" "xray" "dropbear" "stunnel4" "squid" "php-fpm")
    
    for service in "${services[@]}"; do
        systemctl start ${service} 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "${GREEN}Started ${service}${NC}"
        else
            log_message "${RED}Failed to start ${service}${NC}"
        fi
    done
}

# Function to create backup of current config
backup_current() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local current_backup="${BACKUP_DIR}/pre_restore_${timestamp}.tar.gz"
    
    log_message "${YELLOW}Creating backup of current configuration...${NC}"
    
    tar -czf "${current_backup}" \
        /etc/xray \
        /etc/nginx \
        /etc/stunnel \
        /etc/dropbear \
        /etc/squid \
        /etc/php \
        2>/dev/null
        
    if [ $? -eq 0 ]; then
        log_message "${GREEN}Current configuration backed up to: ${current_backup}${NC}"
    else
        log_message "${RED}Failed to backup current configuration${NC}"
        exit 1
    fi
}

# Function to restore backup
restore_backup() {
    local backup_file="$1"
    
    # Create temp directory
    mkdir -p ${TEMP_DIR}
    
    log_message "${YELLOW}Extracting backup to temporary location...${NC}"
    tar -xzf "${backup_file}" -C ${TEMP_DIR}
    
    if [ $? -ne 0 ]; then
        log_message "${RED}Failed to extract backup${NC}"
        rm -rf ${TEMP_DIR}
        exit 1
    }
    
    log_message "${YELLOW}Restoring configuration files...${NC}"
    
    # Restore configuration directories
    cp -rf ${TEMP_DIR}/etc/xray/* /etc/xray/ 2>/dev/null
    cp -rf ${TEMP_DIR}/etc/nginx/* /etc/nginx/ 2>/dev/null
    cp -rf ${TEMP_DIR}/etc/stunnel/* /etc/stunnel/ 2>/dev/null
    cp -rf ${TEMP_DIR}/etc/dropbear/* /etc/dropbear/ 2>/dev/null
    cp -rf ${TEMP_DIR}/etc/squid/* /etc/squid/ 2>/dev/null
    cp -rf ${TEMP_DIR}/etc/php/* /etc/php/ 2>/dev/null
    
    # Restore system files carefully
    while IFS=: read -r username password uid gid info home shell; do
        if [ $uid -ge 1000 ] && [ $uid -ne 65534 ]; then
            useradd -M -u ${uid} -g ${gid} -s ${shell} ${username} 2>/dev/null
        fi
    done < ${TEMP_DIR}/etc/passwd
    
    # Clean up
    rm -rf ${TEMP_DIR}
}

# Main restore process
main() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           BACKUP RESTORE UTILITY           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # List available backups
    echo -e "\nAvailable backup files:"
    ls -1 ${BACKUP_DIR}/*.tar.gz 2>/dev/null
    
    echo -e "\n${YELLOW}Enter backup file name to restore:${NC}"
    read -p "> " backup_name
    
    backup_file="${BACKUP_DIR}/${backup_name}"
    
    # Verify backup file
    verify_backup "${backup_file}"
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    echo -e "\n${RED}WARNING: This will overwrite your current configuration${NC}"
    echo -e "${RED}Do you want to continue? (y/n)${NC}"
    read -p "> " confirm
    
    if [[ "${confirm}" != "y" ]]; then
        log_message "${YELLOW}Restore cancelled${NC}"
        exit 0
    fi
    
    # Start restore process
    backup_current
    stop_services
    restore_backup "${backup_file}"
    start_services
    
    log_message "${GREEN}Restore completed successfully${NC}"
    echo -e "\n${YELLOW}Please check all services are running correctly${NC}"
}

# Run main function
main