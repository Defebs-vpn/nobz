#!/bin/bash
# SSH Services Installation Script
# Created by: Defebs-vpn
# Created at: 2025-02-14 10:35:26 UTC

# Set terminal colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

# Check root privileges
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] $1${NC}"
    else
        echo -e "${RED}[✗] $1${NC}"
        exit 1
    fi
}

# Install required packages
print_status "Installing required packages..."
apt update
apt install -y openssh-server dropbear stunnel4 squid
check_success "Package installation"

# Configure OpenSSH
print_status "Configuring OpenSSH..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat > /etc/ssh/sshd_config << EOF
Port 22
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxAuthTries 3
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
check_success "OpenSSH configuration"

# Configure Dropbear
print_status "Configuring Dropbear..."
cat > /etc/default/dropbear << EOF
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
check_success "Dropbear configuration"

# Configure Stunnel
print_status "Configuring Stunnel..."
cat > /etc/stunnel/stunnel.conf << EOF
pid = /var/run/stunnel.pid
cert = /etc/xray/cert/xray.crt
key = /etc/xray/cert/xray.key
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:22
EOF
check_success "Stunnel configuration"

# Configure Squid
print_status "Configuring Squid..."
cat > /etc/squid/squid.conf << EOF
http_port 8080
http_port 3128
visible_hostname Defebs-vpn
acl localhost src 127.0.0.1/32
http_access allow localhost
http_access deny all
EOF
check_success "Squid configuration"

# Restart services
print_status "Restarting services..."
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart squid
check_success "Services restart"

# Enable services
print_status "Enabling services..."
systemctl enable ssh
systemctl enable dropbear
systemctl enable stunnel4
systemctl enable squid
check_success "Services enabled"

echo -e "${GREEN}[✓] SSH services installation completed successfully${NC}"