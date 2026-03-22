# dotfiles

My Arch Linux / Hyprland desktop configuration.

## Screenshot

<!-- Add a screenshot here after uploading one to the repo -->

## Stack

| Category | Tool |
|---|---|
| Compositor | Hyprland |
| Status bar | Waybar |
| Terminal | Kitty |
| Shell | Bash |
| Launcher | Wofi |
| Wallpaper | swww |
| Desktop widgets | eww |
| Logout menu | wlogout |
| Editor | Neovim (LazyVim) |
| Fonts | 0xProto Nerd Font, JetBrains Mono Nerd Font |

## Theme

Cyberpunk — dark background with purple (`#b450ff`) accents and neon green terminal text.

## Widgets (workspace 6)

Two eww widgets that appear only on workspace 6 (right monitor) and sit behind all windows:

- **System** — CPU temp, GPU temp, RAM usage with live progress bars (updates every 3s)
- **Weather** — 7-day forecast for Kendall, Miami FL via [Open-Meteo](https://open-meteo.com) (no API key required, updates every 30min)

## Hardware assumptions

This config is tuned for a dual-monitor AMD setup:

- `DP-1` — primary monitor (2560x1440 @ 120Hz)
- `DP-3` — secondary monitor (1920x1080 @ 144Hz), workspaces 6–10
- AMD CPU (`k10temp`) and discrete AMD GPU (`amdgpu`)

The install script auto-detects the correct hwmon paths for CPU/GPU temps. Monitor names may need adjusting in `~/.config/hypr/hyprland.conf` after install.

## Install

> Requires a fresh Arch Linux install with an AUR helper not yet set up. The script installs `yay` automatically.

```bash
git clone https://github.com/exhahe/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script will:

1. Update the system
2. Install `yay` if not present
3. Install all pacman and AUR packages
4. Deploy all configs (backing up any existing files as `.bak`)
5. Auto-detect AMD CPU/GPU hwmon paths and patch eww config
6. Install LazyVim

### Manual steps after install

1. Mount your wallpaper drive and verify the path in `~/.config/hypr/hyprland.conf`
2. Adjust monitor names if they differ from `DP-1` / `DP-3`
3. Run `nvim` once to let LazyVim download plugins
4. Launch Discord, then run `betterdiscordctl install`

## Updating your dotfiles

After making changes to any config:

```bash
~/dotfiles/backup.sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```
