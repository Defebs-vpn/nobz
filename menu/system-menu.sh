#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:12:04 UTC
# // System Menu Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

# System menu function
show_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m           ⇱ SYSTEM MENU ⇲             \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "1. System Information"
    echo -e "2. Resource Monitor"
    echo -e "3. Network Monitor"
    echo -e "4. Service Status"
    echo -e "5. Port Scanner"
    echo -e "6. Speedtest"
    echo -e "7. Backup/Restore"
    echo -e "8. Back to Main Menu"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Select menu: " menu_option
    
    case $menu_option in
        1) system_info ;;
        2) resource_monitor ;;
        3) network_monitor ;;
        4) service_status ;;
        5) port_scanner ;;
        6) speedtest ;;
        7) backup_restore ;;
        8) return ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}

# Function implementations
system_info() {
    echo -e "\nSystem Information:"
    echo -e "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
    echo -e "Kernel: $(uname -r)"
    echo -e "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)"
    echo -e "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo -e "Disk: $(df -h / | awk 'NR==2 {print $2}')"
}

resource_monitor() {
    echo -e "\nResource Usage:"
    echo -e "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
    echo -e "Memory Usage: $(free | awk '/Mem/{printf("%.2f%"), $3/$2*100}')"
    echo -e "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"
}

network_monitor() {
    echo -e "\nNetwork Statistics:"
    echo -e "Current Connections: $(netstat -an | grep ESTABLISHED | wc -l)"
    echo -e "Network Interface:"
    ip addr show
}

service_status() {
    echo -e "\nService Status:"
    systemctl status xray --no-pager
    systemctl status ssh --no-pager
    systemctl status dropbear --no-pager
    systemctl status stunnel4 --no-pager
}

port_scanner() {
    echo -e "\nScanning ports..."
    netstat -tulpn
}

speedtest() {
    echo -e "\nRunning speedtest..."
    # Add implementation here
}

backup_restore() {
    echo -e "\nBackup/Restore Menu:"
    echo -e "1. Create Backup"
    echo -e "2. Restore Backup"
    read -p "Select option: " backup_option
    
    case $backup_option in
        1) # Add backup implementation here
           ;;
        2) # Add restore implementation here
           ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}

# Run menu
while true; do
    show_menu
    read -p "Press enter to continue"
done