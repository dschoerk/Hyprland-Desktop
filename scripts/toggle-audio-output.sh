#!/bin/sh
# Toggle the HD Audio Controller sink between its line-out (speakers) and
# headphones ports. Both are ports on one PipeWire sink, so the
# audio-switcher plugin's device/sink switching doesn't cover this.

sink="alsa_output.pci-0000_11_00.6.analog-stereo"

active=$(pactl list sinks | awk -v s="$sink" '
    /Name:/ { name = $2 }
    name == s && /Active Port:/ { print $3; exit }
')

if [ "$active" = "analog-output-headphones" ]; then
    pactl set-sink-port "$sink" analog-output-lineout
    notify-send "Audio Output" "Speakers"
else
    pactl set-sink-port "$sink" analog-output-headphones
    notify-send "Audio Output" "Headphones"
fi
