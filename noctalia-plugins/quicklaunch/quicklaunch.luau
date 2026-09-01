--!nonstrict
-- Bar widget mirroring the SUPER+F1..F4 quick-launch slots defined in
-- ~/.config/hypr/hyprland.lua. That config writes slot assignments to
-- ~/.config/hypr/quicklaunch.conf (one "N=class" line per assigned slot)
-- whenever SUPER+SHIFT+F1..F4 is pressed. This widget shows one segment per
-- slot (app icon + name, highlighted when it's the focused app) and lets a
-- click focus-or-launch that slot's app the same way SUPER+F{n} does.
--
-- Focus tracking is event-driven: it subscribes once to Hyprland's own IPC
-- event socket (.socket2.sock) via noctalia.runStream and reacts to
-- `activewindow>>` lines, instead of polling `hyprctl activewindow` on a
-- timer (which spawned a subprocess every second, forever).

local CONF_PATH = (noctalia.getenv("HOME") or "") .. "/.config/hypr/quicklaunch.conf"

local slots = {}
local activeClass = nil
local iconCache = {}

local function shellQuote(s)
  return "'" .. tostring(s):gsub("'", "'\"'\"'") .. "'"
end

local function luaStringLiteral(s)
  return '"' .. tostring(s):gsub('[\\"]', '\\%0') .. '"'
end

local function loadSlots()
  local raw = noctalia.readFile(CONF_PATH)
  local newSlots = {}
  if type(raw) == "string" then
    for line in raw:gmatch("[^\r\n]+") do
      local n, class = line:match("^(%d+)=(.+)$")
      if n then
        newSlots[tonumber(n)] = class
      end
    end
  end
  slots = newSlots
end

-- Cached: appIconPath resolves against the system icon theme, no need to
-- redo that lookup every render.
local function iconFor(class)
  local cached = iconCache[class]
  if cached ~= nil then
    if cached == false then
      return nil
    end
    return cached
  end
  local ok, path = pcall(noctalia.appIconPath, class)
  if ok and type(path) == "string" and path ~= "" then
    iconCache[class] = path
    return path
  end
  iconCache[class] = false
  return nil
end

-- Same focus-or-launch logic as the SUPER+F{n} keybind in hyprland.lua,
-- issued through `hyprctl eval` since this plugin runs outside Hyprland's
-- own Lua state.
-- Mirrors the SUPER+F{n} bind's cycling behavior: with multiple windows of
-- this class open, each click steps to the next one after whatever is
-- currently focused (wrapping around); with one, it just focuses it.
local function focusOrLaunchCmd(class)
  local classLit = luaStringLiteral(class)
  local script = "local class = " .. classLit .. " "
    .. "local matches = {} "
    .. "for _, w in ipairs(hl.get_windows()) do if w.class == class then matches[#matches + 1] = w end end "
    .. "if #matches == 0 then hl.dispatch(hl.dsp.exec_cmd(class)) "
    .. "elseif #matches == 1 then hl.dispatch(hl.dsp.focus({ window = matches[1] })) "
    .. "else "
    .. "local active = hl.get_active_window() "
    .. "local activeAddr = active and active.address "
    .. "local currentIndex = nil "
    .. "for i, w in ipairs(matches) do if w.address == activeAddr then currentIndex = i break end end "
    .. "local nextIndex = currentIndex and (currentIndex % #matches) + 1 or 1 "
    .. "hl.dispatch(hl.dsp.focus({ window = matches[nextIndex] })) "
    .. "end"
  return "hyprctl eval " .. shellQuote(script)
end

local function render()
  local children = {}
  for n = 1, 4 do
    local class = slots[n]
    local isActive = class ~= nil and class == activeClass

    local fill
    if isActive then
      fill = "primary/0.35"
    elseif class then
      fill = "surface_variant/0.25"
    else
      fill = "surface_variant/0.08"
    end

    local textColor = isActive and "primary" or "on_surface_variant"
    local inner = {}

    if class then
      local iconPath = iconFor(class)
      if iconPath then
        inner[#inner + 1] = ui.image({ path = iconPath, width = 16, height = 16, fit = "contain" })
      else
        inner[#inner + 1] = ui.glyph({ name = "apps", size = 14, color = textColor })
      end
      inner[#inner + 1] = ui.label({
        text = class,
        fontSize = 12,
        color = textColor,
        fontWeight = isActive and "bold" or "normal",
      })
    else
      inner[#inner + 1] = ui.label({ text = "F" .. n, fontSize = 12, color = textColor })
    end

    children[#children + 1] = ui.row({
      gap = 4,
      align = "center",
      radius = 8,
      paddingH = 6,
      fill = fill,
      onClick = class and function()
        noctalia.runAsync(focusOrLaunchCmd(class), function() end)
      end or nil,
    }, inner)
  end

  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = 4, align = "center" }, children))
end

-- Event-driven focus tracking: subscribe once to Hyprland's own IPC socket
-- and react to `activewindow>>class,title` lines as they arrive, instead of
-- polling `hyprctl activewindow` on a timer.
local function watchActiveWindow()
  local sig = noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR") or "/run/user/1000"
  if not sig or sig == "" then
    return
  end
  local sock = runtimeDir .. "/hypr/" .. sig .. "/.socket2.sock"
  noctalia.runStream("socat -u UNIX-CONNECT:" .. shellQuote(sock) .. " -", function(line)
    local class = line:match("^activewindow>>([^,]*)")
    if class then
      activeClass = (class ~= "") and class or nil
      render()
    end
  end)
end

-- Initial paint: seed the active window once at load, then the event stream
-- above takes over for every subsequent focus change.
local function primeActiveWindow()
  noctalia.runAsync("hyprctl activewindow", function(result)
    local out = (result and result.stdout) or ""
    activeClass = out:match("class:%s*(%S+)")
    render()
  end)
end

loadSlots()
primeActiveWindow()
watchActiveWindow()

-- Slot assignments only change when SUPER+SHIFT+F{n} is pressed elsewhere.
-- A slow, subprocess-free file re-read is enough to pick that up; the
-- expensive per-second polling is gone.
function update()
  noctalia.setUpdateInterval(3000)
  loadSlots()
  render()
end
