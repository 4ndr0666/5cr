#!/bin/bash

# Update the package database
echo "Updating package database..."
sudo pacman -Sy

# Define a more inclusive filter for kernel-related packages
kernel_pkg_filter() {
    grep -E '^linux[0-9]*(-[a-z]+[0-9]*(-[a-z0-9]+)?)?(-headers|-docs)?$'
}

# Get the list of all available linux kernels from official repositories
echo "Retrieving official kernels..."
official_kernels=$(pacman -Ssq '^linux' | kernel_pkg_filter)

# Get the list of all available linux kernels from AUR
echo "Retrieving AUR kernels..."
aur_kernels=$(yay -Ssq '^linux' | kernel_pkg_filter)

# Combine both lists and remove duplicates
kernels=$(echo -e "${official_kernels}\n${aur_kernels}" | sort -u)

# Convert the string of kernels into an array
IFS=$'\n' read -r -d '' -a kernel_array <<< "${kernels}"

# Print each kernel on a new line
for kernel in "${kernel_array[@]}"; do
   echo "$kernel"
done
