hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1.25",
})

local terminal    = "kitty"
local fileManager = "thunar"


hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})


require("modules.autostart")
require("modules.env")
require("modules.binds")
require("modules.input")
require("modules.layouts")
require("modules.appearence")
require("modules.animations")
require("modules.rules")


-- For Noctalia Color templates
require("noctalia")
