-- Desktop (CachyOS), two 1440p monitors. Loaded by hyprland.lua; see the
-- HOST section there. Also the fallback for any unknown hostname.

local host = {}

function host.monitors()
    hl.monitor({
        output   = "DP-1",
        mode     = "2560x1440@59.95",
        position = "0x0",
        scale    = 1,
        vrr      = false,
    })
    hl.monitor({
        output   = "DP-2",
        mode     = "2560x1440@165.00",
        position = "2560x0",
        scale    = 1,
        vrr      = true,
    })
end

function host.config()
    hl.config({
        general = {
            gaps_out = 20,
        },
        misc = {
            vrr = 1, -- 0 = off, 1 = always on, 2 = fullscreen only
        },
    })
end

function host.autostart()
    -- ksecretd (Secret Service provider for Noctalia, Nextcloud, ...) is
    -- started and unlocked by pam_kwallet at login, but it blocks until
    -- pam_kwallet_init hands it the session environment. Plasma runs that from
    -- XDG autostart; Hyprland doesn't, so run it here. Don't start a second
    -- ksecretd: it races the PAM one for the bus name and prompts for a password.
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("mako")
    -- Polkit authentication agent; without it polkitd has no way to prompt,
    -- so privileged actions fail (e.g. shelly's GUI package operations).
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
end

function host.binds(mainMod, ipc)
    -- Region screenshot (noctalia built-in, saves to ~/Pictures)
    hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))

    -- Noctalia plugin panels (SUPER+A is the control center, shared)
    hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(ipc .. "panel-toggle blackbartblues/audio-switcher:audio-switcher"))
    hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/bitwarden:unlock"))

    -- Switch the onboard sink between speakers and headphones
    hl.bind(mainMod .. " + CTRL + A", hl.dsp.exec_cmd("sh " .. os.getenv("HOME") .. "/.config/hypr/scripts/toggle-audio-output.sh"))
end

return host
