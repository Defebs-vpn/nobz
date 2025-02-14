#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:45:25 UTC
# // Unlock User Account Script

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
echo -e "\E[44;1;39m         ⇱ Unlock User Account ⇲         \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# List locked users
echo "Locked users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
if [ -f "/etc/xray/config/locked-user.db" ]; then
    cat /etc/xray/config/locked-user.db
else
    echo "No locked users found"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

read -p "Username : " user

# Check if user exists
if ! grep -w -q "^$user:" /etc/passwd; then
    echo -e "${RED}User does not exist!${NC}"
    exit 1
fi

# Unlock user account
passwd -u $user > /dev/null 2>&1
sed -i "/^$user$/d" /etc/xray/config/locked-user.db

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username ${GREEN}$user${NC} has been unlocked!"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"