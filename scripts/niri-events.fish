#!/run/current-system/sw/bin/fish

# Niri Event Stream Handler
# Provides real-time event monitoring for caelestia shell components

set -l shell_path "/etc/nixos/caelestia-shell"

function show_help
    echo 'Niri Event Stream Handler'
    echo
    echo 'Usage: niri-events.fish COMMAND [options]'
    echo
    echo 'Commands:'
    echo '  start         - Start event stream monitoring'
    echo '  stop          - Stop event stream monitoring' 
    echo '  status        - Check if event stream is running'
    echo '  workspace     - Monitor workspace change events only'
    echo '  window        - Monitor window events only'
    echo '  output        - Monitor output/monitor events only'
    echo '  all           - Monitor all events (default)'
    echo
    echo 'Options:'
    echo '  --callback CMD  - Command to execute on events (receives JSON)'
    echo '  --filter TYPE   - Filter events by type'
    echo '  --daemon        - Run in background as daemon'
    echo
    echo 'Examples:'
    echo '  niri-events.fish start --daemon'
    echo '  niri-events.fish workspace --callback "caelestia shell workspace refresh"'
    echo '  niri-events.fish window --filter WindowOpenedOrChanged'
end

function check_niri_available
    if not command -q niri
        echo "Error: niri command not found. Ensure Niri compositor is installed."
        return 1
    end
    
    if not test -n "$NIRI_SOCKET"
        echo "Warning: NIRI_SOCKET environment variable not set. Niri might not be running."
    end
    
    # Test basic connectivity
    if not niri msg version >/dev/null 2>&1
        echo "Error: Cannot connect to Niri compositor."
        return 1
    end
    
    return 0
end

function start_event_stream
    set -l event_filter $argv[1]
    set -l callback_cmd $argv[2]
    set -l daemon_mode $argv[3]
    
    if not check_niri_available
        return 1
    end
    
    set -l pidfile "/tmp/caelestia-niri-events.pid"
    
    # Check if already running
    if test -f "$pidfile"
        set -l existing_pid (cat "$pidfile" 2>/dev/null)
        if test -n "$existing_pid" -a -d "/proc/$existing_pid"
            echo "Event stream already running (PID: $existing_pid)"
            return 0
        else
            rm -f "$pidfile"
        end
    end
    
    echo "Starting Niri event stream monitoring..."
    
    if test "$daemon_mode" = "true"
        nohup fish -c "source '$argv[0]'; event_loop '$event_filter' '$callback_cmd'" >/dev/null 2>&1 &
        set -l pid $last_pid
        echo $pid > "$pidfile"
        echo "Event stream started as daemon (PID: $pid)"
    else
        event_loop "$event_filter" "$callback_cmd"
    end
end

function event_loop
    set -l event_filter $argv[1]
    set -l callback_cmd $argv[2]
    
    echo "Monitoring Niri events (filter: $event_filter)..."
    
    # Start the event stream
    niri msg event-stream | while read -l event_json
        if test -z "$event_json"
            continue
        end
        
        # Parse event type
        set -l event_type (echo "$event_json" | jq -r 'keys[0]' 2>/dev/null)
        
        if test $status -ne 0
            echo "Warning: Failed to parse event JSON: $event_json"
            continue
        end
        
        # Apply filtering if specified
        if test -n "$event_filter" -a "$event_filter" != "all"
            switch "$event_filter"
                case "workspace"
                    if not string match -q "*workspace*" "$event_type"
                        continue
                    end
                case "window"
                    if not string match -q "*window*" "$event_type"
                        continue
                    end
                case "output"
                    if not string match -q "*output*" "$event_type"
                        continue
                    end
            end
        end
        
        # Process the event
        process_event "$event_type" "$event_json" "$callback_cmd"
    end
end

function process_event
    set -l event_type $argv[1]
    set -l event_json $argv[2]
    set -l callback_cmd $argv[3]
    
    # Log the event (for debugging)
    echo "[$(date '+%H:%M:%S')] Event: $event_type"
    
    # Execute callback if provided
    if test -n "$callback_cmd"
        eval "$callback_cmd '$event_json' '$event_type'" 2>/dev/null
    end
    
    # Handle specific event types
    switch "$event_type"
        case "*WorkspaceActivated*" "*WorkspaceActiveWindowChanged*"
            handle_workspace_event "$event_json"
        case "*WindowOpenedOrChanged*" "*WindowClosedOrDestroyed*" "*WindowFocusChanged*"
            handle_window_event "$event_json"
        case "*OutputConnected*" "*OutputDisconnected*" "*OutputConfigChanged*"
            handle_output_event "$event_json"
    end
