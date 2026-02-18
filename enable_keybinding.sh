#!/usr/bin/env bash

# Enable the yabai iTerm quadrant tiling keybinding in skhd

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Ensure skhd config directory exists
mkdir -p "$(dirname "$SKHD_CONFIG")"

# Create skhd config if it doesn't exist
if [ ! -f "$SKHD_CONFIG" ]; then
    touch "$SKHD_CONFIG"
    echo "Created new skhd config at $SKHD_CONFIG"
fi

# Remove existing marker block if present so re-running updates bindings.
if grep -q "$MARKER_START" "$SKHD_CONFIG"; then
    tmp_file="$(mktemp)"
    awk -v marker_start="$MARKER_START" -v marker_end="$MARKER_END" '
        $0 == marker_start {in_block=1; next}
        $0 == marker_end {in_block=0; next}
        !in_block {print}
    ' "$SKHD_CONFIG" > "$tmp_file"
    mv "$tmp_file" "$SKHD_CONFIG"
fi

# Add the keybinding block to skhd config
cat >> "$SKHD_CONFIG" << EOF

$MARKER_START
# Tile first 4 iTerm windows into quadrants
$KEYBINDING : "$TILE_SCRIPT"
# Snap focused window to left third
$KEYBINDING_THIRD_LEFT : "$THIRD_SNAP_SCRIPT" left
# Snap focused window to right third
$KEYBINDING_THIRD_RIGHT : "$THIRD_SNAP_SCRIPT" right
$MARKER_END
EOF

echo "✓ Keybindings applied to $SKHD_CONFIG"
echo "  Quadrants:   $KEYBINDING -> $TILE_SCRIPT"
echo "  Left third:  $KEYBINDING_THIRD_LEFT -> $THIRD_SNAP_SCRIPT left"
echo "  Right third: $KEYBINDING_THIRD_RIGHT -> $THIRD_SNAP_SCRIPT right"
echo ""
echo "Restarting skhd..."

# Restart skhd to apply changes
if pgrep -x skhd > /dev/null; then
    killall skhd
    sleep 0.5
fi

skhd &
sleep 0.5

if pgrep -x skhd > /dev/null; then
    echo "✓ skhd started"
else
    echo "✗ Failed to start skhd. Try running: skhd &"
    exit 1
fi

echo ""
echo "Setup complete!"
echo "  $KEYBINDING: tile first 4 iTerm windows"
echo "  $KEYBINDING_THIRD_LEFT: snap focused window to left third"
echo "  $KEYBINDING_THIRD_RIGHT: snap focused window to right third"
