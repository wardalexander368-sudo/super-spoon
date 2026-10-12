#!/bin/bash
# Installs (or with --uninstall, removes) a launchd agent that runs
# scripts/autopull.sh for this clone every hour and at login.
set -euo pipefail

label="com.super-spoon.autopull"
plist="$HOME/Library/LaunchAgents/$label.plist"
logfile="$HOME/Library/Logs/super-spoon-autopull.log"
domain="gui/$(id -u)"

if [ "$(uname)" != "Darwin" ]; then
  echo "This installer is for macOS (launchd)." >&2
  exit 1
fi

launchctl bootout "$domain/$label" 2>/dev/null || true

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$plist"
  echo "Removed $label. Log kept at $logfile"
  exit 0
fi

repo="$(cd "$(dirname "$0")/.." && pwd)"
script="$repo/scripts/autopull.sh"
chmod +x "$script"

xml_escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$1"; }

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$(xml_escape "$script")</string>
  </array>
  <key>StartInterval</key>
  <integer>3600</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$(xml_escape "$logfile")</string>
  <key>StandardErrorPath</key>
  <string>$(xml_escape "$logfile")</string>
</dict>
</plist>
EOF
plutil -lint "$plist" >/dev/null

launchctl bootstrap "$domain" "$plist"
echo "Installed $label: pulls $repo every hour and at login."
echo "Log: $logfile"
sleep 2
tail -n 3 "$logfile" 2>/dev/null || true
