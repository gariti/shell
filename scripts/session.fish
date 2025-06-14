#!/run/current-system/sw/bin/fish

# Caelestia session management for Niri
# Direct session control commands and UI integration

function show_help
    echo "Caelestia Session Management"
    echo
    echo "Usage: caelestia session [COMMAND]"
    echo
    echo "Commands:"
    echo "  menu      - Show session management menu"
    echo "  lock      - Lock the screen" 
    echo "  logout    - Logout current user"
    echo "  suspend   - Suspend the system"
    echo "  reboot    - Reboot the system"
    echo "  shutdown  - Shutdown the system"
    echo
    echo "Examples:"
    echo "  caelestia session menu"
    echo "  caelestia session lock"
    echo "  caelestia session logout"
end

function get_shell_config_path
    # Try to find the running shell configuration
    set -l shell_configs "/etc/nixos/caelestia-shell/shell-enhanced.qml" "/etc/nixos/caelestia-shell/shell.qml" "/etc/nixos/caelestia-shell/shell-simple.qml"
    
    for config in $shell_configs
        if qs list --all 2>/dev/null | grep -q "Config path: $config"
            echo $config
            return 0
        end
    end
    
    # Fallback to default
    echo "/etc/nixos/caelestia-shell/shell-enhanced.qml"
end

function call_shell_ipc
    set -l method $argv[1]
    set -l args $argv[2..]
    
    set -l shell_config (get_shell_config_path)
    
    if not qs list --all 2>/dev/null | grep -q "Config path: $shell_config"
        echo "Warning: Caelestia shell is not running"
        echo "Session actions will execute directly without shell integration"
        return 1
    end
    
    # Call the IPC method
    qs -p "$shell_config" ipc call $method $args 2>/dev/null
end

function execute_session_action
    set -l action $argv[1]
    
    echo "Executing session action: $action"
    
    switch $action
        case lock
            if command -v swaylock >/dev/null
                swaylock
            else if command -v loginctl >/dev/null
                loginctl lock-session
            else
                echo "Error: No screen locker found (tried swaylock, loginctl)"
                exit 1
            end
            
        case logout
            if command -v loginctl >/dev/null
                loginctl terminate-user $USER
            else
                echo "Error: loginctl not found"
                exit 1
            end
            
        case suspend
            systemctl suspend
            
        case reboot
            systemctl reboot
            
        case shutdown
            systemctl poweroff
            
        case '*'
            echo "Error: Unknown session action '$action'"
            exit 1
    end
end

# Main command handling
set -l command $argv[1]

switch $command
    case menu
        echo "Opening session management menu..."
        if call_shell_ipc "drawers" "toggle" "session"
            echo "Session menu toggled successfully"
        else
            echo "Shell not running, showing available actions:"
            echo "  lock, logout, suspend, reboot, shutdown"
        end
        
    case lock
        execute_session_action "lock"
        
    case logout
        echo "⚠️  Logging out in 3 seconds... (Ctrl+C to cancel)"
        sleep 3
        execute_session_action "logout"
        
    case suspend
        echo "💤 Suspending system in 3 seconds... (Ctrl+C to cancel)"
        sleep 3
        execute_session_action "suspend"
        
    case reboot
        echo "🔄 Rebooting system in 5 seconds... (Ctrl+C to cancel)"
        sleep 5
        execute_session_action "reboot"
        
    case shutdown
        echo "⚡ Shutting down system in 5 seconds... (Ctrl+C to cancel)"
        sleep 5
        execute_session_action "shutdown"
        
    case -h --help ""
        show_help
        
    case '*'
        echo "Error: Unknown command '$command'"
        show_help
        exit 1
end
