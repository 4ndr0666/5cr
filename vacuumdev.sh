#!/usr/bin/env bash

# Automatically escalate privileges if not running as root
if [ "$(id -u)" -ne 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Initialize log file
#log_file="$HOME/.local/share/permissions/$(date +%Y%d%m_%H%M%S)_permissions.log"

# Color and formatting definitions
GREEN='\033[0;32m'
BOLD='\033[1m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Symbols for visual feedback
SUCCESS="✔️"
FAILURE="❌"
INFO="➡️"
EXPLOSION="💥"

# Function to display prominent messages
prominent() {
    echo -e "${BOLD}${GREEN}$1${NC}"
}

# Function for errors
bug() {
    echo -e "${BOLD}${RED}$1${NC}"
}

# Logging function
log() {
    echo "$(date): $1" >> /var/log/r8169_module_script.log
}

# Print ASCII art in green
#echo -e "${GREEN}"
#cat << "EOF"
#  _______          __      .___      .__                            .__     
#  \      \   _____/  |_  __| _/______|__|__  __ ___________    _____|  |__  
#  /   |   \_/ __ \   __\/ __ |\_  __ \  \  \/ // __ \_  __ \  /  ___/  |  \ 
# /    |    \  ___/|  | / /_/ | |  | \/  |\   /\  ___/|  | \/  \___ \|   Y  \
# \____|__  /\___  >__| \____ | |__|  |__| \_/  \___  >__| /\ /____  >___|  /
#         \/     \/          \/                     \/     \/      \/     \/ 
#EOF
#echo -e "${NC}"


# Function to set up cron job for deleting old logs
setup_cron_job() {
    (crontab -l 2>/dev/null; echo "0 0 * * * find $HOME/.local/share/permissions/ -name '*_permissions.log' -mtime +30 -exec rm {} \;") | crontab -
    prominent "$INFO Cron job set up to delete old logs." | log
}

FIND=$(which find)
CHMOD=$(which chmod)
AWK=$(which awk)
STAT=$(which stat)

# Check if cron job exists, if not set it up
if ! crontab -l | grep -q "find $HOME/.local/share/permissions/ -name '*_permissions.log' -mtime +30 -exec rm {} \;"; then
    prominent "$INFO Cron job for deleting old logs not found. Setting up..." | tee -a $log_file
    setup_cron_job
else
    prominent "$INFO Cron job for deleting old logs already exists." | tee -a $log_file
fi

# Function to generate the reference file
generate_reference_file() {
    prominent "Generating reference file..." | log
    reference_file="$HOME/.local/share/permissions/archcraft_permissions_reference.txt"
    prominent "Starting find command..." | log  # Debugging statement added
    timeout 60s find / -type f ! -path "/etc/skel/*" ! -path "/proc/*" ! -path "/run/*" -exec stat -c "%a %n" {} \; > $reference_file 2>>log
    if [ $? -eq 0 ]; then
        prominent "$INFO Find command completed." | log  # Debugging statement added
    else
        prominent "An error occurred during the find command" | log
    fi
    prominent "$INFO Reference file generated." | log
}

# Check if reference file exists, if not generate it
if [ ! -f "$HOME/.local/share/permissions/archcraft_permissions_reference.txt" ]; then
    prominent "$INFO Reference file not found. Generating..." | log
    generate_reference_file
else
    prominent "$INFO Reference file found." | log
fi

# Ask user if they want to regenerate the reference file
read -p "Do you want to regenerate the reference file? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    generate_reference_file
else
    prominent "$INFO Skipping reference file regeneration." | log
fi

# Function to set permissions based on the reference file
set_permissions_from_reference() {
    prominet "$INFO Setting permissions from reference file..." | log
    reference_file="$HOME/.local/share/permissions/archcraft_permissions_reference.txt"
    while read -r perm file; do
        chmod "$perm" "$file" 2>>$log_file
        prominent "Set permission $perm for $file" | log
    done < "$reference_file"
    prominent "$INFO Permissions set from reference file: OK" | log
}

# Ask user if they want to correct permissions based on reference file
read -p "Do you want to correct permissions based on the reference file? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    set_permissions_from_reference
else
    prominent "$INFO Skipping permission correction." | log
fi

# Vacuum journalctl
journalctl --vacuum-time=3d || { bug "Error: Failed to vacuum journalctl"; exit 1; }
prominent "$INFO Clear journalctl: OK"

# Clear cache
$FIND ~/.cache/ -type f -atime +3 -delete || { bug "Error: Failed to clear cache"; exit 1; }
prominent "$INFO Clear cache: OK"

# Update font cache
prominent "$INFO Updating font cache..."
fc-cache -fv || { bug "Error: Failed to update font cache"; exit 1; }
prominent "$INFO Font cache updated: OK"

# Clear trash
read -p "Do you want to clear the trash? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    rm -vrf ~/.local/share/Trash/* || { bug "Error: Failed to clear trash"; exit 1; }
    prominent "$INFO Clear Trash: OK"
else
    prominent "$INFO Skipping trash clear."
fi

# Clear docker images
if command -v docker >/dev/null 2>&1; then
  docker image prune -f || { bug "Error: Failed to clear docker images"; exit 1; }
  prominent "$INFO Clear docker: OK"
else
  prominent "$INFO Docker is not installed. Skipping docker image cleanup."
fi

# Clear temp folder
find /tmp -type f -atime +2 -delete || { bug "Error: Failed to clear temp folder"; exit 1; }
prominent "$INFO Clear temp folder: OK"

# Remove dead symlinks
read -p "Do you want to remove dead symlinks? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    find . -type l -xtype l -delete || { bug "Error: Failed to remove dead symlinks"; exit 1; }
    prominent "$INFO Remove dead symlinks: OK"
else
    prominent "$INFO Skipping dead symlink removal."
fi

# Check for python3 and rmshit.py
if command -v python3 >/dev/null 2>&1 && [ -f /usr/local/bin/rmshit.py ]; then
    python3 /usr/local/bin/rmshit.py || { bug "Error: Failed to run rmshit.py"; exit 1; }
else
    prominent "$INFO python3 or rmshit.py not found. Skipping."
fi

# Remove SSH known hosts entries older than 14 days
if [ -f "$HOME/.ssh/known_hosts" ]; then
  find "$HOME/.ssh/known_hosts" -mtime +14 -exec sed -i "{}d" {} \; || { bug "Error: Failed to remove old SSH known hosts entries"; exit 1; }
else
  prominent "$INFO No SSH known hosts file found. Skipping."
fi

# Remove orphan Vim undo files
find . -type f -iname '*.un~' -exec bash -c 'file=${0%.un~}; [[ -e "$file" ]] || rm "$0"' {} \; || { bug "Error: Failed to remove orphan Vim undo files"; exit 1; }
prominent "$INFO Remove orphan Vim undo files: OK"

# Show disk usage
df -h --exclude-type=squashfs --exclude-type=tmpfs --exclude-type=devtmpfs || { bug "Error: Failed to show disk usage"; exit 1; }
prominent "$INFO Disk usage: OK"

# Force log rotation
logrotate -f /etc/logrotate.conf || { bug "Error: Failed to force log rotation"; exit 1; }
prominent "$INFO Log rotation: OK"

# Check for failed systemd units using sysz
if command -v sysz >/dev/null 2>&1; then
    prominent "$INFO Checking failed systemd units using sysz:"
    sysz --sys --state failed || { bug "Error: Failed to check failed systemd units using sysz"; exit 1; }
    
    # Offer options to restart failed units
    read -p "Do you want to restart the failed system units? (y/n): " choice
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        sysz --sys --state failed restart || { bug "Error: Failed to restart failed systemd units using sysz"; exit 1; }
        bug "Failed system units restarted successfully."
    else
        prominent "Skipping restart of failed system units."
    fi
else
    prominent "sysz is not installed. To install, visit: https://github.com/joehillen/sysz"
fi

prominent "$EXPLOSION System Vacuumed$EXPLOSION"
exit 0
