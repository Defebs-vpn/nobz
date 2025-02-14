#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:50:01 UTC
# // Service Restart Script

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
echo -e "\E[44;1;39m          ⇱ Restart Services ⇲           \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# List of services
echo -e "[ 1 ] Restart All Services"
echo -e "[ 2 ] Restart XRAY"
echo -e "[ 3 ] Restart SSH"
echo -e "[ 4 ] Restart Dropbear"
echo -e "[ 5 ] Restart Stunnel4"
echo -e "[ 6 ] Restart OpenVPN"
echo -e "[ 7 ] Restart Squid"
echo -e "[ 8 ] Restart Nginx"
echo -e "[ 9 ] Back to Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Select From Options [ 1-9 ] : " RestartService

case $RestartService in
    1) # Restart All
        echo -e "\nRestarting All Services..."
        systemctl restart xray
        systemctl restart ssh
        systemctl restart dropbear
        systemctl restart stunnel4
        systemctl restart openvpn
        systemctl restart squid
        systemctl restart nginx
        ;;
    2) systemctl restart xray ;;
    3) systemctl restart ssh ;;
    4) systemctl restart dropbear ;;
    5) systemctl restart stunnel4 ;;
    6) systemctl restart openvpn ;;
    7) systemctl restart squid ;;
    8) systemctl restart nginx ;;
    9) menu ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        exit 1
        ;;
esac

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Service restart completed!"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"