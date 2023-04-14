#!/bin/bash

# Check if a directory is selected
if [ -z "$1" ]; then
  echo "Please select a directory."
  exit 1
fi

# Run fdupes to find duplicates
duplicates=$(fdupes -r -1 "$1")

# Check if duplicates are found
if [ -z "$duplicates" ]; then
  echo "No duplicates found."
  exit 0
fi

# Display duplicates and ask for confirmation
echo "The following duplicate files were found:"
echo "$duplicates"
read -p "Do you want to remove the duplicate files? (y/N) " response

# Remove duplicates if confirmed
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "$duplicates" | xargs -d '\n' rm -v
  echo "Duplicate files removed."
else
  echo "No files were removed."
fi
