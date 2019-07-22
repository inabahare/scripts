#!/bin/bash
# Script to deal with batch waifu2x'ing files and clean up after itself like a good boy.


# Setup

# Create log file
log=$(mktemp)

# Input directory
in="/mnt/jupiter/Temp/2x_waiting"

# Output directory
out="/mnt/jupiter/Temp/2x_done"

# Converter
waifu="$HOME/waifu2x-converter-cpp/out/waifu2x-converter-cpp"

# Arguments (verbose, recursive, subdirs, no autonaming)
args="-v 1 -r 1 -g 1 -f webp -n 0 -i $in -o $out"



# Let's go!
script -q -c "$waifu $args" "$log"



# Clean output
sed -i '1d;$d' "$log"

# Check for errors
errors=$(grep -o "0 files errored" "$log" | awk '{print $1}')

# All files processed, with full paths
files=$(grep -oP '"\K[^"\047]+(?=["\047])' "$log" | awk -v prefix="$in/" '{print prefix $0}' | tr '\n' ' ')

# Delete source files and log if no errors, otherwise scream
if [ -z "$errors" ]; then
    failed=$(grep "too big" "$log" | grep -o '"[^"]\+"')
    echo -e "\e[0;31mFollowing file(s) are too big for WebP: $failed\e[0m"
    echo "Check out file://$log for more details."
else
    echo -e "\e[0;32mNo errors detected, deleting source files!\e[0m"
    rm $files && echo "Source files deleted."
    rm "$log"
fi
