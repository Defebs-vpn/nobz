#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-13 17:41:44 UTC
# // Add SSH & XRAY User Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

# Import Config
source /etc/xray/config/variables.conf
source /etc/xray/config/authentication.conf

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m         ⇱ Add SSH & XRAY User ⇲        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# User Input
read -p "Username : " username
read -p "Password : " password
read -p "Expired (Days): " expired

# Check if username exists
if grep -w -q "^$username:" /etc/passwd; then
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m         ⇱ Add SSH & XRAY User ⇲        \E[0m"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "${RED}Username already exists!${NC}"
    exit 1
fi

# Calculate expiry date
exp=$(date -d "+${expired} days" +"%Y-%m-%d")

# Add SSH User
useradd -e $(date -d "${expired} days" +"%Y-%m-%d") -s /bin/false -M $username
echo -e "$password\n$password\n" | passwd $username &> /dev/null

# Add XRAY User
cat >> /etc/xray/config/xray-core.json << END
{
    "id": "$(uuid)",
    "email": "${username}@nobz.com",
    "flow": "xtls-rprx-direct"
}
END

# Add to user database
echo "${username}:${password}:${exp}" >> /etc/xray/config/user.db

# Create client config
mkdir -p /etc/xray/config/user/${username}
cat > /etc/xray/config/user/${username}/config.json << END
{
    "user": "${username}",
    "password": "${password}",
    "created": "$(date +%Y-%m-%d)",
    "expired": "${exp}"
}
END

# Log creation
echo "$(date +%Y-%m-%d' '%H:%M:%S) - Created user ${username}" >> /etc/xray/logs/created-user.log

# Show Success Message
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m         ⇱ Add SSH & XRAY User ⇲        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username : ${GREEN}$username${NC}"
echo -e "Password : ${GREEN}$password${NC}"
echo -e "Expired  : ${GREEN}$exp${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"