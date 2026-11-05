-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`

-- Association des fichiers pseudo-code (.txt, .algo, .pseudo, .pc)
vim.filetype.add({
  extension = {
    txt = "pseudocode",
    algo = "pseudocode",
    pseudo = "pseudocode",
    pc = "pseudocode",
  },
})

-- Filet de securite anti-disparition de curseur :
-- Si un plugin plante ou laisse le curseur masque, on le restaure automatiquement
local default_guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor-blinkwait175-blinkoff150-blinkon175,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"

vim.api.nvim_create_autocmd({ "CursorHold", "ModeChanged" }, {
  desc = "Securite pour restaurer le curseur s'il a ete masque par un plugin",
  callback = function()
    if vim.o.guicursor:find("Hidden", 1, true) or vim.o.guicursor:find("HideTarget", 1, true) then
      vim.o.guicursor = default_guicursor
    end
  end,
})