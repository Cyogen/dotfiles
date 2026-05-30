#!/bin/bash
# Syncs live configs into the dotfiles directory.
# Run this any time you make changes you want to preserve.
# Then: git add -A && git commit -m "update" && git push

set -e
DOTS="$(cd "$(dirname "$0")" && pwd)"

sync() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp -f "$src" "$dst"
}

syncdir() {
    local src="$1" dst="$2"
    mkdir -p "$dst"
    cp -a "$src/." "$dst/"
}

echo "→ Syncing configs..."

# Hyprland
sync ~/.config/hypr/hyprland.conf           "$DOTS/config/hypr/hyprland.conf"
sync ~/.config/hypr/hyprpaper.conf          "$DOTS/config/hypr/hyprpaper.conf"

# Waybar
sync ~/.config/waybar/config                "$DOTS/config/waybar/config"
sync ~/.config/waybar/style.css             "$DOTS/config/waybar/style.css"
sync ~/.config/waybar/colors.css            "$DOTS/config/waybar/colors.css"

# Kitty
sync ~/.config/kitty/kitty.conf             "$DOTS/config/kitty/kitty.conf"

# eww
sync ~/.config/eww/eww.yuck                 "$DOTS/config/eww/eww.yuck"
sync ~/.config/eww/eww.scss                 "$DOTS/config/eww/eww.scss"
sync ~/.config/eww/scripts/weather.sh       "$DOTS/config/eww/scripts/weather.sh"
sync ~/.config/eww/scripts/workspace-watch.sh \
                                            "$DOTS/config/eww/scripts/workspace-watch.sh"

# wlogout
sync ~/.config/wlogout/layout               "$DOTS/config/wlogout/layout"

# Shell
sync ~/.bashrc                              "$DOTS/home/.bashrc"
sync ~/.dircolors                           "$DOTS/home/.dircolors"

# Neovim (full config directory)
syncdir ~/.config/nvim                      "$DOTS/config/nvim"

# KDE
sync ~/.config/kdeglobals                   "$DOTS/config/kde/kdeglobals"
sync ~/.config/kglobalshortcutsrc          "$DOTS/config/kde/kglobalshortcutsrc"
sync ~/.config/kwinrc                       "$DOTS/config/kde/kwinrc"
sync ~/.config/kwinrulesrc                  "$DOTS/config/kde/kwinrulesrc"
sync ~/.config/plasmarc                     "$DOTS/config/kde/plasmarc"
[[ -f ~/.config/plasma-org.kde.plasma.desktop-appletsrc ]] && \
    sync ~/.config/plasma-org.kde.plasma.desktop-appletsrc \
         "$DOTS/config/kde/plasma-org.kde.plasma.desktop-appletsrc"

# Steam
if [[ -f ~/.local/share/applications/steam.desktop ]]; then
    sync ~/.local/share/applications/steam.desktop \
         "$DOTS/local/share/applications/steam.desktop"
fi

echo "✓ Done. Commit and push when ready:"
echo "    cd $DOTS && git add -A && git commit -m 'update' && git push"
