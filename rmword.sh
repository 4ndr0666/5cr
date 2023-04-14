#!/usr/bin/env bash

if (( $# == 2 )); then
    word="$1"
    file="$2"
    sed -i "s/$word//g" "$file"
    echo "Removed all occurrences of '$word' from '$file'"
else
    echo "Usage: ${0##*/} <word> <file>"
    exit 1
fi
