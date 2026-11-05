return {
  -- Desactiver l'animation de scroll de Snacks pour eviter tout conflit
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },

  -- Defilement fluide avec neoscroll.nvim
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = {
        "<C-u>",
        "<C-d>",
        "<C-b>",
        "<C-f>",
        "<C-y>",
        "<C-e>",
        "zt",
        "zz",
        "zb",
      },
      -- NE JAMAIS masquer le curseur pendant le scroll :
      -- Cela entrait en conflit direct avec smear-cursor et bloquait le curseur invisible
      hide_cursor = false,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      duration_multiplier = 1.0,
      easing = "linear",
    },
  },
}