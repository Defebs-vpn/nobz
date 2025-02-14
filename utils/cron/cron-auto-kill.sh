#!/bin/bash
# Multi-Login Auto Kill Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:54:23 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Log file
LOG_FILE="/var/log/cron-auto-kill.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] $1" >> ${LOG_FILE}
}

# Maximum allowed sessions per user
MAX_SESSIONS=2

log_message "Starting multi-login check"

# Check SSH sessions
data=( $(ps aux | grep -i ssh | grep -i priv | awk '{print $2}') )
for PID in "${data[@]}"; do
    NUM=`cat /var/log/auth.log | grep -i ssh | grep -i "Accepted password" | grep "sshd\[$PID\]" | wc -l`
    USER=`cat /var/log/auth.log | grep -i ssh | grep -i "Accepted password" | grep "sshd\[$PID\]" | awk '{print $9}'`
    
    if [ $NUM -gt $MAX_SESSIONS ]; then
        kill $PID
        log_message "Killed excessive SSH sessions for user: $USER (PID: $PID)"
    fi
done

# Check Dropbear sessions
data=( $(ps aux | grep -i dropbear | grep -i -v "grep" | awk '{print $2}') )
for PID in "${data[@]}"; do
    NUM=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l`
    USER=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}'`
    
    if [ $NUM -gt $MAX_SESSIONS ]; then
        kill $PID
        log_message "Killed excessive Dropbear sessions for user: $USER (PID: $PID)"
    fi
done

log_message "Multi-login check completed"