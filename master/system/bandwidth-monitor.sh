#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:50:01 UTC
# // Bandwidth Monitor Script

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
echo -e "\E[44;1;39m          ⇱ Bandwidth Monitor ⇲          \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Check if vnstat is installed
if ! which vnstat > /dev/null; then
    echo -e "${RED}vnstat is not installed. Installing...${NC}"
    apt update && apt install vnstat -y
    systemctl enable vnstat
    systemctl start vnstat
fi

# Get Network Interface
INTERFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

# Display Bandwidth Usage
echo -e "Network Interface: $INTERFACE\n"
echo -e "Today's Usage:"
vnstat -i $INTERFACE --oneline | cut -d\; -f4,5
echo -e "\nMonthly Usage:"
vnstat -i $INTERFACE -m | tail -n 4
echo -e "\nTop 10 Usage Days:"
vnstat -i $INTERFACE -d | tail -n 10

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"