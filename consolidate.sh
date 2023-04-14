#!/bin/bash

# Usage: ./move_all_files.sh /path/to/source_directory /path/to/new_parent_directory

source_dir="$1"
new_parent_dir="$2"

# Create the new parent directory if it doesn't exist
mkdir -p "$new_parent_dir"

# Move all files from the source directory and its subdirectories to the new parent directory
find "$source_dir" -type f -exec mv {} "$new_parent_dir" \;
