#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:50:01 UTC
# // System Information Script

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
echo -e "\E[44;1;39m         ⇱ System Information ⇲          \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Get System Information
IPVPS=$(curl -s ipv4.icanhazip.com)
DOMAIN=$(cat /etc/xray/config/domain.conf)
OS_NAME=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
OS_KERNEL=$(uname -r)
CPU_INFO=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
RAM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
RAM_USED=$(free -m | grep Mem | awk '{print $3}')
RAM_FREE=$(free -m | grep Mem | awk '{print $4}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}')
UPTIME=$(uptime -p | cut -d " " -f 2-)

# Display Information
echo -e "IP VPS        : $IPVPS"
echo -e "Domain        : $DOMAIN"
echo -e "OS Name       : $OS_NAME"
echo -e "Kernel        : $OS_KERNEL"
echo -e "CPU Info      : $CPU_INFO"
echo -e "CPU Usage     : $CPU_USAGE"
echo -e "RAM Total     : ${RAM_TOTAL}MB"
echo -e "RAM Used      : ${RAM_USED}MB"
echo -e "RAM Free      : ${RAM_FREE}MB"
echo -e "Disk Total    : $DISK_TOTAL"
echo -e "Disk Used     : $DISK_USED"
echo -e "Disk Free     : $DISK_FREE"
echo -e "Uptime        : $UPTIME"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"