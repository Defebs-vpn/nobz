#!/bin/bash
# // Script Creator: Defebs-vpn
# // Created Date: 2025-02-14 09:07:10 UTC
# // XRAY Installation Script

# Import colors
source <(curl -s https://raw.githubusercontent.com/Defebs-vpn/nobz/main/master/config/colors.conf)

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m          ⇱ XRAY INSTALLER ⇲             \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Create main directories
mkdir -p /etc/nobz/{master,xray,ssh,setup,menu,utils}

# Create master subdirectories
mkdir -p /etc/nobz/master/{user-management,system,database,config,logs}

# Create xray subdirectories
mkdir -p /etc/nobz/xray/{config,cert,services,log}

# Create ssh subdirectories
mkdir -p /etc/nobz/ssh/{websocket,config,services,log}

# Create utils subdirectories
mkdir -p /etc/nobz/utils/{backup,cron,monitoring}

# Download setup scripts
cd /etc/nobz/setup
echo -e "[ ${GREEN}INFO${NC} ] Downloading setup scripts..."
for script in dependencies.sh xray-install.sh ssh-install.sh websocket-install.sh ssl-install.sh badvpn-install.sh backup-install.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/setup/${script}"
    chmod +x ${script}
done

# Execute setup scripts in order
./dependencies.sh
./xray-install.sh
./ssh-install.sh
./websocket-install.sh
./ssl-install.sh
./badvpn-install.sh
./backup-install.sh

# Download master scripts
echo -e "[ ${GREEN}INFO${NC} ] Downloading master scripts..."

# User Management
cd /etc/nobz/master/user-management
for script in add-user.sh delete-user.sh renew-user.sh list-user.sh check-user.sh limit-user.sh banned-user.sh autokill-user.sh user-lock.sh user-unlock.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/master/user-management/${script}"
    chmod +x ${script}
done

# System
cd /etc/nobz/master/system
for script in system-info.sh ram-usage.sh cpu-usage.sh bandwidth-monitor.sh speedtest.sh restart-service.sh clear-log.sh auto-reboot.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/master/system/${script}"
    chmod +x ${script}
done

# Download configurations
cd /etc/nobz/master/config
for conf in version.conf variables.conf requirements.txt domain.conf permission.conf ports.conf banner.conf service-names.conf colors.conf authentication.conf; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/master/config/${conf}"
done

# Create database files
cd /etc/nobz/master/database
for db in user.db expired.db banned.db ip-banned.db traffic.db; do
    touch ${db}
done

# Create log files
cd /etc/nobz/master/logs
for log in access.log error.log login.log created-user.log expired-user.log banned-user.log; do
    touch ${log}
done

# Download XRAY configurations
cd /etc/nobz/xray/config
for conf in xray-core.json vmess.json vless.json trojan.json shadowsocks.json; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/xray/config/${conf}"
done

# Download SSH configurations
cd /etc/nobz/ssh/config
for conf in ssh.conf sshd_config dropbear.conf stunnel.conf squid.conf; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/ssh/config/${conf}"
done

# Download WebSocket services
cd /etc/nobz/ssh/websocket
for service in ws-openssh.service ws-dropbear.service ws-stunnel.service ws-ovpn.service; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/ssh/websocket/${service}"
done

# Download menu scripts
cd /etc/nobz/menu
for menu in menu.sh xray-menu.sh ssh-menu.sh user-menu.sh system-menu.sh backup-menu.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/menu/${menu}"
    chmod +x ${menu}
done

# Download utility scripts
# Backup
cd /etc/nobz/utils/backup
for script in backup.sh restore.sh auto-backup.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/utils/backup/${script}"
    chmod +x ${script}
done

# Cron
cd /etc/nobz/utils/cron
for script in cron-user-expire.sh cron-auto-kill.sh cron-auto-reboot.sh cron-backup.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/utils/cron/${script}"
    chmod +x ${script}
done

# Monitoring
cd /etc/nobz/utils/monitoring
for script in monitor-bandwidth.sh monitor-traffic.sh monitor-login.sh; do
    wget -q "https://raw.githubusercontent.com/Defebs-vpn/nobz/main/utils/monitoring/${script}"
    chmod +x ${script}
done

# Create symlinks to /usr/bin
cd /usr/bin
ln -sf /etc/nobz/menu/menu.sh menu
ln -sf /etc/nobz/menu/xray-menu.sh xray-menu
ln -sf /etc/nobz/menu/ssh-menu.sh ssh-menu
ln -sf /etc/nobz/menu/user-menu.sh user-menu
ln -sf /etc/nobz/menu/system-menu.sh system-menu
ln -sf /etc/nobz/menu/backup-menu.sh backup-menu

# Setup menu autostart
cat > /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
menu
END

# Clean up
apt autoremove -y
apt clean

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m       ⇱ INSTALLATION COMPLETED ⇲         \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e "Installation Details:"
echo -e "• Created By : Defebs-vpn"
echo -e "• Created At : 2025-02-14 09:07:10 UTC"
echo -e ""
echo -e "Your VPS will reboot in 5 seconds"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
sleep 5
reboot
