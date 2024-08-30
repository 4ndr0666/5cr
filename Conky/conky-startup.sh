#!/bin/bash

set -euo pipefail

# Check if the user has logged in
if [[ "$logged_user" == *andro* ]]; then

  # Display a notification
  notify-send -i "$notify_icon" "Information display will start in a few seconds"
  echo "Information display will start in a few seconds"
 
  while true; do
    show_conky=$(jq -r .showconky "$json_file_name")
    if [[ "$show_conky" == *Yes* ]]; then 
      if [[ "$logged_user" == "$exec_user" ]]; then
        if ! pgrep conkyrc0 > /dev/null && pgrep cinnamon-desktop > /dev/null; then
          sudo -E dockcross-"$image" conky -d -c "/home/andro/.conky/4ndr0666/Gotham"
          sleep 1
          sudo -E dockcross-"$image" conky -d -c "/home/andro/.conky/4ndr0666/.conkyrc1"
          sleep 1
          sudo -E dockcross-"$image" conky -d -c "/home/andro/.conky/4ndr0666/.conkyrc3"
          sleep 1
          sudo -E dockcross-"$image" conky -d -c "/home/andro/.conky/4ndr0666/.conkyrc2"
        fi
      fi
    fi
    sleep 15
  done
fi
