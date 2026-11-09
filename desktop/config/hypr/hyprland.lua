-- Hyprland settings for Cuckoo Linux.

local home_directory = os.getenv("HOME")
local main_modifier = "SUPER"
local terminal_command = "alacritty"

-- A missing or broken file is left out, so it never breaks the desktop
local function load_settings_file(file_path)
    local settings_file = loadfile(file_path)
    if settings_file then
        settings_file()
    end
end

local function bind_with_main_modifier(key_name, dispatcher, bind_options)
    hl.bind(main_modifier .. " + " .. key_name, dispatcher, bind_options)
end

-- Every screen with its own resolution and scale 1. The scale picked in the bar goes in monitors.lua
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})
load_settings_file(home_directory .. "/.config/hypr/monitors.lua")

-- The Cuckoo window style, from the package so updates reach every user
load_settings_file("/usr/share/cuckoo/hypr/window-style.lua")
-- The theme choices (border, corners, opacity and cursor), made by cuckoo-theme
load_settings_file(home_directory .. "/.config/cuckoo/theme/hyprland.lua")

-- Electron apps run on Wayland, so they stay sharp with any scale
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- Qt apps take their look from qt6ct (qt6ct.conf)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.on("hyprland.start", function()
    -- Wallpaper
    hl.exec_cmd("swaybg --image /usr/share/backgrounds/cuckoo/cuckoo-background-1.png --mode fill")
    -- Notifications first, then the bar that shows them
    hl.exec_cmd("swaync")
    -- The bar and its popups, all in one
    hl.exec_cmd("quickshell")
    -- Locks the screen when idle and before sleep (hypridle.conf)
    hl.exec_cmd("hypridle")
    -- The home folders (Pictures, Downloads...), named in the user language
    hl.exec_cmd("xdg-user-dirs-update")
end)

hl.config({
    -- Apps without Wayland are drawn at the real size: sharp, a bit smaller
    xwayland = {
        force_zero_scaling = true,
    },
    -- Start on black instead of the Hyprland wallpaper, so the login fade ends on black too
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        background_color = 0x000000,
        -- If the lock screen crashes, the session stays locked and the lock can open again
        allow_session_lock_restore = true,
    },
    animations = {
        enabled = true,
    },
})

-- The wallpaper comes in with a soft fade
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "default", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 5, bezier = "default" })

-- Windows
bind_with_main_modifier("RETURN", hl.dsp.exec_cmd(terminal_command))
-- The app launcher lives in Quickshell (Launcher.qml)
bind_with_main_modifier("D", hl.dsp.global("quickshell:launcher"))
-- The theme panel lives in Quickshell too (ThemePanel.qml)
bind_with_main_modifier("T", hl.dsp.global("quickshell:theme"))
-- The power menu lives in Quickshell too (PowerMenu.qml)
bind_with_main_modifier("X", hl.dsp.global("quickshell:power"))
bind_with_main_modifier("Q", hl.dsp.window.close())
bind_with_main_modifier("F", hl.dsp.window.fullscreen())
bind_with_main_modifier("E", hl.dsp.exit())

bind_with_main_modifier("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind_with_main_modifier("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lock, the same way as idle and sleep, so it never opens twice
bind_with_main_modifier("L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Screenshot of an area, saved in the pictures folder of the user language
hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" "$(xdg-user-dir PICTURES)/screenshot_$(date +%Y%m%d_%H%M%S).png"]]))

-- Move between windows
bind_with_main_modifier("left", hl.dsp.focus({ direction = "left" }))
bind_with_main_modifier("right", hl.dsp.focus({ direction = "right" }))
bind_with_main_modifier("up", hl.dsp.focus({ direction = "up" }))
bind_with_main_modifier("down", hl.dsp.focus({ direction = "down" }))

-- Go to a desk, or send the window to it. The key 0 is the desk 10
for workspace_number = 1, 10 do
    local workspace_key = workspace_number % 10
    bind_with_main_modifier(workspace_key, hl.dsp.focus({ workspace = workspace_number }))
    bind_with_main_modifier("SHIFT + " .. workspace_key, hl.dsp.window.move({ workspace = workspace_number }))
end

-- Sound
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
