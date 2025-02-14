#!/bin/bash
# Login Monitoring Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:58:25 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;36m"
NC="\033[0m"

LOG_FILE="/var/log/user-login.log"

print_header() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "            LOGIN MONITORING             "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Date: $(date '+%Y-%m-%d %H:%M:%S UTC')"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

monitor_active_users() {
    print_header
    
    echo -e "\nActive User Sessions:\n"
    echo -e "USERNAME        IP ADDRESS       LOGIN TIME     SERVICE"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Monitor SSH sessions
    who | awk '{printf "%-14s %-15s %-13s SSH\n", $1, $5, $3" "$4}'
    
    # Monitor Dropbear sessions
    ps aux | grep -i dropbear | grep -i -v grep | awk '{print $1}' | \
    while read user; do
        if [ -n "$user" ]; then
            ip=$(netstat -tunp | grep dropbear | grep -i established | awk '{print $5}' | cut -d: -f1)
            printf "%-14s %-15s %-13s Dropbear\n" "$user" "$ip" "$(date +%H:%M)"
        fi
    done
}

log_login_event() {
    local user="$1"
    local ip="$2"
    local service="$3"
    local event="$4"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] $event - User: $user, IP: $ip, Service: $service" >> ${LOG_FILE}
}

monitor_auth_log() {
    print_header
    
    echo -e "\nRecent Login Events:\n"
    echo -e "TIME            USER            IP              EVENT"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Monitor authentication log
    tail -n 50 /var/log/auth.log | grep -i "ssh\|dropbear" | grep -i "accepted\|failed" | \
    while read line; do
        if echo "$line" | grep -qi "accepted"; then
            event="SUCCESS"
            color=$GREEN
        else
            event="FAILED"
            color=$RED
        fi
        
        user=$(echo "$line" | awk '{print $9}')
        ip=$(echo "$line" | awk '{print $11}')
        time=$(echo "$line" | awk '{print $3}')
        
        echo -e "${color}${time}     %-14s %-15s ${event}${NC}" "$user" "$ip"
    done
}

show_login_stats() {
    print_header
    
    echo -e "\nLogin Statistics (Last 24 Hours):\n"
    echo -e "HOUR        SUCCESS     FAILED      TOTAL"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Process log for statistics
    awk -F'[][]' '{
        split($2,dt," ");
        hour=substr(dt[2],1,2);
        if ($0 ~ /SUCCESS/) success[hour]++;
        if ($0 ~ /FAILED/) failed[hour]++;
    } END {
        for (h in success) {
            printf "%s:00     %-10d %-10d %-10d\n", 
            h, success[h], failed[h], success[h]+failed[h]
        }
    }' ${LOG_FILE} | sort -r
}

case "$1" in
    "active")
        monitor_active_users
        ;;
    "auth")
        monitor_auth_log
        ;;
    "log")
        if [ $# -eq 4 ]; then
            log_login_event "$2" "$3" "$4"
        else
            echo "Usage: $0 log <user> <ip> <service> <event>"
            exit 1
        fi
        ;;
    "stats")
        show_login_stats
        ;;
    *)
        echo "Usage: $0 {active|auth|log|stats}"
        exit 1
        ;;
esac