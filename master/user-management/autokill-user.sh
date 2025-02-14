#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:45:25 UTC
# // Auto Kill Multi Login Script

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
echo -e "\E[44;1;39m          ⇱ AutoKill Settings ⇲          \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

echo "1. AutoKill After 5 Minutes"
echo "2. AutoKill After 10 Minutes"
echo "3. AutoKill After 15 Minutes"
echo "4. Turn Off AutoKill"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Select Option [1-4]: " AutoKill

case $AutoKill in
    1)
        echo "*/5 * * * * root /usr/bin/kill-by-multilogin" > /etc/cron.d/autokill
        ;;
    2)
        echo "*/10 * * * * root /usr/bin/kill-by-multilogin" > /etc/cron.d/autokill
        ;;
    3)
        echo "*/15 * * * * root /usr/bin/kill-by-multilogin" > /etc/cron.d/autokill
        ;;
    4)
        rm -f /etc/cron.d/autokill
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        exit 1
        ;;
esac

service cron restart

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
if [ $AutoKill -eq 4 ]; then
    echo -e "AutoKill Multi Login ${RED}Turned Off${NC}"
else
    echo -e "AutoKill Multi Login ${GREEN}Activated${NC}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"