end

function handle_workspace_event
    set -l event_json $argv[1]
    
    # Extract workspace information
    set -l workspace_info (echo "$event_json" | jq -r '.WorkspaceActivated // .WorkspaceActiveWindowChanged // empty' 2>/dev/null)
    
    if test -n "$workspace_info"
        # Signal workspace change to running caelestia components
        pkill -USR1 -f "caelestia.*workspace" 2>/dev/null
        
        # Update any cached workspace state files
        echo "$workspace_info" > "/tmp/caelestia-workspace-state" 2>/dev/null
    end
end

function handle_window_event
    set -l event_json $argv[1]
    
    # Extract window information
    set -l window_info (echo "$event_json" | jq -r '.WindowOpenedOrChanged // .WindowClosedOrDestroyed // .WindowFocusChanged // empty' 2>/dev/null)
    
    if test -n "$window_info"
        # Signal window change to running caelestia components
        pkill -USR2 -f "caelestia.*window" 2>/dev/null
        
        # Update cached window state
        echo "$window_info" > "/tmp/caelestia-window-state" 2>/dev/null
    end
end

function handle_output_event
    set -l event_json $argv[1]
    
    # Extract output information
    set -l output_info (echo "$event_json" | jq -r '.OutputConnected // .OutputDisconnected // .OutputConfigChanged // empty' 2>/dev/null)
    
    if test -n "$output_info"
        # Signal output change to running caelestia components
        pkill -SIGHUP -f "caelestia.*output" 2>/dev/null
        
        # Update cached output state
        echo "$output_info" > "/tmp/caelestia-output-state" 2>/dev/null
    end
end

function stop_event_stream
    set -l pidfile "/tmp/caelestia-niri-events.pid"
    
    if test -f "$pidfile"
        set -l pid (cat "$pidfile" 2>/dev/null)
        if test -n "$pid"
            if kill "$pid" 2>/dev/null
                echo "Event stream stopped (PID: $pid)"
                rm -f "$pidfile"
                return 0
            else
                echo "Failed to stop event stream process $pid"
                rm -f "$pidfile"
                return 1
            end
        end
    end
    
    # Try to find and kill any running event streams
    set -l pids (pgrep -f "niri.*event-stream" 2>/dev/null)
    if test -n "$pids"
        for pid in $pids
            kill "$pid" 2>/dev/null
        end
        echo "Stopped event stream processes: $pids"
    else
        echo "No event stream processes found"
    end
end

function check_status
    set -l pidfile "/tmp/caelestia-niri-events.pid"
    
    if test -f "$pidfile"
        set -l pid (cat "$pidfile" 2>/dev/null)
        if test -n "$pid" -a -d "/proc/$pid"
            echo "Event stream is running (PID: $pid)"
            return 0
        else
            echo "Event stream is not running (stale PID file)"
            rm -f "$pidfile"
            return 1
        end
    else
        echo "Event stream is not running"
        return 1
    end
end

# Main command handler
set -l command $argv[1]
set -l options $argv[2..]

# Parse options
set -l callback_cmd ""
set -l event_filter "all"
set -l daemon_mode "false"

for i in (seq (count $options))
    switch $options[$i]
        case "--callback"
            set callback_cmd $options[(math $i + 1)]
        case "--filter"
            set event_filter $options[(math $i + 1)]
        case "--daemon"
            set daemon_mode "true"
    end
end

switch "$command"
    case "start" "all"
        start_event_stream "$event_filter" "$callback_cmd" "$daemon_mode"
    case "stop"
        stop_event_stream
    case "status"
        check_status
    case "workspace"
        start_event_stream "workspace" "$callback_cmd" "$daemon_mode"
    case "window"
        start_event_stream "window" "$callback_cmd" "$daemon_mode"
    case "output"
        start_event_stream "output" "$callback_cmd" "$daemon_mode"
    case "help" "" "--help"
        show_help
    case "*"
        echo "Unknown command: $command"
        show_help
        exit 1
end
