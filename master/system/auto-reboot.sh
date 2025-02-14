#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:53:22 UTC
# // Auto Reboot Schedule Script

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
echo -e "\E[44;1;39m          ⇱ Auto Reboot Setup ⇲          \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

echo -e "[ 1 ] Set Auto-Reboot Every 1 Hour"
echo -e "[ 2 ] Set Auto-Reboot Every 6 Hours"
echo -e "[ 3 ] Set Auto-Reboot Every 12 Hours"
echo -e "[ 4 ] Set Auto-Reboot Every 1 Day"
echo -e "[ 5 ] Set Auto-Reboot Every 1 Week"
echo -e "[ 6 ] Set Auto-Reboot Every 1 Month"
echo -e "[ 7 ] Disable Auto-Reboot"
echo -e "[ 8 ] Back to Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Select From Options [ 1-8 ] : " AutoReboot

case $AutoReboot in
    1)
        echo "0 * * * * root /sbin/reboot" > /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been set every 1 Hour"
        ;;
    2)
        echo "0 */6 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been set every 6 Hours"
        ;;
    3)
        echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been set every 12 Hours"
        ;;
    4)
        echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been set every 1 Day"
        ;;
    5)
        echo "0 0 * * 0 root /sbin/reboot" > /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been set every 1 Week"
        ;;
    6)
        echo "0 0 1 * * root /sbin/reboot" > /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been set every 1 Month"
        ;;
    7)
        rm -f /etc/cron.d/auto-reboot
        echo -e "Auto-Reboot has been disabled"
        ;;
    8)
        menu
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        exit 1
        ;;
esac

# Restart cron service
systemctl restart cron

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"