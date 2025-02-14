#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:50:01 UTC
# // CPU Usage Monitor Script

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
echo -e "\E[44;1;39m            ⇱ CPU Usage ⇲               \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Get CPU Information
cpu_info=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2)
cpu_cores=$(grep -c processor /proc/cpuinfo)
cpu_freq=$(grep "cpu MHz" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
load_average=$(uptime | awk -F'load average:' '{ print $2 }')

# Display CPU Information
echo -e "CPU Model    : $cpu_info"
echo -e "CPU Cores    : $cpu_cores"
echo -e "CPU Freq     : $cpu_freq MHz"
echo -e "CPU Usage    : $cpu_usage%"
echo -e "Load Average : $load_average"

# CPU Usage Warning
if [ $(echo "$cpu_usage > 90" | bc -l) -eq 1 ]; then
    echo -e "${RED}WARNING: CPU usage is very high!${NC}"
elif [ $(echo "$cpu_usage > 75" | bc -l) -eq 1 ]; then
    echo -e "${YELLOW}NOTICE: CPU usage is high${NC}"
fi

# Top 5 CPU-consuming processes
echo -e "\nTop 5 CPU-consuming processes:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
ps aux --sort=-%cpu | head -n 6 | awk '{print $3"% - "$11}'
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"