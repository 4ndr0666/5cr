#!/bin/bash

echo "Kernel Management Utility - Version 1"
echo "-------------------------------------"

# List installed kernels
echo "Installed Kernels:"
installed_kernels=$(expac '%n' | grep '^linux')
echo "$installed_kernels"

# Determine the running kernel
echo "Running Kernel:"
running_kernel=$(uname -r)
echo "$running_kernel"

# Function to install a new kernel
install_kernel() {
    echo "Installing kernel: $1"
    sudo pacman -S "$1" --noconfirm
}

# Function to remove a kernel
remove_kernel() {
    echo "Removing kernel: $1"
    sudo pacman -R "$1" --noconfirm
}

# User interaction for kernel management
echo "Options:"
echo "1. Install a new kernel"
echo "2. Remove an existing kernel"
read -p "Enter your choice (1/2): " choice

case $choice in
    1)
        read -p "Enter the kernel name to install (e.g., linux-lts): " kernel_name
        install_kernel "$kernel_name"
        ;;
    2)
        read -p "Enter the kernel name to remove (e.g., linux-lts): " kernel_name
        remove_kernel "$kernel_name"
        ;;
    *)
        echo "Invalid option."
        ;;
esac
