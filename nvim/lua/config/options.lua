-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Chiffres a gauche avec mode relatif au curseur
vim.opt.number = true
vim.opt.relativenumber = true

-- Repasser sur le curseur vi (mode Normal) depuis le terminal avec Ctrl+Espace sans fermer la fenetre
vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>", { desc = "Passer en mode normal (curseur vi)", silent = true })
vim.keymap.set("t", "<C-@>", "<C-\\><C-n>", { desc = "Passer en mode normal (curseur vi)", silent = true })

-- Curseur clairement visible et clignotant en mode insertion (couleur Cursor du theme Vinyl)
vim.opt.guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor-blinkwait175-blinkoff150-blinkon175,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"