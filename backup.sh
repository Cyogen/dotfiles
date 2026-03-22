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

echo "→ Syncing configs..."

sync ~/.config/hypr/hyprland.conf           "$DOTS/config/hypr/hyprland.conf"
sync ~/.config/hypr/hyprpaper.conf          "$DOTS/config/hypr/hyprpaper.conf"
sync ~/.config/waybar/config                "$DOTS/config/waybar/config"
sync ~/.config/waybar/style.css             "$DOTS/config/waybar/style.css"
sync ~/.config/waybar/colors.css            "$DOTS/config/waybar/colors.css"
sync ~/.config/kitty/kitty.conf             "$DOTS/config/kitty/kitty.conf"
sync ~/.config/eww/eww.yuck                 "$DOTS/config/eww/eww.yuck"
sync ~/.config/eww/eww.scss                 "$DOTS/config/eww/eww.scss"
sync ~/.config/eww/scripts/weather.sh       "$DOTS/config/eww/scripts/weather.sh"
sync ~/.config/eww/scripts/workspace-watch.sh \
                                            "$DOTS/config/eww/scripts/workspace-watch.sh"
sync ~/.config/wlogout/layout               "$DOTS/config/wlogout/layout"
sync ~/.bashrc                              "$DOTS/home/.bashrc"
sync ~/.dircolors                           "$DOTS/home/.dircolors"

if [[ -f ~/.local/share/applications/steam.desktop ]]; then
    sync ~/.local/share/applications/steam.desktop \
         "$DOTS/local/share/applications/steam.desktop"
fi

echo "✓ Done. Commit and push when ready:"
echo "    cd $DOTS && git add -A && git commit -m 'update' && git push"
