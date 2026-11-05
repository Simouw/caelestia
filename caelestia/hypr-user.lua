-- Disposition clavier AZERTY (français) & US (anglais) & Unités Métriques
hl.config({
    input = {
        kb_layout = "fr,us",
    },
})
hl.env("LC_MEASUREMENT", "fr_FR.UTF-8")
hl.env("LC_TIME", "fr_FR.UTF-8")

local home = os.getenv("HOME") or ""

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    -- Restauration automatique garantie du fond d'écran et du thème au démarrage
    hl.exec_cmd("test -f ~/.local/state/caelestia/wallpaper/path.txt && caelestia wallpaper -f \"$(cat ~/.local/state/caelestia/wallpaper/path.txt)\"")
end)

-- Fenêtres flottantes centrées pour les terminaux d'IA (OpenCode, Antigravity, Codex, Claude)
hl.window_rule({
    match = { title = "^(OpenCode|Antigravity|Codex|Claude|Floating Terminal)$" },
    float = true,
    size = "(monitor_w*0.75) (monitor_h*0.80)",
    center = true,
})

-- Fenêtre flottante de la liste des raccourcis
hl.bind("SUPER + slash", hl.dsp.exec_cmd(home .. "/.config/caelestia/cheatsheet.sh"))
hl.bind("SUPER + H", hl.dsp.exec_cmd(home .. "/.config/caelestia/cheatsheet.sh"))

-- Support direct des bureaux 1 à 10 sur clavier AZERTY
local fn = require("utils.functions")
local azertyKeys = {
    "ampersand",  -- 1
    "eacute",     -- 2
    "quotedbl",   -- 3
    "apostrophe", -- 4
    "parenleft",  -- 5
    "minus",      -- 6
    "egrave",     -- 7
    "underscore", -- 8
    "ccedilla",   -- 9
    "agrave",     -- 10
}

for i, key in ipairs(azertyKeys) do
    hl.bind("SUPER + " .. key, fn.wsaction("focus", "", i))
    hl.bind("SUPER + ALT + " .. key, fn.wsaction("move", "", i))
    hl.bind("SUPER + SHIFT + " .. key, fn.wsaction("move_silent", "", i))
end

-- Galerie visuelle de sélection des fonds d'écran avec prévisualisation (grille 3x3)
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(home .. "/.config/caelestia/wallpaper-gallery.sh"))

-- Fond d'écran aléatoire instantané
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("caelestia wallpaper -r"))

-- Couper / Réactiver le microphone globalement (avec notification OSD)
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd(home .. "/.local/bin/mic toggle"), { locked = true })
