-- ThinkPad (Ubuntu). Loaded by hyprland.lua; see the HOST section there.

local host = {}

function host.monitors()
    -- Built-in laptop panel; "preferred" would pick its 60 Hz mode
    hl.monitor({
        output   = "eDP-1",
        mode     = "2880x1800@120.00",
        position = "0x0",
        scale    = 2,
    })
end

-- ksecretd is already started by PAM at login, and Noctalia handles
-- notifications and the wallpaper, so no mako/hyprpaper here.
function host.autostart()
    -- Polkit authentication agent; without it polkitd has no way to prompt,
    -- so privileged actions fail. hyprpolkitagent isn't packaged on Ubuntu.
    hl.exec_cmd("/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1")
end

function host.binds(mainMod, ipc)
    -- Screenshot: select a region, annotate in swappy, upload to Nextcloud and copy share link
    hl.bind("PRINT", hl.dsp.exec_cmd("$HOME/.local/bin/screenshot-share.sh"))
end

return host
