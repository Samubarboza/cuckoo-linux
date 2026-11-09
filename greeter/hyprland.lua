-- Hyprland settings for the Cuckoo login screen.

-- Every screen at its own resolution, with no scaling
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.on("hyprland.start", function()
    -- The login wallpaper on every screen. ReGreet covers the laptop screen.
    hl.exec_cmd("swaybg --image /usr/share/backgrounds/cuckoo/cuckoo.png --mode fill")
    -- After the login, the wallpaper goes first, so the screen ends on black
    hl.exec_cmd("regreet; pkill -x swaybg; hyprctl dispatch 'hl.dsp.exit()'")
end)

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        disable_hyprland_guiutils_check = true,
        disable_watchdog_warning = true,
        background_color = 0x000000,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
    animations = {
        enabled = false,
    },
})
