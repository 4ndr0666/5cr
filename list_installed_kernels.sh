#!/bin/bash

# Store the list of kernels in a variable
kernels=$(ls /boot | grep vmlinuz-)

# Convert the string of kernels into an array
IFS=' ' read -r -a kernel_array <<< "$kernels"

# Print each kernel on a new line
for kernel in "${kernel_array[@]}"
do
   echo "$kernel"
done
