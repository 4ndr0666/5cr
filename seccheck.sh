#!/bin/bash

# Security check script for Arch Linux machines
# Version: 1.1

# Variables
output_file="seccheck_$(date +%Y-%m-%d_%H-%M-%S).log"

# Functions
function header() {
  echo -e "\n[+] $1" | tee -a "${output_file}"
}

function check_package() {
  if pacman -Qs "$1" > /dev/null; then
    echo -e " [+] $1 is installed" | tee -a "${output_file}"
  else
    echo -e " [-] $1 is not installed" | tee -a "${output_file}"
  fi
}

function check_service() {
  if systemctl is-active "$1" > /dev/null; then
    echo -e " [+] $1 is active" | tee -a "${output_file}"
  else
    echo -e " [-] $1 is not active" | tee -a "${output_file}"
  fi
}

function check_socket() {
  if systemctl is-active "$1.socket" > /dev/null; then
    echo -e " [+] $1 socket is active" | tee -a "${output_file}"
  else
    echo -e " [-] $1 socket is not active" | tee -a "${output_file}"
  fi
}

function check_port() {
  if ss -tunlp | grep -qw "$1"; then
    echo -e " [+] Port $1 is open" | tee -a "${output_file}"
  else
    echo -e " [-] Port $1 is not open" | tee -a "${output_file}"
  fi
}

function check_user() {
  if getent passwd "$1" > /dev/null; then
    echo -e " [+] User $1 exists" | tee -a "${output_file}"
  else
    echo -e " [-] User $1 does not exist" | tee -a "${output_file}"
  fi
}

# Begin security check
header "System Information"
echo -e "System: $(uname -a)" | tee -a "${output_file}"
echo -e "Kernel: $(uname -r)" | tee -a "${output_file}"
echo -e "OS: $(lsb_release -d | awk -F ":" '{print $2}' | xargs)" | tee -a "${output_file}"
echo -e "Architecture: $(arch)" | tee -a "${output_file}"
echo -e "Uptime: $(uptime -p)" | tee -a "${output_file}"
echo -e "Date: $(date)" | tee -a "${output_file}"

header "Installed Packages"
pacman -Q | tee -a "${output_file}"

header "Security Package Checks"
security_packages=("apparmor" "audit" "firejail" "rkhunter" "selinux")
for package in "${security_packages[@]}"; do
  check_package "${package}"
done

header "Services Checks"
services=("sshd" "nginx" "apache" "mysql" "postgresql" "samba" "vsftpd")
for service in "${services[@]}"; do
  check_service "${service}"
  check_socket "${service}"
done

header "Port Checks"
ports=("21" "22" "25" "80" "110" "143" "443" "465" "587" "993" "995" "3306" "5432" "8080")
for port in "${ports[@]}"; do
  check_port "${port}"
done

header "User Checks"
users=("root" "admin" "guest")
for user in "${users[@]}"; do
  check_user "${user}"
done

header "File Permission Checks"
file_permissions=(
  "/etc/passwd"
  "/etc/shadow"
  "/etc/group"
  "/etc/gshadow"
  "/etc/sudoers"
  "/etc/ssh/sshd_config"
)
for file in "${file_permissions[@]}"; do
  echo -e "[$(stat -c '%a' "${file}")] $file" | tee -a "${output_file}"
done

header "SUID and SGID Checks"
find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \; 2>/dev/null | tee -a "${output_file}"

header "Listening Services and Open Ports"
ss -tunlp | tee -a "${output_file}"

header "Logged in Users"
who | tee -a "${output_file}"

header "Last Logins"
lastlog | tee -a "${output_file}"

header "Failed Login Attempts"
journalctl -a --no-pager --since "1 week ago" _SYSTEMD_UNIT=systemd-logind.service | grep -i "failed to authenticate" | tee -a "${output_file}"

header "Active Processes"
ps aux | tee -a "${output_file}"

header "Cron Jobs"
echo -e "System-wide cron jobs:" | tee -a "${output_file}"
ls -l /etc/cron.d | tee -a "${output_file}"
echo -e "\nUser-specific cron jobs:" | tee -a "${output_file}"
for user in $(getent passwd | awk -F: '{print $1}'); do
  echo -e "\nCron jobs for $user:" | tee -a "${output_file}"
  crontab -l -u "${user}" 2>/dev/null | tee -a "${output_file}"
done

echo -e "\n[+] Security check completed. Output saved to ${output_file}"
