#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:47:35 UTC
# // Ban User Account Script

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
echo -e "\E[44;1;39m          ⇱ Ban User Account ⇲           \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# List active users
echo "Active users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -v ":\*" /etc/shadow | cut -d: -f1
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

read -p "Username : " user

# Check if user exists
if ! grep -w -q "^$user:" /etc/passwd; then
    echo -e "${RED}User does not exist!${NC}"
    exit 1
fi

# Get user IP
user_ip=$(grep -w "$user" /var/log/auth.log | grep -i "Accepted" | tail -n 1 | awk '{print $11}')

# Ban user and IP
passwd -l $user > /dev/null 2>&1
echo "$user" >> /etc/xray/config/banned-user.db
echo "$user_ip" >> /etc/xray/config/banned-ip.db

# Block IP using iptables
if [ ! -z "$user_ip" ]; then
    iptables -A INPUT -s $user_ip -j DROP
    iptables-save > /etc/iptables.rules
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username ${RED}$user${NC} has been banned!"
if [ ! -z "$user_ip" ]; then
    echo -e "IP ${RED}$user_ip${NC} has been blocked!"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"