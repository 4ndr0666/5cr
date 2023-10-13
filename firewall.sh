#!/bin/bash

# Script Name: firewall.sh
# Description: Automatically escalates privileges and hardens the system.
# Author: github.com/4ndr0666
# Version: 1.0
# Date: 10-03-2023
# Usage: ./firewall.sh

echo -e "\033[34m"
cat << "EOF"
#  ___________.__                              .__  .__              .__     
#  \_   _____/|__|______   ______  _  _______  |  | |  |        _____|  |__  
#   |    __)  |  \_  __ \_/ __ \ \/ \/ /\__  \ |  | |  |       /  ___/  |  \ 
#   |     \   |  ||  | \/\  ___/\     /  / __ \|  |_|  |__     \___ \|   Y  \
#   \___  /   |__||__|    \___  >\/\_/  (____  /____/____/ /\ /____  >___|  /
#       \/                    \/             \/            \/      \/     \/ 
EOF
echo -e "\033[0m"

# Handle errors
handle_error() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo "Error [Exit Code: $exit_code]"
    exit $exit_code
  fi
}

# Set proper permissions on /etc and /var
permissions_config() {
  UFW_DIR="/etc/ufw/"
  LOG_DIR="/var/log/"
  if [ -d "$UFW_DIR" ] && [ -d "$LOG_DIR" ]; then
    chmod 700 "$UFW_DIR" "$LOG_DIR"
    chown root:root "$UFW_DIR" "$LOG_DIR"
    echo "Proper permission and ownership set"
  else
    echo "Couldn't correct permissions"
  fi
}
handle_error

# Ensure UFW rules exist
rules_config() {
  UFW_FILES=("/etc/ufw/user.rules" "/etc/ufw/before.rules" "/etc/ufw/after.rules" "/etc/ufw/user6.rules" "/etc/ufw/before6.rules" "/etc/ufw/after6.rules")
  for file in "${UFW_FILES[@]}"; do
    if [ ! -f "$file" ]; then
      echo "File $file does not exist. Creating with default rules."
      echo "# Default rules" > "$file"
      chmod 600 "$file"
    fi
  done
}
handle_error

# Function to configure UFW
ufw_config() {
  ufw --force reset
  handle_error
  
  ufw limit proto tcp from any to any port 22
  handle_error

  ufw allow 6341/tcp # Megasync
  handle_error

  ufw default deny incoming
  handle_error

  ufw default allow outgoing
  handle_error

  ufw default deny incoming v6
  handle_error

  ufw default allow outgoing v6
  handle_error

  ufw logging on
  handle_error

  ufw --force enable  # Activate UFW
  handle_error

  systemctl enable ufw --now
  handle_error
}

# Function to configure sysctl
sysctl_config() {
  sysctl kernel.modules_disabled=1
  handle_error
  sysctl -a
  handle_error
  sysctl -A
  handle_error
  sysctl -w net.ipv4.conf.all.accept_redirects=0
  handle_error
  sysctl -w net.ipv4.conf.all.send_redirects=0
  handle_error
  sysctl -w net.ipv4.ip_forward=0
  handle_error
  sysctl net.ipv4.conf.all.rp_filter
  handle_error
  # Prevent IP Spoofs
  echo "order bind,hosts" >> /etc/host.conf
  echo "multi on" >> /etc/host.conf
  handle_error
}

# Function to handle IPv6
ipv6_config() {
  echo "IPv6 on by default."
  echo -n "Would you like to disable it? [y/n]: "
  read -r change_ipv6

  if [ "$change_ipv6" == "y" ]; then
    echo "1. Enable IPv6"
    echo "2. Disable IPv6"
    read -r choice

    case "$choice" in
      "1")
        sysctl -w net.ipv6.conf.all.disable_ipv6=0
        sysctl -w net.ipv6.conf.default.disable_ipv6=0
        ;;
      "2")
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sysctl -w net.ipv6.conf.default.disable_ipv6=1
        ;;
      *)
        echo "Invalid choice. IPv6 will be left as-is."
        ;;
    esac
  fi
}
handle_error

# Function to configure fail2ban
fail2ban_config() {
  cp jail.local /etc/fail2ban/jail.local
  handle_error
  systemctl enable fail2ban
  handle_error
  systemctl restart fail2ban
  handle_error
}

# Main Logic
if [ "$(id -u)" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

# Initiate system hardening
echo "Initiating system hardening..."

permissions_config
handle_error

rules_config
handle_error

ufw_config
handle_error

sysctl_config
handle_error

ipv6_config
handle_error

fail2ban_config
handle_error

ssh_config
handle_error

filesystem_config
handle_error

stickybit_config
handle_error

# --- Portscan Summary
echo "### -------- // Portscan Summary // -------- ###"
netstat -tunlp

echo "### -------- // Active UFW rules // -------- ###"
ufw status numbered

exit 0
