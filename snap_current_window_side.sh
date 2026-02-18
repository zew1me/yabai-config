#!/usr/bin/env bash

# Snap the currently focused window to the left or right side of the display.
#
# Usage: snap_current_window_side.sh [left|right]

if ! command -v yabai &> /dev/null; then
    echo "Error: yabai is not installed or not in PATH"
    exit 1
fi

SIDE="${1:-}"

case "$SIDE" in
    left)
        GRID="1:3:0:0:1:1"
        ;;
    right)
        GRID="1:3:2:0:1:1"
        ;;
    *)
        echo "Usage: $0 [left|right]"
        exit 1
        ;;
esac

yabai -m window --grid "$GRID"
