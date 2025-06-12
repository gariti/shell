#!/run/current-system/sw/bin/fish

# Niri IPC helper functions
# Adapts caelestia scripts to use Niri's IPC instead of Hyprland's hyprctl

function niri_get_focused_window
    # Get currently focused window information
    set -l result (niri msg --json focused-window 2>/dev/null)
    if test $status -eq 0
        echo $result | jq -r '.Ok.FocusedWindow // empty'
    else
        echo "{}"
    end
end

function niri_get_all_windows
    # Get all window information
    set -l result (niri msg --json windows 2>/dev/null)
    if test $status -eq 0
        echo $result | jq -r '.Ok // []'
    else
        echo "[]"
    end
end

function niri_get_workspaces
    # Get workspace information
    set -l result (niri msg --json workspaces 2>/dev/null)
    if test $status -eq 0
        echo $result | jq -r '.Ok // []'
    else
        echo "[]"
    end
end

function niri_get_outputs
    # Get output/monitor information
    set -l result (niri msg --json outputs 2>/dev/null)
    if test $status -eq 0
        echo $result | jq -r '.Ok // []'
    else
        echo "[]"
    end
end

function niri_switch_workspace
    set -l workspace $argv[1]
    if test -z "$workspace"
        echo "Usage: niri_switch_workspace <workspace_id|workspace_name>"
        return 1
    end
    
    # Try as workspace index first (0-based)
    if string match -qr '^\d+$' -- "$workspace"
        set -l ws_index (math "$workspace - 1") # Convert to 0-based
        niri msg action focus-workspace "{ \"reference\": { \"Index\": $ws_index } }" >/dev/null 2>&1
    else
        # Try as workspace name
        niri msg action focus-workspace "$workspace" >/dev/null 2>&1
    end
end

function niri_move_window_to_workspace
    set -l workspace $argv[1]
    if test -z "$workspace"
        echo "Usage: niri_move_window_to_workspace <workspace_id|workspace_name>"
        return 1
    end
    
    # Try as workspace index first (0-based)
    if string match -qr '^\d+$' -- "$workspace"
        set -l ws_index (math "$workspace - 1") # Convert to 0-based
        niri msg action move-column-to-workspace "{ \"reference\": { \"Index\": $ws_index } }" >/dev/null 2>&1
    else
        # Try as workspace name
        niri msg action move-column-to-workspace "$workspace" >/dev/null 2>&1
    end
end

function niri_close_window
    niri msg action close-window >/dev/null 2>&1
end

function niri_toggle_fullscreen
    niri msg action toggle-fullscreen >/dev/null 2>&1
end

function niri_spawn
    set -l command $argv[1..]
    if test -z "$command"
        echo "Usage: niri_spawn <command> [args...]"
        return 1
    end
    
    niri msg action spawn -- $command >/dev/null 2>&1
end

# Event stream helper (for real-time updates)
function niri_event_stream
    niri msg event-stream
end

# Check if Niri is available
function niri_check
    if not command -q niri
        echo "Error: niri command not found"
        return 1
    end
    
    if not niri msg --json outputs >/dev/null 2>&1
        echo "Error: Cannot communicate with Niri compositor"
        return 1
    end
    
    return 0
end
