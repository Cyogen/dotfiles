#!/bin/bash
# ============================================================
# Arch Linux / Hyprland + KDE desktop setup — full install script
# Run as your normal user (NOT root). Uses sudo internally.
#
# Assumes a minimal Arch base install with:
#   base, linux, linux-firmware, amd-ucode, networkmanager, sudo, sddm
#   (these are set up during the Arch install itself)
#
# Hardware-specific values that may need adjusting on new hardware:
#   - Monitor names (DP-1, DP-3) in config/hypr/hyprland.conf
#   - Wallpaper path in config/hypr/hyprland.conf  ← needs /mnt/vault mounted
#   - GPU driver: script assumes AMD (vulkan-radeon, xf86-video-amdgpu)
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
    # Wayland / Hyprland stack
    hyprland hyprpaper hyprpolkitagent
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    waybar swww eww socat
    wofi
    kitty uwsm
    dunst
    grim slurp wl-clipboard
    qt5-wayland qt6-wayland
    xdg-utils

    # KDE / Plasma
    plasma-meta
    dolphin kate konsole
    sddm

    # Display manager / session
    networkmanager network-manager-applet
    iwd wpa_supplicant wireless_tools

    # Audio / video
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    gst-plugin-pipewire libpulse
    pavucontrol playerctl
    vlc vlc-plugins-all

    # Bluetooth
    bluez bluez-utils

    # GPU (AMD) — change for Intel/Nvidia
    vulkan-radeon lib32-vulkan-radeon
    xf86-video-amdgpu xf86-video-ati
    libva-utils

    # Fonts
    ttf-0xproto-nerd ttf-jetbrains-mono-nerd
    woff2-font-awesome

    # Terminal / shell tools
    htop btop fastfetch ranger nano wget curl fuse2

    # System tools
    lm_sensors udiskie brightnessctl
    smartmontools zram-generator
    btrfs-progs

    # Printing
    cups cups-pk-helper
    foomatic-db foomatic-db-engine
    ghostscript system-config-printer

    # Virtualization
    libvirt qemu-full virt-manager dnsmasq iptables

    # Apps
    firefox discord steam
    obs-studio qbittorrent remmina
    bitwarden blender
    spotify-launcher
    freerdp

    # Gaming
    lutris

    # Dev / editor
    git github-cli
    neovim fd nodejs npm lazygit
    python python-six
    marksman pandoc-cli
    base-devel rust

    # Security / CTF tools
    wireshark-cli binwalk hashcat john
    perl-image-exiftool

    # Misc
    tk speech-dispatcher
    xorg-server xorg-xinit
)

info "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || \
    warn "Some packages may have failed — check output above"

# ── 4. AUR packages ──────────────────────────────────────────────────────────

AUR_PKGS=(
    # Core desktop
    wlogout
    grimblast-git

    # Apps
    brave-bin
    freetube
    spotify-launcher   # fallback if not in official repos
    zoom
    durdraw
    java-chatty        # Twitch chat client

    # Fonts
    ttf-font-awesome-5

    # Gaming
    xivlauncher
    cheat-engine-zh
    lutris             # fallback if not in official repos

    # Dev / CTF
    seclists
    python-escpos
    packettracer       # Cisco Packet Tracer

    # Discord enhancement
    betterdiscordctl
)

info "Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}" || \
    warn "Some AUR packages may have failed — check output above"

# ── 5. Enable system services ─────────────────────────────────────────────────

info "Enabling system services..."
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable cups
sudo systemctl enable libvirtd

success "Services enabled"

# ── 6. Deploy configs ────────────────────────────────────────────────────────

deploy() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    [[ -f "$dst" && ! -f "${dst}.bak" ]] && cp "$dst" "${dst}.bak"
    cp -f "$src" "$dst"
}

deploydir() {
    local src="$1" dst="$2"
    mkdir -p "$dst"
    cp -a "$src/." "$dst/"
}

info "Deploying configs..."

# Hyprland
deploy "$DOTS/config/hypr/hyprland.conf"    "$USER_HOME/.config/hypr/hyprland.conf"
deploy "$DOTS/config/hypr/hyprpaper.conf"   "$USER_HOME/.config/hypr/hyprpaper.conf"

# Waybar
deploy "$DOTS/config/waybar/config"         "$USER_HOME/.config/waybar/config"
deploy "$DOTS/config/waybar/style.css"      "$USER_HOME/.config/waybar/style.css"
deploy "$DOTS/config/waybar/colors.css"     "$USER_HOME/.config/waybar/colors.css"

