#!/run/current-system/sw/bin/fish

# Caelestia MPRIS media control for Niri
# Pure D-Bus implementation, no window manager dependencies

function show_help
    echo "Caelestia MPRIS Media Controller"
    echo
    echo "Usage: caelestia mpris [COMMAND] [PLAYER]"
    echo
    echo "Commands:"
    echo "  list                    - List available media players"
    echo "  getActive [property]    - Get property from active player"
    echo "  play [player]          - Start playback"
    echo "  pause [player]         - Pause playback"
    echo "  playPause [player]     - Toggle play/pause"
    echo "  stop [player]          - Stop playback"
    echo "  next [player]          - Next track"
    echo "  previous [player]      - Previous track"
    echo
    echo "Properties (for getActive):"
    echo "  trackTitle, trackArtist, playbackStatus"
    echo
    echo "Examples:"
    echo "  caelestia mpris list"
    echo "  caelestia mpris getActive trackTitle"
    echo "  caelestia mpris playPause"
end

function get_mpris_players
    dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply \
        /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | \
        grep -oP 'org\.mpris\.MediaPlayer2\.[^\s"]+' | \
        sed 's/org\.mpris\.MediaPlayer2\.//'
end

function get_active_player
    set -l players (get_mpris_players)
    if test (count $players) -gt 0
        echo $players[1]
    end
end

function get_player_property
    set -l player $argv[1]
    set -l property $argv[2]
    
    if test -z "$player" -o -z "$property"
        return 1
    end
    
    set -l dbus_dest "org.mpris.MediaPlayer2.$player"
    
    switch $property
        case trackTitle
            set -l result (dbus-send --session --dest=$dbus_dest --print-reply \
                /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
                string:org.mpris.MediaPlayer2.Player string:Metadata 2>/dev/null)
            echo $result | grep -oP 'xesam:title[^}]*string\s*"\K[^"]*' | head -1
        case trackArtist
            set -l result (dbus-send --session --dest=$dbus_dest --print-reply \
                /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
                string:org.mpris.MediaPlayer2.Player string:Metadata 2>/dev/null)
            echo $result | grep -oP 'xesam:artist[^}]*string\s*"\K[^"]*' | head -1
        case playbackStatus
            set -l result (dbus-send --session --dest=$dbus_dest --print-reply \
                /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
                string:org.mpris.MediaPlayer2.Player string:PlaybackStatus 2>/dev/null)
            echo $result | grep -oP 'string\s*"\K[^"]*'
    end
end

function player_action
    set -l action $argv[1]
    set -l player $argv[2]
    
    if test -z "$player"
        set player (get_active_player)
    end
    
    if test -z "$player"
        echo "No active media player found"
        return 1
    end
    
    set -l dbus_dest "org.mpris.MediaPlayer2.$player"
    
    switch $action
        case play
            dbus-send --session --dest=$dbus_dest /org/mpris/MediaPlayer2 \
                org.mpris.MediaPlayer2.Player.Play 2>/dev/null
        case pause
            dbus-send --session --dest=$dbus_dest /org/mpris/MediaPlayer2 \
                org.mpris.MediaPlayer2.Player.Pause 2>/dev/null
        case playPause
            dbus-send --session --dest=$dbus_dest /org/mpris/MediaPlayer2 \
                org.mpris.MediaPlayer2.Player.PlayPause 2>/dev/null
        case stop
            dbus-send --session --dest=$dbus_dest /org/mpris/MediaPlayer2 \
                org.mpris.MediaPlayer2.Player.Stop 2>/dev/null
        case next
            dbus-send --session --dest=$dbus_dest /org/mpris/MediaPlayer2 \
                org.mpris.MediaPlayer2.Player.Next 2>/dev/null
        case previous
            dbus-send --session --dest=$dbus_dest /org/mpris/MediaPlayer2 \
                org.mpris.MediaPlayer2.Player.Previous 2>/dev/null
    end
end

# Main command handling
set -l command $argv[1]

switch $command
    case list
        get_mpris_players
    case getActive
        set -l active_player (get_active_player)
        if test -n "$active_player"
            if test -n "$argv[2]"
                get_player_property $active_player $argv[2]
            else
                echo $active_player
            end
        end
    case play pause playPause stop next previous
        player_action $command $argv[2]
    case -h --help ""
        show_help
    case '*'
        echo "Error: Unknown command '$command'"
        show_help
        exit 1
end
