#!/usr/bin/env fish

# Caelestia Shell Scheme Management Script
# Usage: scheme.fish [command] [arguments]

function show_help
    echo "Usage: scheme.fish [command] [arguments]"
    echo ""
    echo "Commands:"
    echo "  list                    List all available schemes"
    echo "  current                 Show current scheme"
    echo "  set <scheme_name>       Set the current scheme"
    echo "  variant <variant_name>  Set scheme variant"
    echo "  print [wallpaper_path]  Print scheme colors for wallpaper"
    echo "  help                    Show this help"
end

function list_schemes
    # Look for scheme files in config directory
    set config_dir "$HOME/.config/caelestia/schemes"
    if test -d "$config_dir"
        find "$config_dir" -name "*.json" -type f | while read file
            basename "$file" .json
        end
    else
        # Default schemes if no config directory
        echo "default"
        echo "dark"
        echo "light"
        echo "blue"
        echo "green"
        echo "purple"
    end
end

function get_current_scheme
    set state_file "$HOME/.local/state/caelestia/scheme/last.txt"
    if test -f "$state_file"
        cat "$state_file"
    else
        echo "default"
    end
end

function set_scheme
    set scheme_name "$argv[1]"
    if test -z "$scheme_name"
        echo "Error: No scheme name provided"
        return 1
    end

    # Create state directory if it doesn't exist
    set state_dir "$HOME/.local/state/caelestia/scheme"
    mkdir -p "$state_dir"

    # Save the current scheme
    echo "$scheme_name" > "$state_dir/last.txt"

    # Apply the scheme (this would normally call the actual scheme application logic)
    echo "Scheme set to: $scheme_name"
    
    # For now, just notify via dbus or similar
    # notify-send "Caelestia Shell" "Scheme changed to $scheme_name" 2>/dev/null || true
end

function set_variant
    set variant_name "$argv[1]"
    if test -z "$variant_name"
        echo "Error: No variant name provided"
        return 1
    end

    # Create state directory if it doesn't exist
    set state_dir "$HOME/.local/state/caelestia/variant"
    mkdir -p "$state_dir"

    # Save the current variant
    echo "$variant_name" > "$state_dir/last.txt"

    echo "Variant set to: $variant_name"
end

function print_colors
    set wallpaper_path "$argv[1]"
    
    if test -n "$wallpaper_path" -a -f "$wallpaper_path"
        # This would normally extract colors from the wallpaper
        # For now, return a sample color scheme
        echo '{"primary": "#6200ea", "secondary": "#03dac6", "background": "#121212", "surface": "#1e1e1e"}'
    else
        # Return current scheme colors
        echo '{"primary": "#6200ea", "secondary": "#03dac6", "background": "#121212", "surface": "#1e1e1e"}'
    end
end

# Main command dispatch
switch "$argv[1]"
    case "list"
        list_schemes
    case "current"
        get_current_scheme
    case "set"
        set_scheme $argv[2..-1]
    case "variant"
        set_variant $argv[2..-1]
    case "print"
        print_colors $argv[2..-1]
    case "help" ""
        show_help
    case "*"
        echo "Error: Unknown command '$argv[1]'"
        show_help
        exit 1
end
