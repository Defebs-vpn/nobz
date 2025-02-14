#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:27:16 UTC
# // XRAY Installation Script

# Warna
RED="\033[31m"
NC="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
CYAN="\033[36m"
LIGHT="\033[37m"

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Check OS
if [[ -e /etc/debian_version ]]; then
    source /etc/os-release
    OS=$ID
elif [[ -e /etc/centos-release ]]; then
    source /etc/os-release
    OS=$ID
else
    echo -e "${RED}Unsupported OS${NC}"
    exit 1
fi

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m          ⇱ XRAY INSTALLER ⇲             \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Update and upgrade system
echo -e "Updating system..."
apt update
apt upgrade -y

# Install required packages
echo -e "Installing required packages..."
apt install -y curl wget unzip zip tar jq python3 python3-pip nginx certbot uuid-runtime

# Create directories
echo -e "Creating directories..."
mkdir -p /etc/xray
mkdir -p /var/log/xray
mkdir -p /etc/xray/config
mkdir -p /etc/xray/cert
mkdir -p /etc/xray/utils/backup
mkdir -p /etc/xray/utils/cron
mkdir -p /etc/xray/utils/monitoring
mkdir -p /etc/xray/ssh/websocket
mkdir -p /etc/xray/ssh/config
mkdir -p /etc/xray/ssh/services
mkdir -p /etc/xray/ssh/log

# Install XRAY
echo -e "Installing XRAY..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Install BBR
echo -e "Installing BBR..."
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# Install acme.sh
echo -e "Installing acme.sh..."
curl https://get.acme.sh | sh
mkdir -p /root/.acme.sh

# Install WebSocket
echo -e "Installing WebSocket..."
pip3 install websocket-client

# Configure NGINX
echo -e "Configuring NGINX..."
rm -f /etc/nginx/conf.d/*
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/*

cat > /etc/nginx/nginx.conf << END
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    client_max_body_size 32M;
    
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
END

# Configure Dropbear
echo -e "Installing and configuring Dropbear..."
apt install -y dropbear
rm -f /etc/default/dropbear
cat > /etc/default/dropbear << END
# Dropbear Configuration
NO_START=0
DROPBEAR_PORT=80
DROPBEAR_EXTRA_ARGS="-p 2052"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
END

# Configure Stunnel
echo -e "Installing and configuring Stunnel..."
apt install -y stunnel4
cat > /etc/stunnel/stunnel.conf << END
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:80

[openssh]
accept = 442
connect = 127.0.0.1:22
END

# Generate SSL Certificate for Stunnel
openssl genrsa -out /etc/stunnel/stunnel.key 2048
openssl req -new -x509 -key /etc/stunnel/stunnel.key -out /etc/stunnel/stunnel.crt -days 1095 \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Defebs-vpn/OU=Defebs-vpn/CN=Defebs-vpn"
cat /etc/stunnel/stunnel.key /etc/stunnel/stunnel.crt > /etc/stunnel/stunnel.pem

# Copy configuration files
echo -e "Copying configuration files..."
cp -r xray/* /etc/xray/
cp -r ssh/* /etc/xray/ssh/

# Set permissions
echo -e "Setting permissions..."
chmod +x /etc/xray/ssh/websocket/*.py
chmod +x /etc/xray/ssh/websocket/*.sh
chmod +x /etc/xray/ssh/config/*.sh
chmod +x /etc/xray/ssh/services/*.sh
chmod +x /etc/xray/ssh/log/*.sh
chmod +x /etc/xray/utils/backup/*.sh
chmod +x /etc/xray/utils/cron/*.sh
chmod +x /etc/xray/utils/monitoring/*.sh

# Start services
echo -e "Starting services..."
systemctl restart nginx
systemctl restart xray
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart ssh

# Enable services
echo -e "Enabling services..."
systemctl enable nginx
systemctl enable xray
systemctl enable dropbear
systemctl enable stunnel4
systemctl enable ssh

# Final cleanup
echo -e "Performing final cleanup..."
apt autoremove -y
apt clean

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m       ⇱ INSTALLATION COMPLETED ⇲         \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "XRAY Version: $(xray -version | head -n1)"
echo -e "Created by: Defebs-vpn"
echo -e "Created at: 2025-02-14 04:27:16 UTC"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Installation log saved to /var/log/xray/install.log"
echo -e "Please reboot your system!"