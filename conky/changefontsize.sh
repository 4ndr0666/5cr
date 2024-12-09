#!/bin/bash
#
# Change font size of conky

# Set variables
OLD_FONT_SIZE=$(cat $Jason_file_name | jq -r .Screenfontsize)
NOTIFY_ICON="icon.png"

# Check if font size is within limits
if [[ "$OLD_FONT_SIZE" -lt 20 && "$OLD_FONT_SIZE" -gt 2 ]]; then
    # Determine direction of font size change
    if [[ "$#" -eq 1 && "$1" == "down" ]]; then
        NEW_FONT_SIZE=$((OLD_FONT_SIZE - 1))
    else
        NEW_FONT_SIZE=$((OLD_FONT_SIZE + 1))
    fi

    # Update font size and configuration files
    rpl -i "size=$OLD_FONT_SIZE" "size=$NEW_FONT_SIZE" /home/andro/.conky/4ndr0666/.conkyrc*
    if [[ "$NEW_FONT_SIZE" -lt 13 ]]; then
        rpl -i "gap_x 350" "gap_x 220" /home/andro/.conky/4ndr0666/.conkyrc2*
        rpl -i "gap_x 725" "gap_x 480" /home/andro/.conky/4ndr0666/.conkyrc1*
        rpl -i "minimum_size 320 0" "minimum_size 220 0" /home/andro/.conky/4ndr0666/.conkyrc1*
    else
        rpl -i "gap_x 220" "gap_x 350" /home/andro/.conky/4ndr0666/.conkyrc2*
        rpl -i "gap_x 480" "gap_x 725" /home/andro/.conky/4ndr0666/.conkyrc1*
        rpl -i "minimum_size 220 0" "minimum_size 320 0" /home/andro/.conky/4ndr0666/.conkyrc1*
    fi

    # Notify user of font size change
    notify-send -i $NOTIFY_ICON "Font size changed from: $OLD_FONT_SIZE to: $NEW_FONT_SIZE"
    writeToJason "$NEW_FONT_SIZE " "Screenfontsize"
else
    # Notify user of invalid font size
    notify-send -i $NOTIFY_ICON "Invalid font size: $OLD_FONT_SIZE"
fi

exit 1;
