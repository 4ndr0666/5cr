#!/bin/bash

# Prompt user for path to PKGBUILD file
read -p "Enter path to your PKGBUILD file: " PKGBUILD

# Options you want to add
ffmpeg_options="--enable-libx264 --enable-nvdec --enable-vaapi"
mpv_options="--enable-vapoursynth --enable-libmpv-shared"

# Convert options to the format used in PKGBUILD
ffmpeg_options=$(echo $ffmpeg_options | sed 's/--enable-/\'$'\\n  \'\''--enable-/g')
mpv_options=$(echo $mpv_options | sed 's/--enable-/\'$'\\n  \'\''-D/g' | sed 's/-D/-D/g')

# Add options to PKGBUILD
sed -i "/_ffmpeg_options=(/a $ffmpeg_options" $PKGBUILD
sed -i "/_mpv_options=(/a $mpv_options" $PKGBUILD

echo "Options added successfully."
