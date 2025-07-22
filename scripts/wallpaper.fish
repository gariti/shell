#!/run/current-system/sw/bin/fish

# Caelestia wallpaper management for Niri

function show_help
    echo "Caelestia Wallpaper Manager (Niri Edition)"
    echo
    echo "Usage: caelestia wallpaper [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  set <path>      - Set wallpaper to specific file"
    echo "  random         - Set random wallpaper"
    echo "  current        - Show current wallpaper path"
    echo "  list           - List available wallpapers"
    echo
    echo "Examples:"
    echo "  caelestia wallpaper set ~/Pictures/my-wallpaper.jpg"
    echo "  caelestia wallpaper random"
end

function set_wallpaper
    set -l wallpaper_path $argv[1]
    
    if test -z "$wallpaper_path"
        echo "Error: No wallpaper path provided"
        return 1
    end
    
    if not test -f "$wallpaper_path"
        echo "Error: Wallpaper file not found: $wallpaper_path"
        return 1
    end
    
    # Update QML state to trigger fade transition
    set -l state_dir "$HOME/.local/state/quickshell/wallpaper"
    mkdir -p $state_dir
    echo "$wallpaper_path" > $state_dir/last.txt
    
    echo "Wallpaper set: $wallpaper_path"
end

function set_random_wallpaper
    set -l wallpaper_dir "$HOME/Pictures/Wallpapers"
    
    if not test -d "$wallpaper_dir"
        echo "Error: Wallpapers directory not found: $wallpaper_dir"
        return 1
    end
    
    set -l wallpapers (find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null)
    set -l count (count $wallpapers)
    
    if test $count -eq 0
        echo "Error: No wallpapers found in $wallpaper_dir"
        return 1
    end
    
    set -l random_index (random 1 $count)
    set -l selected_wallpaper $wallpapers[$random_index]
    
    set_wallpaper "$selected_wallpaper"
end

function list_wallpapers
    set -l wallpaper_dir "$HOME/Pictures/Wallpapers"
    
    if not test -d "$wallpaper_dir"
        echo "Error: Wallpapers directory not found: $wallpaper_dir"
        return 1
    end
    
    find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null
end

function get_current_wallpaper
    echo "Current wallpaper functionality not yet implemented"
    return 1
end

# Main command handling
set -l command $argv[1]

switch $command
    case set
        set_wallpaper $argv[2]
    case random
        set_random_wallpaper
    case list
        list_wallpapers
    case current
        get_current_wallpaper
    case -h --help ""
        show_help
    case '*'
        echo "Error: Unknown command '$command'"
        show_help
        exit 1
end
