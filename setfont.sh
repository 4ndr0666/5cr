#!/bin/bash
if sudo touch /etc/vconsole.conf &> /dev/null; then
    if sudo cat <<EOF > /etc/vconsole.conf
KEYMAP=us
FONT=ter-220n
EOF
    then
        echo "Successfully updated /etc/vconsole.conf"
    else
        echo "Failed to write to /etc/vconsole.conf"
        exit 1
    fi
else
    echo "Failed to obtain root privileges"
    exit 1
fi
