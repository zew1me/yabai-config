#!/usr/bin/env bash

# Set up skhd to start automatically at login using LaunchAgent
# This is required for skhd to receive Accessibility permissions on macOS

PLIST_PATH="$HOME/Library/LaunchAgents/com.koekeishiya.skhd.plist"
SKHD_BIN="$(which skhd)"

if [ -z "$SKHD_BIN" ]; then
    echo "Error: skhd not found in PATH. Install with: brew install skhd"
    exit 1
fi

echo "Setting up skhd to start at login..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$HOME/Library/LaunchAgents"

# Unload existing plist if loaded
if launchctl list | grep -q com.koekeishiya.skhd; then
    echo "Unloading existing skhd LaunchAgent..."
    launchctl unload "$PLIST_PATH" 2>/dev/null
fi

# Create the plist file
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.koekeishiya.skhd</string>
    <key>ProgramArguments</key>
    <array>
        <string>${SKHD_BIN}</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/skhd.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/skhd.err.log</string>
</dict>
</plist>
EOF

echo "✓ Created LaunchAgent plist at $PLIST_PATH"

# Load the plist
launchctl load "$PLIST_PATH"

if [ $? -eq 0 ]; then
    echo "✓ skhd is now set to start automatically at login"
    echo ""
    echo "Verify skhd is running:"
    echo "  ps aux | grep '[s]khd'"
    echo "  launchctl list | grep skhd"
    echo ""
    echo "Check logs:"
    echo "  tail -f /tmp/skhd.out.log  # Output"
    echo "  tail -f /tmp/skhd.err.log  # Errors"
else
    echo "⚠ Warning: Failed to load LaunchAgent"
    echo "Try manually: launchctl load $PLIST_PATH"
    exit 1
fi
