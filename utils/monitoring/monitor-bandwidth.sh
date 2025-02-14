#!/bin/bash
# Bandwidth Monitoring Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:58:25 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;36m"
NC="\033[0m"

# Interface to monitor
IFACE="eth0"
LOG_FILE="/var/log/bandwidth.log"

print_header() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "          BANDWIDTH MONITORING           "
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Interface: $IFACE"
    echo -e " Date: $(date '+%Y-%m-%d %H:%M:%S UTC')"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_bandwidth() {
    # Get RX/TX bytes
    RX_BYTES=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
    TX_BYTES=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
    
    # Convert to MB
    RX_MB=$(echo "scale=2; $RX_BYTES/1024/1024" | bc)
    TX_MB=$(echo "scale=2; $TX_BYTES/1024/1024" | bc)
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] RX: ${RX_MB} MB, TX: ${TX_MB} MB" >> ${LOG_FILE}
}

monitor_realtime() {
    print_header
    
    echo -e "\nRealtime Bandwidth Monitor (Press CTRL+C to exit)\n"
    echo -e "TIME            RX (KB/s)    TX (KB/s)"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    OLD_RX=0
    OLD_TX=0
    
    while true; do
        RX_BYTES=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
        TX_BYTES=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
        
        # Calculate speed
        RX_SPEED=$((($RX_BYTES - $OLD_RX) / 1024))
        TX_SPEED=$((($TX_BYTES - $OLD_TX) / 1024))
        
        # Update old values
        OLD_RX=$RX_BYTES
        OLD_TX=$TX_BYTES
        
        # Print current speed
        printf "%s    %-10s   %-10s\n" "$(date +%H:%M:%S)" "${RX_SPEED}" "${TX_SPEED}"
        
        sleep 1
    done
}

show_daily_stats() {
    print_header
    
    echo -e "\nDaily Bandwidth Statistics\n"
    echo -e "DATE            DOWNLOAD      UPLOAD"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Process log file for daily stats
    awk '{
        split($1,date,"-");
        rx[$1]+=$5;
        tx[$1]+=$8
    } END {
        for (d in rx) {
            printf "%s    %.2f GB     %.2f GB\n", d, rx[d]/1024, tx[d]/1024
        }
    }' ${LOG_FILE} | sort -r | head -n 7
}

case "$1" in
    "realtime")
        monitor_realtime
        ;;
    "log")
        log_bandwidth
        ;;
    "stats")
        show_daily_stats
        ;;
    *)
        echo "Usage: $0 {realtime|log|stats}"
        exit 1
        ;;
esac