#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 04:04:32 UTC
# // Dependencies Installation Script

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
echo -e "\E[44;1;39m        ⇱ Installing Dependencies ⇲       \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Update package list
apt update

# Essential packages
echo -e "Installing essential packages..."
apt install -y \
    curl \
    wget \
    unzip \
    tar \
    git \
    jq \
    bc \
    netcat \
    socat \
    cron \
    net-tools \
    python \
    python3 \
    python3-pip \
    python3-cryptography \
    build-essential

# Web server
echo -e "Installing web server..."
apt install -y nginx

# SSL tools
echo -e "Installing SSL tools..."
apt install -y openssl

# SSH and tunnel
echo -e "Installing SSH and tunnel packages..."
apt install -y \
    openssh-server \
    dropbear \
    stunnel4

# Python packages
echo -e "Installing Python packages..."
pip3 install \
    requests \
    websocket-client \
    python-daemon \
    pyOpenSSL

# Cleanup
apt autoremove -y
apt clean

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Dependencies installation completed!"
echo -e "Created by: Defebs-vpn"
echo -e "Created at: 2025-02-14 04:04:32 UTC"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"