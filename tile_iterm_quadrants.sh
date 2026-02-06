#!/usr/bin/env bash

# Tile 4 iTerm2 windows into a 2x2 quadrant layout
# Works with yabai in float mode using explicit grid placement
#
# Usage: tile_iterm_quadrants.sh [offset]
#   offset: Number of windows to skip (default: 0)
#   Example: offset=0 tiles windows 1-4, offset=4 tiles windows 5-8

# Check if yabai is available
if ! command -v yabai &> /dev/null; then
    echo "Error: yabai is not installed or not in PATH"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Install with: brew install jq"
    exit 1
fi

# Get offset parameter (default 0)
OFFSET=${1:-0}

# Query all iTerm2 windows and get their IDs
# Filter for iTerm2 app with standard window role, skip OFFSET windows, then get the next 4 window IDs
if [ "$OFFSET" -eq 0 ]; then
    window_ids=$(yabai -m query --windows | \
        jq -r '.[] | select(.app=="iTerm2" and .role=="AXWindow") | .id' | \
        head -n 4)
else
    window_ids=$(yabai -m query --windows | \
        jq -r '.[] | select(.app=="iTerm2" and .role=="AXWindow") | .id' | \
        tail -n +$((OFFSET + 1)) | \
        head -n 4)
fi

# Check if we found any iTerm windows
if [ -z "$window_ids" ]; then
    echo "No iTerm2 windows found"
    exit 0
fi

# Count how many windows we found
window_count=$(echo "$window_ids" | wc -l | tr -d ' ')
if [ "$OFFSET" -eq 0 ]; then
    echo "Tiling windows 1-4 (found $window_count window(s))"
else
    echo "Tiling windows $((OFFSET + 1))-$((OFFSET + 4)) (found $window_count window(s))"
fi

# Grid placement for 2x2 quadrants
# Format: rows:cols:start-x:start-y:width:height
POSITIONS=(
    "2:2:0:0:1:1"  # top-left
    "2:2:1:0:1:1"  # top-right
    "2:2:0:1:1:1"  # bottom-left
    "2:2:1:1:1:1"  # bottom-right
)

# Tile each window to its quadrant
count=0
while IFS= read -r window_id; do
    if [ $count -lt 4 ]; then
        position=${POSITIONS[$count]}
        echo "Placing window $window_id at position $position"
        yabai -m window "$window_id" --grid "$position"
        # Focus the window to make it visible
        yabai -m window "$window_id" --focus
        ((count++))
    fi
done <<< "$window_ids"

echo "Tiled $count iTerm2 window(s) into quadrants"

# Bring iTerm to front and focus the first tiled window
if [ $count -gt 0 ]; then
    osascript -e 'tell application "iTerm2" to activate'
fi
