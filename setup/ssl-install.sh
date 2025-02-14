#!/bin/bash
# SSL Certificate Installation Script
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
apt install -y socat curl wget

# Install acme.sh
print_status "Installing acme.sh..."
curl https://get.acme.sh | sh
check_success "acme.sh installation"

# Function to request SSL certificate
get_ssl_cert() {
    local domain="$1"
    local email="$2"

    print_status "Requesting SSL certificate for ${domain}..."
    
    mkdir -p /etc/xray/cert
    
    ~/.acme.sh/acme.sh --issue -d "${domain}" --standalone \
        --key-file /etc/xray/cert/xray.key \
        --fullchain-file /etc/xray/cert/xray.crt \
        --email "${email}"
    
    check_success "SSL certificate request"

    # Set permissions
    chmod 644 /etc/xray/cert/xray.crt
    chmod 600 /etc/xray/cert/xray.key
    
    # Configure auto-renewal
    ~/.acme.sh/acme.sh --install-cert -d "${domain}" \
        --key-file /etc/xray/cert/xray.key \
        --fullchain-file /etc/xray/cert/xray.crt \
        --reloadcmd "systemctl restart xray nginx stunnel4"
}

# Main installation process
print_status "Starting SSL installation..."

# Get domain and email
read -p "Enter your domain: " domain
read -p "Enter your email: " email

# Validate domain
if [ -z "$domain" ]; then
    echo -e "${RED}Domain cannot be empty${NC}"
    exit 1
fi

# Validate email
if [ -z "$email" ]; then
    echo -e "${RED}Email cannot be empty${NC}"
    exit 1
fi

# Stop services that might use port 80
print_status "Stopping services that might interfere..."
systemctl stop nginx xray stunnel4 2>/dev/null

# Request certificate
get_ssl_cert "${domain}" "${email}"

# Create cron for renewal check
print_status "Setting up auto-renewal..."
cat > /etc/cron.d/ssl-renew << EOF
0 0 * * * root /root/.acme.sh/acme.sh --cron --home /root/.acme.sh > /dev/null
EOF
chmod 644 /etc/cron.d/ssl-renew
check_success "Auto-renewal setup"

# Restart services
print_status "Restarting services..."
systemctl restart xray nginx stunnel4 2>/dev/null
check_success "Services restart"

# Create SSL info file
cat > /etc/xray/cert/ssl-info.txt << EOF
SSL Certificate Information
-------------------------
Domain: ${domain}
Email: ${email}
Installation Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Installed by: ${USER}
Certificate Path: /etc/xray/cert/xray.crt
Private Key Path: /etc/xray/cert/xray.key
Auto-renewal: Enabled (daily check)
EOF

echo -e "${GREEN}[✓] SSL installation completed successfully${NC}"
echo -e "${GREEN}[✓] Certificate will auto-renew when needed${NC}"
echo -e "${YELLOW}[*] Certificate info saved in /etc/xray/cert/ssl-info.txt${NC}"