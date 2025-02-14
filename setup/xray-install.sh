#!/bin/bash
# XRAY Installation Script
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

# Function to print status
print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

# Function to check installation success
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] $1${NC}"
    else
        echo -e "${RED}[✗] $1${NC}"
        exit 1
    fi
}

print_status "Starting XRAY installation..."

# Create directories
mkdir -p /etc/xray/{config,cert,logs}
mkdir -p /usr/local/etc/xray

# Download XRAY core
print_status "Downloading XRAY core..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
check_success "XRAY core installation"

# Configure XRAY
print_status "Configuring XRAY..."
cat > /etc/xray/config/config.json << EOF
{
    "log": {
        "access": "/etc/xray/logs/access.log",
        "error": "/etc/xray/logs/error.log",
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/cert/xray.crt",
                            "keyFile": "/etc/xray/cert/xray.key"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
check_success "XRAY configuration"

# Configure systemd service
print_status "Configuring XRAY service..."
cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=XRAY Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
check_success "XRAY service configuration"

# Enable and start service
print_status "Starting XRAY service..."
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
check_success "XRAY service started"

# Final check
if systemctl is-active --quiet xray; then
    echo -e "${GREEN}[✓] XRAY installation completed successfully${NC}"
else
    echo -e "${RED}[✗] XRAY installation failed${NC}"
    exit 1
fi