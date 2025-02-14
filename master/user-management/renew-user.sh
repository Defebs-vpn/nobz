#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:41:44 UTC
# // Renew SSH & XRAY User Script

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
echo -e "\E[44;1;39m        ⇱ Renew SSH & XRAY User ⇲        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# List existing users
echo "Existing users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E "^### " "/etc/xray/config/user.db" | cut -d ' ' -f 2-3
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# User Input
read -p "Username : " username
read -p "Renew Days : " renew_days

# Check if user exists
if ! grep -w -q "^$username:" /etc/passwd; then
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m        ⇱ Renew SSH & XRAY User ⇲        \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "${RED}User does not exist!${NC}"
    exit 1
fi

# Get current expiry
curr_exp=$(chage -l $username | grep "Account expires" | cut -d " " -f3-)
curr_exp_date=$(date -d "$curr_exp" +%Y-%m-%d)

# Calculate new expiry
new_exp=$(date -d "${curr_exp_date} +${renew_days} days" +"%Y-%m-%d")

# Update SSH expiry
chage -E $(date -d "${new_exp}" +"%Y-%m-%d") $username

# Update user database
sed -i "s/\(^${username}:[^:]*:\)[^:]*/\1${new_exp}/" /etc/xray/config/user.db

# Update user config
if [ -f "/etc/xray/config/user/${username}/config.json" ]; then
    sed -i "s/\"expired\": \".*\"/\"expired\": \"${new_exp}\"/" /etc/xray/config/user/${username}/config.json
fi

# Log renewal
echo "$(date +%Y-%m-%d' '%H:%M:%S) - Renewed user ${username} for ${renew_days} days" >> /etc/xray/logs/renewed-user.log

# Show Success Message
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m        ⇱ Renew SSH & XRAY User ⇲        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username  : ${GREEN}$username${NC}"
echo -e "New Expiry: ${GREEN}$new_exp${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"