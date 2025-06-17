#!/usr/bin/env bash
# Proper application launcher that completely detaches from parent process
# This ensures applications don't get killed when the shell restarts

if [ $# -eq 0 ]; then
    echo "Usage: $0 <application-id>"
    exit 1
fi

APP_ID="$1"

# Double fork to ensure complete detachment from parent process
(
    # First fork - this creates a child process
    (
        # Second fork and exec - this completely detaches from the shell
        # and ensures the process is adopted by init (PID 1)
        exec setsid gtk-launch "$APP_ID" </dev/null >/dev/null 2>&1 &
    ) &
) &

# Exit immediately, leaving no trace of connection to the parent
exit 0
