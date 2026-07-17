hl.env("XDG_CONFIG_HOME", os.getenv("HOME").."/.config")
hl.env("XDG_CACHE_HOME", os.getenv("HOME").."/.cache")
hl.env("XDG_DATA_HOME", os.getenv("HOME").."/.local/share")
hl.env("XDG_STATE_HOME", os.getenv("HOME").."/.local/state")
hl.env("XDG_DOWNLOAD_DIR", os.getenv("HOME").."/downloads")
hl.env("XDG_DATA_DIRS", os.getenv("HOME").."/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:"..(os.getenv("XDG_DATA_DIRS") or "/usr/local/share:/usr/share"))

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("SDL_VIDEODRIVER", "wayland")

hl.env("GDK_BACKEND", "wayland,x11,*")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")