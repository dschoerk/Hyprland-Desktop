# hyprland-config

My Hyprland setup, shared between a ThinkPad (Ubuntu) and a desktop (CachyOS). It uses the Lua config format (`hyprland.lua`), so it needs **Hyprland 0.56 or newer**.

- Bar, launcher, notifications, wallpaper, OSD, screenshots: [Noctalia](https://github.com/noctalia-dev/noctalia)
- Layouts: dwindle, master and scrolling; `SUPER + SHIFT + T` cycles between them
- The special workspace is an inset overlay with blur and dimming
- Quick-launch slots on `SUPER + F1–F4`
- Vim-style navigation on `H J K L` alongside the arrow keys
- Numpad workspace switching works with Num Lock on or off
- Screen recording via `gpu-screen-recorder` (whole monitor or a region)

## Per-host files

`hyprland.lua` holds everything shared. The machine-specific parts live in `hosts/<name>.lua`, chosen by the hostname in `/etc/hostname`:

| File | Machine | Contents |
|---|---|---|
| `hosts/laptop.lua` | `dominik-thinkpad` | `eDP-1` panel at 120 Hz, `pam_kwallet_init`, KDE polkit agent, Nextcloud screenshot on `Print` |
| `hosts/desktop.lua` | anything else | `DP-1` + `DP-2` 1440p with VRR, `ksecretd`/`mako`/`hyprpolkitagent`, wider gaps, audio and Bitwarden binds |

A host file returns a table with these optional hooks, which `hyprland.lua` calls at the right points:

- `monitors()`: `hl.monitor` rules (a catch-all fallback rule follows in the base)
- `config()`: `hl.config` overrides, applied after the shared look/misc settings
- `autostart()`: commands run on `hyprland.start`, after Noctalia
- `binds(mainMod, ipc)`: extra keybinds (`ipc` is `"noctalia msg "`)

**Adding a machine:** create `hosts/<name>.lua` (copy one of the existing files) and add `["<hostname>"] = "<name>"` to `hostFiles` at the top of `hyprland.lua`. Unknown hostnames load `hosts/desktop.lua`.

## Install

### Packages

Arch / CachyOS:

```sh
sudo pacman -S --needed \
    hyprland hyprlauncher hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    noctalia mako kwallet \
    kitty dolphin \
    gpu-screen-recorder slurp jq libnotify xdg-user-dirs \
    pipewire-pulse wireplumber
```

`noctalia`, `hyprlauncher` and `gpu-screen-recorder` are in the CachyOS repos; on plain Arch, use the AUR.

Ubuntu: `hyprpolkitagent` isn't packaged, so the laptop host uses `polkit-kde-agent-1` instead. `mako` isn't needed there because Noctalia shows notifications. The Nextcloud `Print` bind needs `~/.local/bin/screenshot-share.sh` and `nextcloud-screenshot.conf` (the app password lives in KWallet, not in the file).

| Package | Used for |
|---|---|
| `hyprland` | The compositor (0.56 or newer) |
| `hyprlauncher` | `SUPER + R` app launcher |
| `hyprpolkitagent` / `polkit-kde-agent-1` | Password prompts for privileged actions |
| `noctalia` | Bar, launcher, wallpaper, OSD, screenshots, media keys, plugin panels |
| `mako` | Notifications (desktop) |
| `kwallet` | `ksecretd`, the Secret Service provider |
| `kitty`, `dolphin` | Terminal (`SUPER + Q`) and file manager (`SUPER + E`) |
| `gpu-screen-recorder`, `slurp`, `jq` | Screen recording script |
| `libnotify` | `notify-send`, used by the scripts |
| `pipewire-pulse`, `wireplumber` | `pactl` and `wpctl`, for mic mute and the audio-output toggle |

### Noctalia plugins (desktop)

The desktop's `SUPER + SHIFT + A` and `SUPER + B` open Noctalia plugin panels. Install these plugins from Noctalia's settings, or remove the binds from `hosts/desktop.lua`:

- `blackbartblues/audio-switcher`
- `noctalia/bitwarden`

### Clone

```sh
mv ~/.config/hypr ~/.config/hypr.bak 2>/dev/null
git clone https://github.com/dschoerk/hyprland-config.git ~/.config/hypr
```

Then log in to a Hyprland session.

### Machine-specific values

- **Monitors:** in your `hosts/*.lua`. List your outputs with `hyprctl monitors`.
- **Keyboard layout:** `kb_layout = "de"` in `hyprland.lua`.
- **Audio output toggle** (`scripts/toggle-audio-output.sh`): the sink name `alsa_output.pci-0000_11_00.6.analog-stereo` belongs to the desktop's onboard audio. Find yours with `pactl list sinks short`.

## Keybinds

`SUPER` is the main modifier.

| Keys | Action |
|---|---|
| `SUPER + Q` | Terminal (kitty) |
| `SUPER + C` | Close window |
| `SUPER + M` | Exit / shutdown menu |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + R` | hyprlauncher |
| `SUPER + D` | Noctalia launcher |
| `SUPER + A` | Noctalia control center |
| `SUPER + ,` | Noctalia settings |
| `ALT + TAB` | Noctalia window switcher |
| `SUPER + V` | Toggle floating |
| `SUPER + P` | Pseudo-tile |
| `SUPER + T` | Toggle split (dwindle) |
| `SUPER + SHIFT + T` | Cycle layout: dwindle → master → scrolling |
| `SUPER + F1–F4` | Focus the slot's app (cycles its windows), or launch it |
| `SUPER + SHIFT + F1–F4` | Assign the focused app to that slot |
| `SUPER + arrows` / `H J K L` | Move focus |
| `SUPER + SHIFT + arrows` / `H J K L` | Move window |
| `SUPER + 1–0` | Go to workspace 1–10 |
| `SUPER + SHIFT + 1–0` | Move window to workspace 1–10 |
| `SUPER + CTRL + left/right` or `H/L` | Previous / next workspace |
| `SUPER + CTRL + SHIFT + left/right` or `H/L` | Move window to previous / next workspace |
| `SUPER + Numpad 1–9` | Go to workspace 1–9 |
| `SUPER + Numpad 0` | Cycle through open workspaces on the current monitor |
| `SUPER + S` | Toggle the special workspace |
| `SUPER + SHIFT + S` | Move window to the special workspace |
| `SUPER + scroll` | Scroll through workspaces |
| `SUPER + LMB / RMB drag` | Move / resize window |
| `SUPER + SHIFT + LMB drag` | Move window |
| `Print` | Region screenshot (laptop: annotate and upload to Nextcloud; desktop: Noctalia, saved to `~/Pictures`) |
| `SHIFT + Print` | Screenshot the current monitor |
| `CTRL + Print` | Screenshot all monitors |
| `ALT + Print` | Start or stop recording the focused monitor |
| `ALT + SHIFT + Print` | Start or stop recording a region |
| **Desktop only** | |
| `SUPER + SHIFT + A` | Audio switcher panel |
| `SUPER + CTRL + A` | Switch between speakers and headphones |
| `SUPER + B` | Bitwarden unlock panel |

Screenshots go to `~/Pictures` and recordings go to `~/Videos`.
