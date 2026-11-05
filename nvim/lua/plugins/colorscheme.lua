local theme_file = vim.fn.stdpath("state") .. "/selected_theme.txt"

local function get_saved_theme()
  local f = io.open(theme_file, "r")
  if f then
    local theme = f:read("*l")
    f:close()
    if theme and theme ~= "" then
      return theme
    end
  end
  return "challenger_deep"
end

-- Sauvegarder automatiquement le theme choisi lors d'un changement ou a la fermeture
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("persist_theme", { clear = true }),
  callback = function(args)
    if args.match and args.match ~= "" then
      local f = io.open(theme_file, "w")
      if f then
        f:write(args.match .. "\n")
        f:close()
      end
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("persist_theme_exit", { clear = true }),
  callback = function()
    if vim.g.colors_name and vim.g.colors_name ~= "" then
      local f = io.open(theme_file, "w")
      if f then
        f:write(vim.g.colors_name .. "\n")
        f:close()
      end
    end
  end,
})

return {
  -- Base2Tone (https://github.com/atelierbram/Base2Tone-vim)
  {
    "atelierbram/Base2Tone-vim",
    lazy = false,
    priority = 1000,
  },

  -- Theme Challenger Deep (https://github.com/challenger-deep-theme/vim)
  {
    "challenger-deep-theme/vim",
    name = "challenger-deep",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.challenger_deep_termcolors = 256
      vim.g.challenger_deep_terminal_italics = 1
    end,
  },

  -- Theme Birds of Paradise (https://github.com/ronny/birds-of-paradise.vim)
  {
    "ronny/birds-of-paradise.vim",
    lazy = false,
    priority = 1000,
  },

  -- Definir le theme actif (persistant d'une session a l'autre)
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = get_saved_theme(),
    },
  },
}