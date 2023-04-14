#!/usr/bin/env bash

if [[ "$EUID" != 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

grub-mkconfig -o /boot/grub/grub.cfg "$@"
