#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:12:04 UTC
# // Main Menu Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

# Main menu function
show_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m            ⇱ MAIN MENU ⇲               \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "1. XRAY Menu"
    echo -e "2. SSH Menu"
    echo -e "3. System Menu"
    echo -e "4. Settings Menu"
    echo -e "5. Exit"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Select menu: " menu_option
    
    case $menu_option in
        1) /etc/xray/menu/xray-menu.sh ;;
        2) /etc/xray/menu/ssh-menu.sh ;;
        3) /etc/xray/menu/system-menu.sh ;;
        4) /etc/xray/menu/settings-menu.sh ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}

# Run menu
while true; do
    show_menu
    read -p "Press enter to continue"
done