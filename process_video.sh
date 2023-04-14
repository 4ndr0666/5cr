#!/bin/bash
set -euo pipefail

readonly INPUT_VIDEO="$1"
readonly OUTPUT_VIDEO="$2"
readonly TEMP_VPY="$(mktemp).vpy"

# Create a temporary VapourSynth script with the input video path
printf "import sys\nsys.argv = [None, '%s']\n" "$INPUT_VIDEO" > "$TEMP_VPY"
cat video_filter.vpy >> "$TEMP_VPY"

# Debug: Print the content of the temporary VapourSynth script
printf "=== Debug: Content of temporary VapourSynth script ===\n%s\n=======================================================\n" "$(cat "$TEMP_VPY")"

# Process the video using the temporary VapourSynth script
# Add frame rate conversion to 60fps using interpolation and remove the audio
mpv "$INPUT_VIDEO" --vf=vapoursynth="$TEMP_VPY",lavfi="[minterpolate='fps=60']" --o="$OUTPUT_VIDEO" --no-audio --vo=gpu

# Remove the temporary VapourSynth script
rm "$TEMP_VPY"
