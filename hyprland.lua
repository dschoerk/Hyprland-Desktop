-- Hyprland config (Lua format, Hyprland >= 0.55)
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Built-in laptop panel; "preferred" would pick its 60 Hz mode
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@120.00",
    position = "0x0",
    scale    = 2,
})

-- Fallback for any other/future monitor
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "hyprlauncher"
local browser     = "firefox"

-- Quick-launch slots for SUPER+F1..F4 (see KEYBINDINGS below), persisted across reloads
local quickLaunchFile = (os.getenv("HOME") or "") .. "/.config/hypr/quicklaunch.conf"
local quickApps = { [1] = browser }
do
    local f = io.open(quickLaunchFile, "r")
    if f then
        for line in f:lines() do
            local slot, class = line:match("^(%d+)=(.+)$")
            if slot then quickApps[tonumber(slot)] = class end
        end
        f:close()
    end
end
local function saveQuickApps()
    local f = io.open(quickLaunchFile, "w")
    if f then
        for slot = 1, 4 do
            if quickApps[slot] then f:write(slot .. "=" .. quickApps[slot] .. "\n") end
        end
        f:close()
    end
end


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function ()
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)

-- ksecretd is already started by PAM at login, and Noctalia handles
-- notifications and the wallpaper, so no mako/hyprpaper here.
hl.on("hyprland.start", function ()
  hl.exec_cmd("noctalia")
  -- Polkit authentication agent; without it polkitd has no way to prompt,
  -- so privileged actions fail. hyprpolkitagent isn't packaged on Ubuntu.
  hl.exec_cmd("/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 4,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,

            -- Blur whatever is behind the special workspace, so it reads
            -- as an overlay floating above the normal workspace.
            special  = true,
        },

        -- How much to dim the workspace underneath while the special
        -- workspace is open. Default is 0.2; higher = more separation.
        dim_special = 0.4,

        -- Native inner glow (Hyprland 0.56+). NOTE: this is global -- there
        -- is no no_glow window rule, so it cannot be limited to the special
        -- workspace. It also glows *inward* from the window edge rather than
        -- haloing outward into the gaps.
        glow = {
            enabled      = true,
            range        = 10,
            render_power = 3,

            -- Matches the active border gradient above.
            color          = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            -- Default for this is opaque white, which rims every unfocused
            -- window. Transparent = only the focused window glows.
            color_inactive = "rgba(00000000)",
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default spring
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Inset the special workspace with large outer gaps for the "floating panel"
-- look. This replaces special_scale_factor < 1, which scales every window
-- around its own tile centre and so also blows up the gaps between windows.
hl.workspace_rule({ workspace = "s[true]", gaps_out = 30 })

-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this

        -- Keep at 1: the inset look comes from the s[true] gaps_out rule.
        special_scale_factor = 1,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",

        -- Mirror the dwindle setting (see the s[true] gaps_out rule).
        special_scale_factor = 1,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,     -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "de",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        numlock_by_default = true,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local ipc     = "noctalia msg "

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Screenshot: select a region, annotate in swappy, upload to Nextcloud and copy share link
hl.bind("PRINT", hl.dsp.exec_cmd("$HOME/.local/bin/screenshot-share.sh"))
-- Monitor screenshots (noctalia built-in, saves to ~/Pictures)
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen all"))

-- Screen recording (gpu-screen-recorder); the same key stops and saves.
hl.bind("ALT + Print",         hl.dsp.exec_cmd("sh " .. os.getenv("HOME") .. "/.config/hypr/scripts/record-toggle.sh"))
hl.bind("ALT + SHIFT + Print", hl.dsp.exec_cmd("sh " .. os.getenv("HOME") .. "/.config/hypr/scripts/record-toggle.sh region"))

hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))    -- dwindle only (J is vim-down)

-- Cycle the global tiling layout. Note that `hyprctl keyword` does NOT work
-- with the Lua parser ("keyword can't work with non-legacy parsers"), so the
-- usual exec-based approach from the wiki is out; we set config directly.
local layouts = { "dwindle", "master", "scrolling" }

hl.bind(mainMod .. " + SHIFT + T", function()
    -- Read the live value rather than tracking an index, so this stays
    -- correct across config reloads.
    local current = hl.get_config("general.layout")
    local nextIndex = 1
    for i, name in ipairs(layouts) do
        if name == current then
            nextIndex = i % #layouts + 1
            break
        end
    end

    local target = layouts[nextIndex]
    hl.config({ general = { layout = target } })
    hl.notification.create({ text = "Layout: " .. target, timeout = 1500 })
end)

