#!/bin/sh
# Simple wrapper to launch caelestia launcher
echo "$(date) - Launcher wrapper called" > /tmp/caelestia-debug.log
cd /etc/nixos/caelestia-shell
exec /run/current-system/sw/bin/fish ./caelestia drawers toggle launcher 2>&1 | tee -a /tmp/caelestia-debug.log
