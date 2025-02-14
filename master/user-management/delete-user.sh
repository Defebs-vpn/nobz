#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:41:44 UTC
# // Delete SSH & XRAY User Script

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
echo -e "\E[44;1;39m        ⇱ Delete SSH & XRAY User ⇲       \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# List existing users
echo "Existing users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E "^### " "/etc/xray/config/user.db" | cut -d ' ' -f 2-3
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# User Input
read -p "Input Username : " username

# Check if user exists
if ! grep -w -q "^$username:" /etc/passwd; then
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m        ⇱ Delete SSH & XRAY User ⇲       \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "${RED}User does not exist!${NC}"
    exit 1
fi

# Delete SSH User
userdel -f $username

# Delete XRAY User
sed -i "/\"email\": \"${username}@nobz.com\"/,/}}/d" /etc/xray/config/xray-core.json

# Remove from user database
sed -i "/^${username}:/d" /etc/xray/config/user.db

# Remove user config directory
rm -rf /etc/xray/config/user/${username}

# Log deletion
echo "$(date +%Y-%m-%d' '%H:%M:%S) - Deleted user ${username}" >> /etc/xray/logs/deleted-user.log

# Show Success Message
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m        ⇱ Delete SSH & XRAY User ⇲       \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username ${RED}$username${NC} has been deleted."
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"