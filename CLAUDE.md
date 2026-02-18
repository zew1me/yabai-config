# Yabai iTerm Quadrant Tiling Configuration

## Project Overview

This project provides scripting to tile the first four iTerm windows into a 2x2 quadrant layout using yabai window manager. The solution maintains yabai's `float` layout mode while providing explicit grid placement for precise window positioning.

## Key Features

- **Float Mode Compatibility**: Uses yabai's grid placement without switching to BSP layout
- **Simple Keybinding**: Command+4 tiles the first 4 most-recently-focused iTerm windows
- **Third Snap Keybindings**: Command+Control+Left/Right snaps focused window to left/right third
- **Global Hotkey**: Works from any application, brings iTerm windows to front
- **Enable/Disable Scripts**: Easy scripts to add or remove the keybinding
- **One-Handed Operation**: Keybinding designed for single-hand activation
- **Offset-Based Selection**: Script accepts optional offset parameter for manual use

## Architecture

### Grid Placement Format

Yabai uses the format `<rows>:<cols>:<start-x>:<start-y>:<width>:<height>` for grid placement:
- For 2x2 quadrant layout:
  - Top-left: `2:2:0:0:1:1`
  - Top-right: `2:2:1:0:1:1`
  - Bottom-left: `2:2:0:1:1:1`
  - Bottom-right: `2:2:1:1:1:1`

### Components

1. **tile_iterm_quadrants.sh**: Main script that queries iTerm windows and places them in quadrants
   - Accepts optional offset parameter (default: 0 for windows 1-4)
   - Brings iTerm to front after tiling
2. **snap_current_window_third.sh**: Snaps currently focused window to left or right third
   - Accepts `left` or `right` argument
   - Uses yabai grid placement `1:3:0:0:1:1` or `1:3:2:0:1:1`
3. **enable_keybinding.sh**: Adds/updates managed keybinding block in skhd configuration
4. **disable_keybinding.sh**: Removes the managed keybinding block from skhd configuration
5. **config.sh**: Configuration file for keybindings and script paths
6. **setup_skhd_autostart.sh**: Sets up skhd to start automatically via LaunchAgent

## Requirements

- macOS with Accessibility permissions granted
- yabai (installed via Homebrew)
- skhd (installed via Homebrew)
- iTerm2
- jq (for JSON parsing)

## Installation Notes

- Yabai version: v7.1.16+
- Works with default float layout
- No SIP disabling required for this functionality

## Window Ordering

Windows returned by `yabai -m query --windows` are in **most-recently-focused order** (see [yabai issue #944](https://github.com/koekeishiya/yabai/issues/944)). This means:
- The "first 4" windows are the 4 most recently used/focused
- Windows 5-8 are the next 4 most recently used
- Ordering changes as you switch between windows

## Troubleshooting

### Keybinding Not Working

**Problem**: The keybinding doesn't trigger the tiling script.

**Common Causes**:
1. **Accessibility Permissions Missing**: skhd needs accessibility permissions to capture keystrokes
   - System Settings → Privacy & Security → Accessibility
   - **Note**: skhd is a command-line tool and won't appear in the Accessibility UI when added manually
   - **Solution**: Use a LaunchAgent to run skhd (see setup below)

2. **skhd Not Running**: Check if skhd is active
   ```bash
   ps aux | grep skhd | grep -v grep
   ```

3. **Config Not Loaded**: Reload skhd configuration
   ```bash
   skhd --reload
   ```

### Testing the Script Manually

You can test the tiling script directly:
```bash
/Users/nigel.stuke/repos/nigel-upstart/yabai-config/tile_iterm_quadrants.sh
```

### Setting Up skhd with Accessibility Permissions

skhd is a command-line tool that requires accessibility permissions but cannot be added to System Settings manually. The solution is to run it via a LaunchAgent:

**LaunchAgent is already configured at**: `~/Library/LaunchAgents/com.koekeishiya.skhd.plist`

To verify it's running:
```bash
launchctl list | grep skhd
ps aux | grep '[s]khd'
```

To restart skhd:
```bash
launchctl unload ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
launchctl load ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
```

**Logs**: Check `/tmp/skhd.out.log` and `/tmp/skhd.err.log` for debugging.

### Alternative Keybindings

If cmd+4 conflicts with other apps, edit `~/.config/skhd/skhdrc` and try:
- `cmd + alt - t` (Command + Option + T)
- `ctrl + alt - t` (Control + Option + T)
- `cmd + shift - t` (Command + Shift + T)

Then reload with `pkill -USR1 skhd`.

For third snapping, configure in `config.sh`:
- `KEYBINDING_THIRD_LEFT`
- `KEYBINDING_THIRD_RIGHT`

## References

Key documentation sources:
- [Yabai Commands Wiki](https://github.com/koekeishiya/yabai/wiki/Commands)
- [Yabai Configuration Wiki](https://github.com/koekeishiya/yabai/wiki/Configuration)
- [Josh Medeski's Yabai Setup](https://www.joshmedeski.com/posts/blazing-fast-window-management-on-macos/)
- [Yabai Window Ordering Discussion](https://github.com/koekeishiya/yabai/issues/944)
