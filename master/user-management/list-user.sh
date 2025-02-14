#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:41:44 UTC
# // List SSH & XRAY Users Script

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
echo -e "\E[44;1;39m        ⇱ List SSH & XRAY Users ⇲        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Get current date
now=$(date +%Y-%m-%d)

# Read user database and display information
echo -e "\n${YELLOW}Current Users:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
printf "%-20s %-15s %-15s %-10s\n" "Username" "Created" "Expires" "Status"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

while IFS=: read -r username password exp; do
    if [ -n "$username" ]; then
        created=$(grep -w "$username" /etc/xray/logs/created-user.log | cut -d ' ' -f1)
        if [[ "$exp" < "$now" ]]; then
            status="${RED}Expired${NC}"
        else
            status="${GREEN}Active${NC}"
        fi
        printf "%-20s %-15s %-15s %-10s\n" "$username" "$created" "$exp" "$status"
    fi
done < /etc/xray/config/user.db

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Total Users: $(wc -l < /etc/xray/config/user.db)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"