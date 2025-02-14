#!/bin/bash
# WebSocket Installation Script
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
apt install -y python3 python3-pip
check_success "Package installation"

# Install Python WebSocket library
print_status "Installing Python WebSocket library..."
pip3 install websockets
check_success "WebSocket library installation"

# Create WebSocket scripts
print_status "Creating WebSocket scripts..."

# Create Dropbear WebSocket
cat > /usr/local/bin/ws-dropbear << EOF
#!/usr/bin/python3
import asyncio
import websockets
import socket
import sys

async def handle_connection(websocket, path):
    try:
        dropbear = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        dropbear.connect(('127.0.0.1', 109))
        
        async def forward_ws_to_tcp():
            while True:
                data = await websocket.recv()
                dropbear.send(data)
                
        async def forward_tcp_to_ws():
            while True:
                data = dropbear.recv(4096)
                if not data:
                    break
                await websocket.send(data)
                
        await asyncio.gather(
            forward_ws_to_tcp(),
            forward_tcp_to_ws()
        )
    except:
        pass
    finally:
        dropbear.close()

port = int(sys.argv[1]) if len(sys.argv) > 1 else 2082
start_server = websockets.serve(handle_connection, '0.0.0.0', port)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
EOF

# Create Stunnel WebSocket
cat > /usr/local/bin/ws-stunnel << EOF
#!/usr/bin/python3
import asyncio
import websockets
import socket
import sys

async def handle_connection(websocket, path):
    try:
        stunnel = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        stunnel.connect(('127.0.0.1', 443))
        
        async def forward_ws_to_tcp():
            while True:
                data = await websocket.recv()
                stunnel.send(data)
                
        async def forward_tcp_to_ws():
            while True:
                data = stunnel.recv(4096)
                if not data:
                    break
                await websocket.send(data)
                
        await asyncio.gather(
            forward_ws_to_tcp(),
            forward_tcp_to_ws()
        )
    except:
        pass
    finally:
        stunnel.close()

port = int(sys.argv[1]) if len(sys.argv) > 1 else 2083
start_server = websockets.serve(handle_connection, '0.0.0.0', port)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
EOF

# Create OpenVPN WebSocket
cat > /usr/local/bin/ws-ovpn << EOF
#!/usr/bin/python3
import asyncio
import websockets
import socket
import sys

async def handle_connection(websocket, path):
    try:
        ovpn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ovpn.connect(('127.0.0.1', 1194))
        
        async def forward_ws_to_tcp():
            while True:
                data = await websocket.recv()
                ovpn.send(data)
                
        async def forward_tcp_to_ws():
            while True:
                data = ovpn.recv(4096)
                if not data:
                    break
                await websocket.send(data)
                
        await asyncio.gather(
            forward_ws_to_tcp(),
            forward_tcp_to_ws()
        )
    except:
        pass
    finally:
        ovpn.close()

port = int(sys.argv[1]) if len(sys.argv) > 1 else 2084
start_server = websockets.serve(handle_connection, '0.0.0.0', port)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
EOF

chmod +x /usr/local/bin/ws-*
check_success "WebSocket scripts creation"

# Create systemd services
print_status "Creating systemd services..."

# Dropbear WebSocket Service
cat > /etc/systemd/system/ws-dropbear.service << EOF
[Unit]
Description=Dropbear WebSocket Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/ws-dropbear 2082
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

# Stunnel WebSocket Service
cat > /etc/systemd/system/ws-stunnel.service << EOF
[Unit]
Description=Stunnel WebSocket Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/ws-stunnel 2083
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

# OpenVPN WebSocket Service
cat > /etc/systemd/system/ws-ovpn.service << EOF
[Unit]
Description=OpenVPN WebSocket Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/ws-ovpn 2084
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

check_success "Service creation"

# Start and enable services
print_status "Starting WebSocket services..."
systemctl daemon-reload
systemctl enable ws-dropbear ws-stunnel ws-ovpn
systemctl start ws-dropbear ws-stunnel ws-ovpn
check_success "Services started"

echo -e "${GREEN}[✓] WebSocket installation completed successfully${NC}"