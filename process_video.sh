#!/bin/bash

# process_video.sh
# Usage: ./process_video.sh input_video.mp4 output_video.mp4

input_video="$1"
output_video="$2"
temp_vpy=$(mktemp)

# Create a temporary VapourSynth script with the input video path
cat <<EOF > "$temp_vpy"
import vapoursynth as vs
core = vs.get_core()
clip = core.ffms2.Source("$input_video")
EOF
cat video_filter.vpy >> "$temp_vpy"

# Debug: Print the content of the temporary VapourSynth script
echo "=== Debug: Content of temporary VapourSynth script ==="
cat "$temp_vpy"
echo "======================================================="

# Process the video using the temporary VapourSynth script
# Add frame rate conversion to 60fps using interpolation and remove the audio
mpv "$input_video" --vf=vapoursynth="$temp_vpy",lavfi="[minterpolate='fps=60']" --o="$output_video" --no-audio --vo=gpu

# Remove the temporary VapourSynth script
rm "$temp_vpy"
