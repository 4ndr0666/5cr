#!/usr/bin/env bash

# This script takes three arguments: STR1, STR2, and the extension (without the dot) of the files to search for.
# It searches for files with the given extension and replaces all occurrences of STR1 with STR2 using sed.

# Check if the number of arguments is correct
if (( $# != 3 )); then
    echo "Usage: ${0##*/} <STR1> <STR2> <extension (without the dot)>"
    exit 1
fi

# Assign the arguments to variables
str1="$1"
str2="$2"
ext="$3"

# Search for files with the given extension and replace STR1 with STR2 using sed
find . -type f -name "*.$ext" -print0 | xargs -0 -P "$(nproc)" sed -i "s/$str1/$str2/g"
