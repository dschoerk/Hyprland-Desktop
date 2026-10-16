#!/bin/sh
# Show the keybind cheatsheet (keybinds-help/index.html) in a bare app window.
# Chromium derives the Wayland app_id from the URL (it ignores --class), so the
# window rule in hyprland.lua matches on "keybinds-help" in the class.
# The hash tells the page which host-only binds to show.

page="$HOME/.config/hypr/keybinds-help/index.html"
case "$(cat /etc/hostname)" in
    dominik-thinkpad) host=laptop ;;
    *)                host=desktop ;;
esac

for browser in brave chromium google-chrome-stable; do
    command -v "$browser" >/dev/null 2>&1 || continue
    # Snap browsers can't read hidden dirs like ~/.config; copy into the snap's own dir
    if [ -d "$HOME/snap/$browser/common" ]; then
        cp "$page" "$HOME/snap/$browser/common/keybinds-help.html"
        page="$HOME/snap/$browser/common/keybinds-help.html"
    fi
    exec "$browser" --app="file://$page#$host"
done
notify-send "Keybind help" "No Chromium-based browser found"
