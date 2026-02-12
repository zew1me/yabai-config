# Yabai iTerm Quadrant Tiling

Automatically tile the first 4 iTerm2 windows into a 2×2 quadrant layout using yabai and skhd, while keeping yabai in float mode.

## Features

- 🎯 **Simple quadrant tiling** - Tile first 4 iTerm windows with one keystroke
- 🎨 **Float mode compatible** - No need to switch to BSP layout
- ⌨️ **One-handed keybinding** - `⌘4` (configurable)
- 🔧 **Easy enable/disable** - Simple scripts to manage keybinding
- 📦 **Self-contained** - All configuration in this repo
- 🪟 **Global hotkey** - Works from any application, brings iTerm to front

## Prerequisites

Install via Homebrew if not already installed:

```bash
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
brew install jq
```

Grant Accessibility permissions to yabai in:
**System Settings → Privacy & Security → Accessibility**

**Note about skhd**: skhd is a command-line tool and cannot be manually added to Accessibility. It must run via LaunchAgent (handled by setup script below).

## Quick Start

### 1. Set Up skhd LaunchAgent

**This is required** for skhd to receive accessibility permissions:

```bash
./setup_skhd_autostart.sh
```

This will:
- Create a LaunchAgent that starts skhd automatically on login
- Enable skhd to receive accessibility permissions
- Set up logging to `/tmp/skhd.out.log` and `/tmp/skhd.err.log`

### 2. Enable the Keybinding

```bash
./enable_keybinding.sh
```

This will:
- Add the keybinding to `~/.config/skhd/skhdrc`
- Reload skhd configuration
- Default keybinding: `⌘4`

### 3. Use It

Open at least 4 iTerm2 windows, then press `⌘4` (from any application):

```
┌─────────┬─────────┐
│ Window 1│ Window 2│
├─────────┼─────────┤
│ Window 3│ Window 4│
└─────────┴─────────┘
```

The first 4 windows are selected by most-recently-focused order, and iTerm is brought to the front automatically.

### 4. Disable (Optional)

To remove the keybinding:

```bash
./disable_keybinding.sh
```

## Configuration

### Change the Keybinding

Edit `config.sh` and set your preferred keybinding:

```bash
# Default: cmd + 4
KEYBINDING="cmd - 4"

# Alternative: cmd + shift + 4
# KEYBINDING="cmd + shift - 4"
```

Then run `./enable_keybinding.sh` again to apply.

### skhd Keybinding Format

- `cmd` - Command key
- `shift` - Shift key
- `-` separator between modifier and key
- Example: `cmd + shift - 4` = Command + Shift + 4

See [skhd documentation](https://github.com/koekeishiya/skhd) for more options.

## Manual Usage

You can also run the tiling script directly without a keybinding:

```bash
# Tile first 4 windows
./tile_iterm_quadrants.sh

# Or specify an offset to tile different windows
# Tile windows 5-8
./tile_iterm_quadrants.sh 4
```

## How It Works

The `tile_iterm_quadrants.sh` script:

1. Accepts an optional offset parameter (default: 0)
2. Queries all windows using `yabai -m query --windows`
3. Filters for iTerm2 application windows
4. Skips the first N windows (where N is the offset)
5. Takes the next 4 window IDs
6. Places each in a quadrant using yabai's grid format:
   - Top-left: `2:2:0:0:1:1`
   - Top-right: `2:2:1:0:1:1`
   - Bottom-left: `2:2:0:1:1:1`
   - Bottom-right: `2:2:1:1:1:1`

The grid format is `rows:cols:start-x:start-y:width:height`, where the screen is divided into a 2×2 grid and each window occupies one cell.

**Window Ordering:** Windows are returned by yabai in most-recently-focused order (see [yabai issue #944](https://github.com/koekeishiya/yabai/issues/944)), so the "first 4" windows are the 4 most recently active windows.

## Managing skhd

### Check Status

```bash
# Check if skhd is running
ps aux | grep '[s]khd'
launchctl list | grep skhd

# View logs
tail -f /tmp/skhd.out.log  # Output
tail -f /tmp/skhd.err.log  # Errors
```

### Restart skhd

```bash
# Full restart
launchctl unload ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
launchctl load ~/Library/LaunchAgents/com.koekeishiya.skhd.plist

# Or just reload config
pkill -USR1 skhd
```

## Troubleshooting

### Keybinding not working

1. **Check if skhd is running:**
   ```bash
   ps aux | grep '[s]khd'
   launchctl list | grep skhd
   ```

2. **Verify LaunchAgent is set up:**
   ```bash
   ls -la ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
   ```
   If missing, run: `./setup_skhd_autostart.sh`

3. **Check logs for errors:**
   ```bash
   tail -20 /tmp/skhd.err.log
   ```

4. **Verify keybinding:**
   ```bash
   cat ~/.config/skhd/skhdrc | grep -A 2 "yabai-iterm-quadrant"
   ```

### Accessibility permissions

**yabai**: Add `/opt/homebrew/bin/yabai` to System Settings → Privacy & Security → Accessibility

**skhd**: Must run via LaunchAgent (not manually added to Accessibility). Run `./setup_skhd_autostart.sh` to set this up. After setup, restart your Mac for permissions to take effect.

### Windows not tiling

1. Verify yabai is running: `yabai -m query --windows`
2. Check you have at least 1 iTerm window open
3. Run the script manually to see error messages: `./tile_iterm_quadrants.sh`

## Project Structure

```
.
├── README.md                    # This file
├── CLAUDE.md                    # Project documentation for Claude
├── config.sh                    # Configuration (keybinding, paths)
├── tile_iterm_quadrants.sh      # Main tiling script
├── enable_keybinding.sh         # Add keybinding to skhd
├── disable_keybinding.sh        # Remove keybinding from skhd
└── setup_skhd_autostart.sh      # Set up skhd LaunchAgent (one-time)
```

## Resources

- [yabai Wiki](https://github.com/koekeishiya/yabai/wiki)
- [yabai Commands](https://github.com/koekeishiya/yabai/wiki/Commands)
- [skhd Documentation](https://github.com/koekeishiya/skhd)
- [Josh Medeski's Yabai Guide](https://www.joshmedeski.com/posts/blazing-fast-window-management-on-macos/)
- [Josean's Yabai Setup](https://www.josean.com/posts/yabai-setup)

## License

MIT
