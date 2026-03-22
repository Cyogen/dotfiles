#!/bin/bash
# ============================================================
# Arch Linux / Hyprland desktop setup — full install script
# Run as your normal user (NOT root). Uses sudo internally.
#
# Hardware-specific values that may need adjusting on new hardware:
#   - Monitor names (DP-1, DP-3) in config/hypr/hyprland.conf
#   - Wallpaper path in config/hypr/hyprland.conf  ← needs /mnt/vault mounted
#   - eww.yuck hwmon paths — auto-detected by this script (AMD CPU + GPU assumed)
# ============================================================

set -e

DOTS="$(cd "$(dirname "$0")" && pwd)"
USER_HOME="$HOME"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}→ $*${NC}"; }
success() { echo -e "${GREEN}✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}! $*${NC}"; }
die()     { echo -e "${RED}✗ $*${NC}"; exit 1; }

[[ "$EUID" -eq 0 ]] && die "Do not run as root."
[[ ! -f /etc/arch-release ]] && die "This script is for Arch Linux only."

# ── 1. System update ─────────────────────────────────────────────────────────

info "Updating system..."
sudo pacman -Syu --noconfirm

# ── 2. Install yay (AUR helper) ──────────────────────────────────────────────

if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    success "yay installed"
else
    success "yay already present"
fi

# ── 3. Pacman packages ───────────────────────────────────────────────────────

PACMAN_PKGS=(
    # Wayland / Hyprland
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    waybar swww eww socat
    wofi wlogout
    kitty

    # Audio / video
    pipewire pipewire-alsa pipewire-pulse wireplumber
    playerctl

    # System tools
    lm_sensors udiskie brightnessctl
    network-manager-applet polkit-kde-agent
    grimblast-git

    # Fonts
    ttf-0xproto-nerd ttf-jetbrains-mono-nerd

    # Apps
    firefox discord steam

    # Dev / editor
    neovim fd nodejs npm lazygit python curl git

    # Build tools (needed for AUR packages like eww)
    rust base-devel
)

info "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || \
    warn "Some packages may have failed — check output above"

# ── 4. AUR packages ──────────────────────────────────────────────────────────

AUR_PKGS=(
    betterdiscordctl
)

info "Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}" || \
    warn "Some AUR packages may have failed — check output above"

# ── 5. Deploy configs ────────────────────────────────────────────────────────

deploy() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    # Backup existing file if present
    [[ -f "$dst" && ! -f "${dst}.bak" ]] && cp "$dst" "${dst}.bak"
    cp -f "$src" "$dst"
}

info "Deploying configs..."

deploy "$DOTS/config/hypr/hyprland.conf"    "$USER_HOME/.config/hypr/hyprland.conf"
deploy "$DOTS/config/hypr/hyprpaper.conf"   "$USER_HOME/.config/hypr/hyprpaper.conf"
deploy "$DOTS/config/waybar/config"         "$USER_HOME/.config/waybar/config"
deploy "$DOTS/config/waybar/style.css"      "$USER_HOME/.config/waybar/style.css"
deploy "$DOTS/config/waybar/colors.css"     "$USER_HOME/.config/waybar/colors.css"
deploy "$DOTS/config/kitty/kitty.conf"      "$USER_HOME/.config/kitty/kitty.conf"
deploy "$DOTS/config/eww/eww.yuck"          "$USER_HOME/.config/eww/eww.yuck"
deploy "$DOTS/config/eww/eww.scss"          "$USER_HOME/.config/eww/eww.scss"
deploy "$DOTS/config/eww/scripts/weather.sh" \
                                            "$USER_HOME/.config/eww/scripts/weather.sh"
deploy "$DOTS/config/eww/scripts/workspace-watch.sh" \
                                            "$USER_HOME/.config/eww/scripts/workspace-watch.sh"
deploy "$DOTS/config/wlogout/layout"        "$USER_HOME/.config/wlogout/layout"
deploy "$DOTS/home/.bashrc"                 "$USER_HOME/.bashrc"
deploy "$DOTS/home/.dircolors"              "$USER_HOME/.dircolors"

if [[ -f "$DOTS/local/share/applications/steam.desktop" ]]; then
    deploy "$DOTS/local/share/applications/steam.desktop" \
           "$USER_HOME/.local/share/applications/steam.desktop"
fi

chmod +x "$USER_HOME/.config/eww/scripts/weather.sh"
chmod +x "$USER_HOME/.config/eww/scripts/workspace-watch.sh"

success "Configs deployed"

# ── 6. Auto-detect AMD hwmon paths and patch eww.yuck ────────────────────────

info "Detecting CPU/GPU hwmon paths..."

CPU_HWMON=""
GPU_HWMON=""