# Kitty
deploy "$DOTS/config/kitty/kitty.conf"      "$USER_HOME/.config/kitty/kitty.conf"

# eww
deploy "$DOTS/config/eww/eww.yuck"          "$USER_HOME/.config/eww/eww.yuck"
deploy "$DOTS/config/eww/eww.scss"          "$USER_HOME/.config/eww/eww.scss"
deploy "$DOTS/config/eww/scripts/weather.sh" \
                                            "$USER_HOME/.config/eww/scripts/weather.sh"
deploy "$DOTS/config/eww/scripts/workspace-watch.sh" \
                                            "$USER_HOME/.config/eww/scripts/workspace-watch.sh"

# wlogout
deploy "$DOTS/config/wlogout/layout"        "$USER_HOME/.config/wlogout/layout"

# Shell
deploy "$DOTS/home/.bashrc"                 "$USER_HOME/.bashrc"
deploy "$DOTS/home/.dircolors"              "$USER_HOME/.dircolors"

# Neovim (full config)
deploydir "$DOTS/config/nvim"               "$USER_HOME/.config/nvim"

# KDE
deploy "$DOTS/config/kde/kdeglobals"        "$USER_HOME/.config/kdeglobals"
deploy "$DOTS/config/kde/kglobalshortcutsrc" "$USER_HOME/.config/kglobalshortcutsrc"
deploy "$DOTS/config/kde/kwinrc"            "$USER_HOME/.config/kwinrc"
deploy "$DOTS/config/kde/kwinrulesrc"       "$USER_HOME/.config/kwinrulesrc"
deploy "$DOTS/config/kde/plasmarc"          "$USER_HOME/.config/plasmarc"
[[ -f "$DOTS/config/kde/plasma-org.kde.plasma.desktop-appletsrc" ]] && \
    deploy "$DOTS/config/kde/plasma-org.kde.plasma.desktop-appletsrc" \
           "$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

# Steam local override
if [[ -f "$DOTS/local/share/applications/steam.desktop" ]]; then
    deploy "$DOTS/local/share/applications/steam.desktop" \
           "$USER_HOME/.local/share/applications/steam.desktop"
fi

chmod +x "$USER_HOME/.config/eww/scripts/weather.sh"
chmod +x "$USER_HOME/.config/eww/scripts/workspace-watch.sh"

success "Configs deployed"

# ── 7. Auto-detect AMD hwmon paths and patch eww.yuck ────────────────────────

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
            [[ -f "$dev/fan1_input" ]] && GPU_HWMON="$dev/temp1_input" ;;
    esac
done

if [[ -n "$CPU_HWMON" && -n "$GPU_HWMON" ]]; then
    YUCK="$USER_HOME/.config/eww/eww.yuck"
    python3 - "$YUCK" "$CPU_HWMON" "$GPU_HWMON" << 'PYEOF'
import sys, re

yuck_path, cpu_path, gpu_path = sys.argv[1], sys.argv[2], sys.argv[3]

with open(yuck_path) as f:
    content = f.read()

content = re.sub(
    r"(defpoll cpu-temp.*?`awk '\{printf \"%d\", \$1/1000\}' )/sys/class/hwmon/hwmon\d+/temp1_input(`)",
    rf"\g<1>{cpu_path}\g<2>",
    content, flags=re.DOTALL
)

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
fi

# ── 8. dircolors symlink ──────────────────────────────────────────────────────

[[ ! -f "$USER_HOME/.dir_colors" ]] && \
    ln -sf "$USER_HOME/.dircolors" "$USER_HOME/.dir_colors" 2>/dev/null || true

# ── 9. lm_sensors init ───────────────────────────────────────────────────────

info "Initializing lm_sensors..."
sudo sensors-detect --auto &>/dev/null || true

# ── 10. Add user to libvirt group ────────────────────────────────────────────

info "Adding $USER to libvirt group..."
sudo usermod -aG libvirt "$USER" 2>/dev/null || true

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
success "Installation complete!"
echo ""
echo -e "${YELLOW}Manual steps remaining:${NC}"
echo "  1. Reboot and log in via SDDM — select Hyprland or Plasma session"
echo "  2. Ensure /mnt/vault/Wallpapers/pirate.png is accessible (wallpaper path)"
echo "  3. Run 'nvim' to let LazyVim install plugins on first launch"
echo "  4. Run 'betterdiscordctl install' after first Discord launch"
echo "  5. Monitor names (DP-1, DP-3) may differ — adjust ~/.config/hypr/hyprland.conf"
echo "  6. Re-login for libvirt group membership to take effect"
