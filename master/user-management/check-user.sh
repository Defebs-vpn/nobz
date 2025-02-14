#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:45:25 UTC
# // Check SSH & XRAY User Login Script

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
echo -e "\E[44;1;39m        ⇱ Check User Login Status ⇲       \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Check SSH Login
echo -e "\n${YELLOW}SSH Login Sessions:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
printf "%-20s %-15s %-15s\n" "Username" "IP" "Connected Since"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

data=($(ps aux | grep -i dropbear | awk '{print $2}'))
for PID in "${data[@]}"
do
    NUM=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "$(date +"%Y-%m-%d")" | grep -w "$PID" | wc -l)
    USER=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "$(date +"%Y-%m-%d")" | grep -w "$PID" | awk '{print $10}' | head -n1)
    IP=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "$(date +"%Y-%m-%d")" | grep -w "$PID" | awk '{print $12}' | head -n1)
    if [ $NUM -eq 1 ]; then
        printf "%-20s %-15s %-15s\n" "$USER" "$IP" "$(date -d @$(ps -o etime= -p $PID | awk '{print $1}') +%H:%M:%S)"
    fi
done

# Check XRAY Login
echo -e "\n${YELLOW}XRAY Active Connections:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
printf "%-20s %-15s %-15s\n" "Username" "IP" "Protocol"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Read XRAY connection logs
netstat -anp | grep ESTABLISHED | grep xray | awk '{print $5}' | cut -d: -f1 | sort | uniq > /tmp/xray-login.txt

while read -r ip; do
    user=$(grep -w "$ip" /var/log/xray/access.log | tail -n 1 | awk '{print $3}')
    protocol=$(grep -w "$ip" /var/log/xray/access.log | tail -n 1 | awk '{print $2}')
    if [ -n "$user" ]; then
        printf "%-20s %-15s %-15s\n" "$user" "$ip" "$protocol"
    fi
done < /tmp/xray-login.txt

rm -f /tmp/xray-login.txt
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"