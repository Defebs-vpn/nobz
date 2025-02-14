#!/bin/bash
# User Management Menu Script
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

# Function to display banner
show_banner() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           USER MANAGEMENT MENU           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${GREEN}[1]${NC} Create User Account"
    echo -e " ${GREEN}[2]${NC} Delete User Account"
    echo -e " ${GREEN}[3]${NC} Extend User Account"
    echo -e " ${GREEN}[4]${NC} List All Users"
    echo -e " ${GREEN}[5]${NC} Monitor User Login"
    echo -e " ${GREEN}[6]${NC} Check User Details"
    echo -e " ${GREEN}[7]${NC} Limit Bandwidth"
    echo -e " ${GREEN}[8]${NC} Lock/Unlock User"
    echo -e " ${GREEN}[9]${NC} Auto Kill Multi Login"
    echo -e " ${GREEN}[0]${NC} Back to Main Menu"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Current Version: 1.0.0"
    echo -e " Current Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Create User Account
create_user() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           CREATE USER ACCOUNT           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -p "Username : " username
    read -p "Password : " password
    read -p "Duration (days) : " duration
    
    # Add user logic here
    useradd -e $(date -d "+${duration} days" +"%Y-%m-%d") -s /bin/false -M ${username}
    echo -e "${password}\n${password}" | passwd ${username}
    
    echo -e "${GREEN}User Created Successfully${NC}"
    read -n 1 -s -r -p "Press any key to continue"
}

# Delete User Account
delete_user() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           DELETE USER ACCOUNT           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -p "Username : " username
    
    userdel -f ${username}
    echo -e "${GREEN}User Deleted Successfully${NC}"
    read -n 1 -s -r -p "Press any key to continue"
}

# List All Users
list_users() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "              LIST ALL USERS              "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "USERNAME          EXP DATE         STATUS"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    while read expired; do
        AKUN="$(echo $expired | cut -d: -f1)"
        ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
        exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
        status="$(passwd -S $AKUN | awk '{print $2}')"
        
        if [[ $ID -ge 1000 ]]; then
            printf "%-17s %s %s\n" "$AKUN" "$exp" "$status"
        fi
    done < /etc/passwd
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -n 1 -s -r -p "Press any key to continue"
}

# Main menu loop
while true; do
    show_banner
    read -p "Select menu : " menu_option
    case $menu_option in
        1) create_user ;;
        2) delete_user ;;
        3) extend_user ;;
        4) list_users ;;
        5) monitor_login ;;
        6) check_user ;;
        7) limit_bandwidth ;;
        8) lock_user ;;
        9) auto_kill ;;
        0) break ;;
        *) echo -e "${RED}Please enter a valid number [0-9]${NC}"
           sleep 1
           ;;
    esac
done