#!/bin/zsh

# Kill the transmission-daemon process
killall transmission-daemon 2>/dev/null

# Start transmission-daemon and filter its log output
transmission-daemon --foreground --log-info 2>&1 | grep -v -e "announcer.c:" -e "platform.c:" -e "Saved.*variant.c:" | while read line; do
    if echo "$line" | grep -q "Queued for verification (verify.c:"; then
        # Notify when a download is queued for verification
        notify-send --app-name="Transmission Started" "${line#* * }"
    elif echo "$line" | grep -q "changed from .Incomplete. to .Complete."; then
        # Notify when a download is complete
        notify-send --app-name="Transmission Complete" "${line#* * }"
    fi

    # Log the filtered output using systemd-cat
    echo "$line" | systemd-cat --identifier="TransWrap" --priority=5
done & disown
