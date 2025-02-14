#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:50:01 UTC
# // RAM Usage Monitor Script

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
echo -e "\E[44;1;39m            ⇱ RAM Usage ⇲               \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Get RAM Information
total=$(free -m | grep Mem | awk '{print $2}')
used=$(free -m | grep Mem | awk '{print $3}')
free=$(free -m | grep Mem | awk '{print $4}')
cached=$(free -m | grep Mem | awk '{print $6}')
usage_percent=$((used * 100 / total))

# Display RAM Usage
echo -e "Total RAM    : ${total}MB"
echo -e "Used RAM     : ${used}MB"
echo -e "Free RAM     : ${free}MB"
echo -e "Cached       : ${cached}MB"
echo -e "Usage        : ${usage_percent}%"

# RAM Usage Warning
if [ $usage_percent -ge 90 ]; then
    echo -e "${RED}WARNING: RAM usage is very high!${NC}"
elif [ $usage_percent -ge 75 ]; then
    echo -e "${YELLOW}NOTICE: RAM usage is high${NC}"
fi

# Top 5 RAM-consuming processes
echo -e "\nTop 5 RAM-consuming processes:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
ps aux --sort=-%mem | head -n 6 | awk '{print $4"% - "$11}'
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"