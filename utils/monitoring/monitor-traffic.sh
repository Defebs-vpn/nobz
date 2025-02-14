#!/bin/bash
# Traffic Monitoring Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:58:25 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;36m"
NC="\033[0m"

LOG_FILE="/var/log/traffic.log"

print_header() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           TRAFFIC MONITORING            "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Date: $(date '+%Y-%m-%d %H:%M:%S UTC')"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

monitor_connections() {
    print_header
    
    echo -e "\nActive Connections:\n"
    echo -e "PROTO   LOCAL ADDRESS         FOREIGN ADDRESS       STATE"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Display active connections
    netstat -tuln | grep LISTEN | awk '{printf "%-8s %-20s %-20s %s\n", $1, $4, $5, $6}'
    
    echo -e "\nConnection Count by State:\n"
    netstat -an | awk '{print $6}' | sort | uniq -c | sort -rn
}

monitor_services() {
    print_header
    
    echo -e "\nService Traffic Statistics:\n"
    echo -e "SERVICE         CONNECTIONS"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Monitor specific services
    services=("ssh:22" "dropbear:143" "stunnel:443" "xray:8080" "squid:3128")
    
    for service in "${services[@]}"; do
        name="${service%%:*}"
        port="${service#*:}"
        count=$(netstat -an | grep ":${port}" | wc -l)
        printf "%-14s %-d\n" "${name}" "${count}"
    done
}

log_traffic() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S UTC')
    
    # Count connections per service
    ssh_count=$(netstat -an | grep ":22" | wc -l)
    dropbear_count=$(netstat -an | grep ":143" | wc -l)
    stunnel_count=$(netstat -an | grep ":443" | wc -l)
    xray_count=$(netstat -an | grep ":8080" | wc -l)
    squid_count=$(netstat -an | grep ":3128" | wc -l)
    
    echo "${timestamp} SSH:${ssh_count} DB:${dropbear_count} SSL:${stunnel_count} XRAY:${xray_count} SQUID:${squid_count}" >> ${LOG_FILE}
}

show_stats() {
    print_header
    
    echo -e "\nTraffic Statistics (Last 24 Hours):\n"
    echo -e "HOUR            SSH    DB     SSL    XRAY   SQUID"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Process last 24 hours from log
    awk -F'[ :]' '{
        hour=substr($2,1,2);
        ssh[$1 " " hour]+=$4;
        db[$1 " " hour]+=$6;
        ssl[$1 " " hour]+=$8;
        xray[$1 " " hour]+=$10;
        squid[$1 " " hour]+=$12
    } END {
        for (h in ssh) {
            printf "%-15s %-6d %-6d %-6d %-6d %-6d\n", 
            h, ssh[h], db[h], ssl[h], xray[h], squid[h]
        }
    }' ${LOG_FILE} | sort -r | head -n 24
}

case "$1" in
    "connections")
        monitor_connections
        ;;
    "services")
        monitor_services
        ;;
    "log")
        log_traffic
        ;;
    "stats")
        show_stats
        ;;
    *)
        echo "Usage: $0 {connections|services|log|stats}"
        exit 1
        ;;
esac