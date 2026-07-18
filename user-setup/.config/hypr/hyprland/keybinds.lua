local terminal = os.getenv("TERMINAL")

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + F", hl.dsp.exec_cmd("flatpak run app.zen_browser.zen"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(terminal.." -e yazi"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("qs ipc call menu toggle"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind("SUPER + C", hl.dsp.exec_cmd(terminal.." -e nvim"))

hl.bind("SUPER + SHIFT + C", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + X", hl.dsp.window.fullscreen())

-- Settings control
hl.bind("SUPER + EQUAL", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("SUPER + MINUS", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))

-- Move window to another workspace
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1", follow = false }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2", follow = false }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3", follow = false }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4", follow = false }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "6", follow = false }))

-- Move window
hl.bind("SUPER + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + RIGHT", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + DOWN", hl.dsp.window.move({ direction = "down" }))

-- Move to workspace
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))

-- Mouse
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })    -- ALT + LMB: Move a window
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })  -- ALT + RMB: Resize a window

hl.bind("SUPER + SHIFT + X", hl.dsp.window.float({ action = "toggle" }))