# Hyprland-Desktop

My Hyprland setup on CachyOS. It uses the Lua config format (`hyprland.lua`), so it needs **Hyprland 0.56 or newer**.

- Bar, launcher, notifications panel, screenshots: [Noctalia](https://github.com/noctalia-dev/noctalia)
- Layouts: dwindle, master and scrolling; `SUPER + SHIFT + J` cycles between them
- The special workspace is an inset overlay with blur and dimming
- Numpad workspace switching works with Num Lock on or off
- Screen recording via `gpu-screen-recorder` (whole monitor or a region)

## Install

### 1. Packages (Arch / CachyOS)

```sh
sudo pacman -S --needed \
    hyprland hyprpaper hyprlauncher hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    noctalia mako kwallet \
    kitty dolphin \
    gpu-screen-recorder slurp jq libnotify xdg-user-dirs \
    pipewire-pulse wireplumber playerctl brightnessctl
```

`noctalia`, `hyprlauncher` and `gpu-screen-recorder` are in the CachyOS repos. On plain Arch, get them from the AUR (for example with `paru -S noctalia-git`) if they aren't in your repos.

| Package | Used for |
|---|---|
| `hyprland` | The compositor (0.56 or newer) |
| `hyprpaper` | Wallpaper |
| `hyprlauncher` | `SUPER + R` app launcher |
| `hyprpolkitagent` | Password prompts for privileged actions |
| `noctalia` | Bar, `SUPER + D` launcher, screenshots, audio switcher and Bitwarden panels |
| `mako` | Notifications |
| `kwallet` | `ksecretd`, the Secret Service provider (Noctalia keeps calendar credentials there) |
| `kitty`, `dolphin` | Terminal (`SUPER + Q`) and file manager (`SUPER + E`) |
| `gpu-screen-recorder`, `slurp`, `jq` | Screen recording script |
| `libnotify` | `notify-send`, used by the scripts |
| `pipewire-pulse`, `wireplumber` | `pactl` and `wpctl`, for the volume keys and audio-output toggle |
| `playerctl`, `brightnessctl` | Media keys and screen brightness keys |

### 2. Noctalia plugins

Two keybinds open Noctalia plugin panels. Install these plugins from Noctalia's settings, or remove the binds:

- `blackbartblues/audio-switcher` (`SUPER + A`)
- `noctalia/bitwarden` (`SUPER + B`)

### 3. Clone the config

```sh
mv ~/.config/hypr ~/.config/hypr.bak 2>/dev/null
git clone https://github.com/dschoerk/Hyprland-Desktop.git ~/.config/hypr
```

Then log in to a Hyprland session.

### 4. Adjust for your machine

These settings are specific to my hardware:

- **Monitors** (`hyprland.lua`, MONITORS section): `DP-1` and `DP-2` at 2560x1440. List your outputs with `hyprctl monitors`. The catch-all rule at the end of that section handles unknown monitors, so you can also delete my two entries.
- **Keyboard layout:** `kb_layout = "de"`.
- **Audio output toggle** (`scripts/toggle-audio-output.sh`): the sink name `alsa_output.pci-0000_11_00.6.analog-stereo` belongs to my onboard audio. Find yours with `pactl list sinks short`.
- **Wallpaper** (`hyprpaper.conf`): points to a file from `cachyos-wallpapers`. Change the path to an image you have.

## Keybinds

`SUPER` is the main modifier.

| Keys | Action |
|---|---|
| `SUPER + Q` | Terminal (kitty) |
| `SUPER + C` | Close window |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + R` | hyprlauncher |
| `SUPER + D` | Noctalia launcher |
| `SUPER + A` | Audio switcher panel |
| `SUPER + SHIFT + A` | Switch between speakers and headphones |
| `SUPER + B` | Bitwarden unlock panel |
| `SUPER + V` | Toggle floating |
| `SUPER + P` | Pseudo-tile |
| `SUPER + J` | Toggle split (dwindle) |
| `SUPER + SHIFT + J` | Cycle layout: dwindle → master → scrolling |
| `SUPER + arrows` | Move focus |
| `SUPER + SHIFT + arrows` | Move window |
| `SUPER + 1–0` | Go to workspace 1–10 |
| `SUPER + SHIFT + 1–0` | Move window to workspace 1–10 |
| `SUPER + Numpad 1–9` | Go to workspace 1–9 |
| `SUPER + Numpad 0` | Cycle through open workspaces on the current monitor |
| `SUPER + S` | Toggle the special workspace |
| `SUPER + SHIFT + S` | Move window to the special workspace |
| `SUPER + scroll` | Scroll through workspaces |
| `SUPER + LMB / RMB drag` | Move / resize window |
| `Print` | Screenshot a region |
| `SHIFT + Print` | Screenshot the current monitor |
| `CTRL + Print` | Screenshot all monitors |
| `ALT + Print` | Start or stop recording the focused monitor |
| `ALT + SHIFT + Print` | Start or stop recording a region |

Screenshots go to `~/Pictures` and recordings go to `~/Videos`.