-- Quick-launch: SUPER+F1..F4 switches to the assigned app, or launches it if it isn't running.
-- With multiple windows of that app open, repeated presses cycle through them.
-- SUPER+SHIFT+F1..F4 (re)assigns that slot to the currently active app.
local function windowsOfClass(class)
    local matches = {}
    for _, w in ipairs(hl.get_windows()) do
        if w.class == class then matches[#matches + 1] = w end
    end
    return matches
end

for n = 1, 4 do
    local key = "F" .. n

    hl.bind(mainMod .. " + " .. key, function ()
        local class = quickApps[n]
        if not class then return end

        local matches = windowsOfClass(class)
        if #matches == 0 then
            hl.dispatch(hl.dsp.exec_cmd(class))
            return
        end
        if #matches == 1 then
            hl.dispatch(hl.dsp.focus({ window = matches[1] }))
            return
        end

        -- Multiple windows of this class: cycle to the next one after
        -- whichever is currently focused (wraps around); otherwise focus the first.
        local active = hl.get_active_window()
        local activeAddr = active and active.address
        local currentIndex = nil
        for i, w in ipairs(matches) do
            if w.address == activeAddr then
                currentIndex = i
                break
            end
        end
        local nextIndex = currentIndex and (currentIndex % #matches) + 1 or 1
        hl.dispatch(hl.dsp.focus({ window = matches[nextIndex] }))
    end)

    hl.bind(mainMod .. " + SHIFT + " .. key, function ()
        local w = hl.get_active_window()
        if not w then return end
        quickApps[n] = w.class
        saveQuickApps()
    end)
end

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move the active window with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Vim-style equivalents: mainMod (+ SHIFT) + H/J/K/L
local vimKeys = { H = "left", J = "down", K = "up", L = "right" }
for key, direction in pairs(vimKeys) do
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ direction = direction }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Same workspace switching, but reachable from the numpad.
-- Bound to both the digit keysyms (Num Lock on) and the navigation
-- keysyms the same physical keys send with Num Lock off, so it works
-- regardless of Num Lock state.
local numpadKeysyms = {
    [1] = "KP_1",   [2] = "KP_2",  [3] = "KP_3",
    [4] = "KP_4",   [5] = "KP_5",  [6] = "KP_6",
    [7] = "KP_7",   [8] = "KP_8",  [9] = "KP_9",
    [0] = "KP_0",
}
local numpadNavKeysyms = {
    [1] = "KP_End",    [2] = "KP_Down",  [3] = "KP_Next",
    [4] = "KP_Left",   [5] = "KP_Begin", [6] = "KP_Right",
    [7] = "KP_Home",   [8] = "KP_Up",    [9] = "KP_Prior",
    [0] = "KP_Insert",
}
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. numpadKeysyms[i],    hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + " .. numpadNavKeysyms[i], hl.dsp.focus({ workspace = i }))
end

-- Numpad 0 instead cycles through the open workspaces on the focused
-- monitor only ("m+1" skips empty ones and wraps around).
hl.bind(mainMod .. " + " .. numpadKeysyms[0],    hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + " .. numpadNavKeysyms[0], hl.dsp.focus({ workspace = "m+1" }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Switch to the next/previous workspace with mainMod + CTRL + left/right
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))

-- Move the active window to the next/previous workspace with mainMod + CTRL + SHIFT + left/right
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }))

-- Same with vim keys: mainMod + CTRL (+ SHIFT) + H/L
hl.bind(mainMod .. " + CTRL + H",         hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + L",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move windows by holding mainMod + SHIFT and dragging anywhere (no need to grab the titlebar)
hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
-- Routed through Noctalia's IPC so its volume/brightness OSD shows up
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(ipc .. "volume-up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(ipc .. "volume-down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(ipc .. "volume-mute"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(ipc .. "brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"), { locked = true, repeating = true })

-- Noctalia panels
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + A",     hl.dsp.exec_cmd(ipc .. "panel-toggle control-center")) -- mainMod+S is already the scratchpad toggle
hl.bind(mainMod .. " + COMMA", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("ALT + TAB",           hl.dsp.exec_cmd(ipc .. "window-switcher"))

-- Media keys via Noctalia's MPRIS control (playerctl isn't installed here)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(ipc .. "media next"),     { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(ipc .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Noctalia settings window
hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size  = { 1080, 920 },
})

-- Blur Noctalia's bar, panels, dock, notifications and window switcher;
-- its own animations replace Hyprland's layer animations for these surfaces
hl.layer_rule({
    name  = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim      = true,
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})


-- >>> HYPRLAND VISUAL EDITOR (HVE) <<<
pcall(function() dofile(os.getenv("HOME") .. "/.cache/noctalia/HVE/overlay.lua") end)
-- <<< HYPRLAND VISUAL EDITOR (HVE) <<<
