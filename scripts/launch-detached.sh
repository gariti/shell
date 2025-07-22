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

# Simple approach: Use nohup with disown for maximum isolation
nohup gtk-launch "$APP_ID" >/dev/null 2>&1 &
LAUNCH_PID=$!
disown $LAUNCH_PID

echo "launch-detached.sh: Started $APP_ID with PID $LAUNCH_PID" >> /tmp/launcher.log

exit 0
