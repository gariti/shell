#!/run/current-system/sw/bin/fish

# Caelestia notification control for Niri
# Works with mako or dunst notification daemons

function show_help
    echo "Caelestia Notification Controller"
    echo
    echo "Usage: caelestia notifs [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  send <title> [body]        - Send a notification"
    echo "  dismiss                    - Dismiss all notifications"
    echo "  dismiss-last               - Dismiss last notification"
    echo "  toggle                     - Toggle do not disturb mode"
    echo "  status                     - Show notification daemon status"
    echo
    echo "Examples:"
    echo "  caelestia notifs send 'Test' 'Hello world'"
    echo "  caelestia notifs dismiss"
    echo "  caelestia notifs toggle"
end

function detect_notification_daemon
    if pgrep -f "mako" >/dev/null
        echo "mako"
    else if pgrep -f "dunst" >/dev/null
        echo "dunst"
    else
        echo "none"
    end
end

function send_notification
    set -l title $argv[1]
    set -l body $argv[2]
    
    if test -z "$title"
        echo "Error: No title provided"
        return 1
    end
    
    if test -n "$body"
        notify-send "$title" "$body"
    else
        notify-send "$title"
    end
end

function dismiss_notifications
    set -l daemon (detect_notification_daemon)
    
    switch $daemon
        case mako
            makoctl dismiss --all
        case dunst
            dunstctl close-all
        case none
            echo "No supported notification daemon found"
            return 1
    end
end

function dismiss_last_notification
    set -l daemon (detect_notification_daemon)
    
    switch $daemon
        case mako
            makoctl dismiss
        case dunst
            dunstctl close
        case none
            echo "No supported notification daemon found"
            return 1
    end
end

function toggle_dnd
    set -l daemon (detect_notification_daemon)
    
    switch $daemon
        case mako
            if makoctl mode | grep -q "do-not-disturb"
                makoctl mode -r do-not-disturb
                echo "Do not disturb disabled"
            else
                makoctl mode -a do-not-disturb
                echo "Do not disturb enabled"
            end
        case dunst
            dunstctl set-paused toggle
            if dunstctl is-paused | grep -q "true"
                echo "Do not disturb enabled"
            else
                echo "Do not disturb disabled"
            end
        case none
            echo "No supported notification daemon found"
            return 1
    end
end

function show_status
    set -l daemon (detect_notification_daemon)
    
    echo "Notification daemon: $daemon"
    
    switch $daemon
        case mako
            echo "Mako status:"
            makoctl mode
        case dunst
            echo "Dunst status:"
            if dunstctl is-paused | grep -q "true"
                echo "Paused: true (do not disturb)"
            else
                echo "Paused: false"
            end
        case none
            echo "No supported notification daemon running"
            return 1
    end
end

# Main command handling
set -l command $argv[1]

switch $command
    case send
        send_notification $argv[2] $argv[3]
    case dismiss
        dismiss_notifications
    case dismiss-last
        dismiss_last_notification
    case toggle
        toggle_dnd
    case status
        show_status
    case -h --help ""
        show_help
    case '*'
        echo "Error: Unknown command '$command'"
        show_help
        exit 1
end
