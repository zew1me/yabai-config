#!/usr/bin/env bash

# Configuration for yabai iTerm quadrant tiling

# Default keybinding
# cmd + 4: Tile first 4 iTerm windows
KEYBINDING="${KEYBINDING:-cmd - 4}"

# Path to the tiling script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TILE_SCRIPT="${SCRIPT_DIR}/tile_iterm_quadrants.sh"

# skhd config file location
SKHD_CONFIG="${HOME}/.config/skhd/skhdrc"

# Marker comments for identifying our keybinding in skhd config
MARKER_START="# === yabai-iterm-quadrant START ==="
MARKER_END="# === yabai-iterm-quadrant END ==="
