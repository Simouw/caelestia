return {
  "sphamba/smear-cursor.nvim",
  -- Desactive sous Kitty afin de laisser Kitty gerer nativement
  -- l'animation du curseur (cursor_trail) sans lag reseau ni conflit de redraw
  enabled = function()
    return vim.env.TERM ~= "xterm-kitty" and vim.env.KITTY_WINDOW_ID == nil
  end,
  event = "VeryLazy",
  opts = {
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    scroll_buffer_space = true,
    -- Desactive en mode insertion pour ne jamais cacher le curseur pendant la frappe
    smear_insert_mode = false,
    never_draw_over_target = true,
    hide_target_hack = false,
    stiffness = 0.6,
    trailing_stiffness = 0.45,
    damping = 0.85,
    trailing_exponent = 3,
    distance_stop_animating = 0.1,
  },
}