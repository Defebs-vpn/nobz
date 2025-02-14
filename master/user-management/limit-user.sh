#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:45:25 UTC
# // Limit SSH & XRAY User Login Script

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
echo -e "\E[44;1;39m          ⇱ Limit User Login ⇲           \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# User Input
read -p "Username : " user
read -p "Limit Login : " limit

# Check if user exists
if ! grep -w -q "^$user:" /etc/passwd; then
    echo -e "${RED}User does not exist!${NC}"
    exit 1
fi

# Update user limit in config
echo "$user $limit" > /etc/xray/config/limit-user/$user

# Check current login
login=$(ps -u "$user" | wc -l)
if [ $login -gt $limit ]; then
    # Kill excess connections
    ps -u "$user" --no-headers | head -n -$limit | awk '{print $1}' | xargs kill -9 > /dev/null 2>&1
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username : ${GREEN}$user${NC}"
echo -e "Limit    : ${GREEN}$limit${NC} login"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"