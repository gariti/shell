#!/run/current-system/sw/bin/fish

# Caelestia drawer control for Niri
# Interfaces with the Quickshell shell to toggle UI panels

function show_help
    echo "Caelestia Drawer Controller"
    echo
    echo "Usage: caelestia drawers [COMMAND] [DRAWER_NAME]"
    echo
    echo "Commands:"
    echo "  toggle <drawer>    - Toggle specified drawer"
    echo "  show <drawer>      - Show specified drawer"
    echo "  hide <drawer>      - Hide specified drawer"
    echo "  list              - List available drawers"
    echo
    echo "Available drawers:"
    echo "  dashboard         - Main dashboard panel"
    echo "  launcher          - Application launcher"
    echo "  session           - Session management (logout/shutdown)"
    echo "  notifications     - Notification center"
    echo
    echo "Examples:"
    echo "  caelestia drawers toggle dashboard"
    echo "  caelestia drawers show launcher"
end

function get_shell_config_path
    # Try to find the running shell configuration
    set -l shell_configs "/etc/nixos/caelestia-shell/shell.qml" "/etc/nixos/caelestia-shell/shell-niri.qml"
    
    for config in $shell_configs
        if qs list --all 2>/dev/null | grep -q "Config path: $config"
            echo $config
            return 0
        end
    end
    
    # Fallback to default
    echo "/etc/nixos/caelestia-shell/shell.qml"
end

function call_shell_ipc
    set -l method $argv[1]
    set -l args $argv[2..]
    
    set -l shell_config (get_shell_config_path)
    
    if not qs list --all 2>/dev/null | grep -q "Config path: $shell_config"
        echo "Error: Caelestia shell is not running"
        echo "Start it with: systemctl --user start caelestia-shell.service"
        return 1
    end
    
    # Call the IPC method
    qs -p "$shell_config" ipc call $method $args 2>/dev/null
end

function toggle_drawer
    set -l drawer_name $argv[1]
    
    if test -z "$drawer_name"
        echo "Error: No drawer name provided"
        echo "Use 'caelestia drawers list' to see available drawers"
        return 1
    end
    
    # For now, just show a message since IPC integration needs shell support
    echo "Toggling drawer: $drawer_name"
    echo "Note: Full IPC integration requires shell-side implementation"
    
    # Try to call shell IPC if available
    call_shell_ipc "toggle" "visibilities.$drawer_name"
end

function list_drawers
    echo "Available drawers:"
    echo "  dashboard      - Main dashboard with widgets and information"
    echo "  launcher       - Application launcher with search"
    echo "  session        - Session management (logout, shutdown, reboot)"
    echo "  notifications  - Notification center"
end

# Main command handling
set -l command $argv[1]

switch $command
    case toggle
        toggle_drawer $argv[2]
    case show
        echo "Showing drawer: $argv[2]"
        call_shell_ipc "set" "visibilities.$argv[2]" "true"
    case hide
        echo "Hiding drawer: $argv[2]"
        call_shell_ipc "set" "visibilities.$argv[2]" "false"
    case list
        list_drawers
    case -h --help ""
        show_help
    case '*'
        echo "Error: Unknown command '$command'"
        show_help
        exit 1
end
