#!/bin/sh
# Toggle screen recording with gpu-screen-recorder. The second invocation sends
# SIGINT, which is how gpu-screen-recorder stops and finalises the file -- so
# one keybind both starts and stops.
#
#   record-toggle.sh          record the focused monitor
#   record-toggle.sh region   drag out a region with slurp (Esc cancels)
#   record-toggle.sh DP-1     record a named output instead
#
# Pass "mic" as an extra argument to mix the default input into the desktop
# audio track. Both sources share one track so every player picks them up.
#
# The recorder is tracked by PID rather than by name: the kernel truncates
# process names to 15 characters ("gpu-screen-reco"), so pkill/pgrep given the
# full name silently match nothing and every press would start another capture.

pidfile="${XDG_RUNTIME_DIR:-/tmp}/hypr-record.pid"
dir=$(xdg-user-dir VIDEOS 2>/dev/null) || dir="$HOME/Videos"

if [ -r "$pidfile" ]; then
    pid=$(cat "$pidfile")
    if kill -0 "$pid" 2>/dev/null; then
        kill -INT "$pid"
        rm -f "$pidfile"
        notify-send -t 2000 "Screen Recording" "Stopped, saved to $dir"
        exit 0
    fi
    rm -f "$pidfile"
fi

if ! command -v gpu-screen-recorder >/dev/null 2>&1; then
    notify-send -t 4000 "Screen Recording" "gpu-screen-recorder is not installed"
    exit 1
fi

target=""
audio="default_output"

for arg in "$@"; do
    case "$arg" in
        mic) audio="default_output|default_input" ;;
        region) target="region" ;;
        *)   target="$arg" ;;
    esac
done

# gpu-screen-recorder's own "screen" target just grabs the first output it
# finds, so resolve the focused monitor ourselves (matters once an external
# monitor is plugged in).
if [ -z "$target" ]; then
    target=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
fi

# gpu-screen-recorder takes a WxH+X+Y geometry directly as the -w target.
# slurp exits non-zero when the selection is cancelled; do nothing then.
if [ "$target" = "region" ]; then
    target=$(slurp -f '%wx%h+%x+%y') || exit 0
fi

mkdir -p "$dir"
out="$dir/Recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"

notify-send -t 2000 "Screen Recording" "Started on $target"
gpu-screen-recorder -w "$target" -f 60 -a "$audio" -o "$out" &
pid=$!
echo "$pid" > "$pidfile"
wait "$pid"
rm -f "$pidfile"
