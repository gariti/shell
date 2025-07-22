#!/usr/bin/env bash
# Proper application launcher that completely detaches from parent process
# This ensures applications don't get killed when the shell restarts

if [ $# -eq 0 ]; then
    echo "Usage: $0 <application-id>"
    exit 1
fi

APP_ID="$1"

# Log for debugging
echo "launch-detached.sh: Launching $APP_ID" >> /tmp/launcher.log

# Remove .desktop extension if present for gtk-launch compatibility
LAUNCH_ID="${APP_ID%.desktop}"

# Try multiple launch methods to ensure compatibility
if command -v gtk-launch >/dev/null 2>&1; then
    # gtk-launch expects the desktop file name without extension
    echo "launch-detached.sh: Using gtk-launch with $LAUNCH_ID" >> /tmp/launcher.log
    nohup gtk-launch "$LAUNCH_ID" >/dev/null 2>&1 &
    LAUNCH_PID=$!
    disown $LAUNCH_PID
elif command -v dex >/dev/null 2>&1; then
    # dex can handle full paths and desktop IDs
    echo "launch-detached.sh: Using dex with $APP_ID" >> /tmp/launcher.log
    nohup dex "$APP_ID" >/dev/null 2>&1 &
    LAUNCH_PID=$!
    disown $LAUNCH_PID
elif command -v gio >/dev/null 2>&1; then
    # gio launch as fallback
    echo "launch-detached.sh: Using gio launch with $APP_ID" >> /tmp/launcher.log
    nohup gio launch "$APP_ID" >/dev/null 2>&1 &
    LAUNCH_PID=$!
    disown $LAUNCH_PID
else
    echo "launch-detached.sh: ERROR - No suitable launcher found" >> /tmp/launcher.log
    exit 1
fi

echo "launch-detached.sh: Started $APP_ID with PID $LAUNCH_PID" >> /tmp/launcher.log

exit 0
