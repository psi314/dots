local mainMod = "SUPER"

local function dispatch(command)
    return hl.dsp.exec_cmd("hyprctl dispatch " .. command)
end

local function spawn(command)
    return hl.dsp.exec_cmd(command)
end

-- === Switch to tag ===
-- === Move windows ===

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- === Noctalia v5 ===

hl.bind(mainMod .. " + R", spawn("noctalia msg panel-toggle launcher"))
hl.bind(mainMod .. " + semicolon", spawn("noctalia msg panel-toggle control-center"))
hl.bind(mainMod .. " + L", spawn("noctalia msg panel-toggle session"))
hl.bind(mainMod .. " + SHIFT + W", spawn("noctalia msg panel-toggle wallpaper"))
hl.bind(mainMod .. " + A", spawn("noctalia msg wallpaper-random"))
hl.bind(mainMod .. " + SHIFT + S", spawn("noctalia msg screenshot-region pick"))

-- === Apps Bindings ===

hl.bind(mainMod .. " + W", spawn("firefox"))
hl.bind(mainMod .. " + E", spawn("thunar"))
hl.bind(mainMod .. " + return", spawn("kitty --single-instance"))

-- === Windows Control ===

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({mode=maximized}))
hl.bind(mainMod .. " + P", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({internal = 0, client = 2 , action = "toggle" }))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x=-50,y=0,relative=true }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x=50,y=0,relative=true }))

-- === Layout ===

hl.bind(mainMod .. " + s", function() 
    hl.workspace_rule({ workspace = hl.get_active_workspace().name , layout = "scrolling" })
end)

hl.bind(mainMod .. " + t", function() 
    hl.workspace_rule({ workspace = hl.get_active_workspace().name , layout = "default" })
end)

-- === Device Controls ===

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })


-- === Mouse ===

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("mouse:274", hl.dsp.window.fullscreen({mode="maximized"}), {mouse=true})