for name_file in /sys/class/hwmon/hwmon*/name; do
    dev=$(dirname "$name_file")
    name=$(cat "$name_file" 2>/dev/null)
    case "$name" in
        k10temp)
            CPU_HWMON="$dev/temp1_input" ;;
        amdgpu)
            # Discrete GPU has a fan controller; integrated does not
            [[ -f "$dev/fan1_input" ]] && GPU_HWMON="$dev/temp1_input" ;;
    esac
done

if [[ -n "$CPU_HWMON" && -n "$GPU_HWMON" ]]; then
    YUCK="$USER_HOME/.config/eww/eww.yuck"
    # Replace the hwmon paths with detected values
    sed -i "s|/sys/class/hwmon/hwmon[0-9]*/temp1_input'  # cpu|$CPU_HWMON'  # cpu|g" "$YUCK" 2>/dev/null || true
    # Simpler: just patch known awk lines
    sed -i "s|awk '{printf \"%d\", \$1/1000}' /sys/class/hwmon/hwmon[0-9]*/temp1_input\`  # cpu-temp|awk '{printf \"%d\", \$1/1000}' $CPU_HWMON\`  # cpu-temp|g" "$YUCK" 2>/dev/null || true

    # Patch eww.yuck inline awk commands
    python3 - "$YUCK" "$CPU_HWMON" "$GPU_HWMON" << 'PYEOF'
import sys, re

yuck_path, cpu_path, gpu_path = sys.argv[1], sys.argv[2], sys.argv[3]

with open(yuck_path) as f:
    content = f.read()

# Replace CPU hwmon path (first awk line after defpoll cpu-temp)
content = re.sub(
    r"(defpoll cpu-temp.*?`awk '\{printf \"%d\", \$1/1000\}' )/sys/class/hwmon/hwmon\d+/temp1_input(`)",
    rf"\g<1>{cpu_path}\g<2>",
    content, flags=re.DOTALL
)

# Replace GPU hwmon path (first awk line after defpoll gpu-temp)
content = re.sub(
    r"(defpoll gpu-temp.*?`awk '\{printf \"%d\", \$1/1000\}' )/sys/class/hwmon/hwmon\d+/temp1_input(`)",
    rf"\g<1>{gpu_path}\g<2>",
    content, flags=re.DOTALL
)

with open(yuck_path, 'w') as f:
    f.write(content)

print(f"  CPU hwmon: {cpu_path}")
print(f"  GPU hwmon: {gpu_path}")
PYEOF
    success "hwmon paths patched in eww.yuck"
else
    warn "Could not auto-detect hwmon paths — edit ~/.config/eww/eww.yuck manually"
    warn "  CPU (k10temp): $(ls /sys/class/hwmon/hwmon*/name 2>/dev/null | xargs grep -l k10temp 2>/dev/null | sed 's/name/temp1_input/' || echo 'not found')"
    warn "  GPU (amdgpu with fan): $(for f in /sys/class/hwmon/hwmon*/name; do grep -q amdgpu "$f" 2>/dev/null && ls "$(dirname $f)/fan1_input" 2>/dev/null && dirname "$f"; done | sed 's|$|/temp1_input|' || echo 'not found')"
fi

# ── 7. Neovim / LazyVim ──────────────────────────────────────────────────────

if [[ ! -d "$USER_HOME/.config/nvim" ]]; then
    info "Installing LazyVim..."
    git clone https://github.com/LazyVim/starter "$USER_HOME/.config/nvim"
    rm -rf "$USER_HOME/.config/nvim/.git"
    success "LazyVim installed — run 'nvim' to finish plugin installation"
else
    warn "~/.config/nvim already exists — skipping LazyVim install"
fi

# ── 8. dircolors ─────────────────────────────────────────────────────────────

if [[ ! -f "$USER_HOME/.dir_colors" ]]; then
    ln -sf "$USER_HOME/.dircolors" "$USER_HOME/.dir_colors" 2>/dev/null || true
fi

# ── 9. sensors init ──────────────────────────────────────────────────────────

info "Initializing lm_sensors..."
sudo sensors-detect --auto &>/dev/null || true

# ── 10. BetterDiscord ────────────────────────────────────────────────────────

warn "BetterDiscord: after first launching Discord, run:  betterdiscordctl install"

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
success "Installation complete!"
echo ""
echo -e "${YELLOW}Manual steps remaining:${NC}"
echo "  1. Reboot or log into Hyprland"
echo "  2. Ensure /mnt/vault/Wallpapers/pirate.png is accessible (wallpaper path)"
echo "  3. Run 'nvim' to let LazyVim install plugins"
echo "  4. Run 'betterdiscordctl install' after first Discord launch"
echo "  5. Monitor names (DP-1, DP-3) may differ — adjust ~/.config/hypr/hyprland.conf"
echo "  6. Push your dotfiles to GitHub:"
echo "     cd $DOTS && git init && git add -A && git commit -m 'initial' && git remote add origin <your-repo-url> && git push -u origin main"
