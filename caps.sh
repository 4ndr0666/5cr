#!/bin/bash

echo -e "\033[34m"
cat << "EOF"
#  _________                                 .__     
#  \_   ___ \_____  ______  ______      _____|  |__  
#  /    \  \/\__  \ \____ \/  ___/     /  ___/  |  \ 
#  \     \____/ __ \|  |_> >___ \      \___ \|   Y  \
#   \______  (____  /   __/____  > /\ /____  >___|  /
#          \/     \/|__|       \/  \/      \/     \/ 
EOF
echo -e "\033[0m"

# Global variable to store FPS, avoids multiple ffprobe calls
fps=0

# Function to get FPS of a video
get_fps() {
  local video=$1
  fps=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate "$video" | bc -l)
}

# Function to capture frames using FFmpeg
capture_frames() {
  local video=$1
  local start=$2
  local end=$3
  ffmpeg -ss "$start" -to "$end" -i "$video" -vf "fps=$fps" -qscale:v 2 -strftime 1 "out-%Y%m%d%H%M%S.png"
}

# Main menu
main_menu() {
  while true; do
    echo "=== Frame Capture Menu ==="
    echo "1. Capture Frames"
    echo "2. Exit"
    read -p "Select an option: " option

    case "$option" in
      "1")
        read -p "Enter the video file path: " video_file
        if [ ! -f "$video_file" ]; then
          echo "File does not exist. Try again."
          continue
        fi
        read -p "Enter the start time (hh:mm:ss): " start_time
        read -p "Enter the end time (hh:mm:ss): " end_time
        get_fps "$video_file"
        capture_frames "$video_file" "$start_time" "$end_time"
        ;;
      "2")
        exit 0
        ;;
      *)
        echo "Invalid option. Try again."
        ;;
    esac
  done
}

main_menu
