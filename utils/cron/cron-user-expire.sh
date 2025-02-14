#!/bin/bash
# User Account Expiration Checker
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:54:23 UTC

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Log file
LOG_FILE="/var/log/cron-user-expire.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] $1" >> ${LOG_FILE}
}

# Check expired accounts
log_message "Starting user expiration check"

while read expired; do
    ACCOUNT="$(echo $expired | cut -d: -f1)"
    ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
    EXP="$(chage -l $ACCOUNT | grep "Account expires" | awk -F": " '{print $2}')"
    
    if [[ $ID -ge 1000 ]] && [[ $ID -ne 65534 ]]; then
        if [[ $(date +%s) -ge $(date -d "$EXP" +%s) ]]; then
            passwd -l $ACCOUNT > /dev/null 2>&1
            log_message "Locked expired account: $ACCOUNT (Expired: $EXP)"
        fi
    fi
done < /etc/passwd

log_message "User expiration check completed"