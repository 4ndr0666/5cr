#!/usr/bin/env bash

# Check if user is root
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

# Create temporary directory to store system information
tmpdir="sysinfo-$(date +'%Y%m%d-%H%M%S-%Z')"
mkdir "$tmpdir" || exit $?

# Define a function to gather system information
gather() {
    file="$1"
    shift
    bash -c "$*" >> "$tmpdir/$file.txt" 2>&1 || true
}

# Gather system information
gather "uname" uname -a
gather "uptime" uptime
gather "selinux" sestatus
gather "dmesg" dmesg -T
gather "df" df -h
gather "mount" mount
gather "fdisk" fdisk -lu
gather "ps" ps faux
gather "sysctl" sysctl -A
gather "glxinfo" glxinfo
gather "nvidia-smi" nvidia-smi -a
gather "aticonfig" aticonfig --odgt
gather "cpuinfo" lscpu
gather "meminfo" cat /proc/meminfo
gather "lspci" lspci -v
gather "lsusb" lsusb -v
gather "lsscsi" lsscsi -s
gather "grubline" cat /proc/cmdline
gather "lsmod" lsmod
gather "lshw" lshw
gather "dmidecode" dmidecode
gather "chkconfig" chkconfig --list
gather "netstat" netstat -npl
gather "ip-rules" ip rule show
gather "ip-routes" ip route show
gather "ifconfig" ifconfig -a
gather "route" route -n
gather "dpkg-packages" dpkg -l
gather "rpm-packages" rpm -qa
gather "arch-packages-all" pacman -Q
gather "arch-packages-installed" pacman -Qe
gather "arch-packages-yay" pacman -Qm
gather "pip3" pip3 list
gather "npm" npm list -g --depth=0
gather "brew" brew list

# Compress and archive system information
XZ_OPT=-e9 tar cJf "${tmpdir}.tar.xz" "$tmpdir"
rm -rf "$tmpdir"

echo "System information archive has been created: ${tmpdir}.tar.xz"
