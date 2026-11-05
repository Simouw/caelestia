-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Repasser sur le curseur vi (mode Normal) depuis le terminal avec Ctrl+Espace (<C-Space> / <C-@>)
-- sans fermer la fenetre du terminal
vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>", { desc = "Passer en mode normal (curseur vi)", silent = true })
vim.keymap.set("t", "<C-@>", "<C-\\><C-n>", { desc = "Passer en mode normal (curseur vi)", silent = true })

-- Assurer le mapping pour tous les buffers de terminal ouverts
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("terminal_exit_mode", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true, desc = "Passer en mode normal (curseur vi)" }
    vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>", opts)
    vim.keymap.set("t", "<C-@>", "<C-\\><C-n>", opts)
  end,
})

-- Commande :Colorschemes et :Theme avec TUI et prévisualisation en direct
vim.api.nvim_create_user_command("Colorschemes", function()
  if pcall(require, "snacks") and Snacks.picker and Snacks.picker.colorschemes then
    Snacks.picker.colorschemes()
  else
    vim.cmd("Telescope colorscheme enable_preview=true")
  end
end, { desc = "Ouvrir le sélecteur de couleurs TUI avec aperçu en direct" })

vim.api.nvim_create_user_command("Theme", function()
  vim.cmd("Colorschemes")
end, { desc = "Alias pour :Colorschemes" })

vim.keymap.set("n", "<leader>th", "<cmd>Colorschemes<CR>", { desc = "Sélecteur de Thèmes (TUI)" })

-- =========================================================================
-- Système d'aide et correction automatique en Ghost Text (<leader>s)
-- =========================================================================
local ns = vim.api.nvim_create_namespace("aide_correction")

local function trouver_fichier_corrige()
  local dir = vim.fn.expand("%:p:h")
  local nom = vim.fn.expand("%:t:r")
  local ext = vim.fn.expand("%:e")

  -- 1. Cherche nom_corrige.ext (ex: src/calc_corrige.c pour src/calc.c)
  local cible = dir .. "/" .. nom .. "_corrige." .. ext
  if vim.fn.filereadable(cible) == 1 then
    return cible
  end

  -- 2. Cherche calc_corrige.c dans le même dossier
  cible = dir .. "/calc_corrige.c"
  if vim.fn.filereadable(cible) == 1 then
    return cible
  end

  -- 3. Cherche dans ../src/calc_corrige.c
  cible = dir .. "/../src/calc_corrige.c"
  if vim.fn.filereadable(cible) == 1 then
    return cible
  end

  return nil
end

local function obtenir_ligne_correction()
  local fichier = trouver_fichier_corrige()
  if not fichier then
    vim.notify("Aucun fichier corrigé trouvé (*_corrige.c)", vim.log.levels.WARN)
    return nil, nil
  end

  local lignes_corrige = vim.fn.readfile(fichier)
  local ligne_num = vim.fn.line(".")
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, ligne_num, false)

  -- Tenter de détecter la fonction courante pour aligner intelligemment
  local nom_fonc = nil
  local decalage_fonc = 0
  for i = #buf_lines, 1, -1 do
    local l = buf_lines[i]
    local m = l:match("([%a_][%w_]*)%s*%b()")
    if
      m
      and not l:match("^%s*if%s*%(")
      and not l:match("^%s*while%s*%(")
      and not l:match("^%s*for%s*%(")
      and not l:match("^%s*switch%s*%(")
      and not l:match("^%s*assert%s*%(")
    then
      nom_fonc = m
      decalage_fonc = ligne_num - i
      break
    end
  end

  local ligne_cible = nil
  if nom_fonc then
    for j, l in ipairs(lignes_corrige) do
      if l:match(nom_fonc) and l:match("%b()") and not l:match(";") then
        local idx = j + decalage_fonc
        if lignes_corrige[idx] then
          ligne_cible = lignes_corrige[idx]
        end
        break
      end
    end
  end

  -- Si non trouvé par contexte de fonction, utiliser le numéro de ligne absolu
  if not ligne_cible and lignes_corrige[ligne_num] then
    ligne_cible = lignes_corrige[ligne_num]
  end

  return ligne_cible, ligne_num
end

-- Raccourci <leader>s : Afficher la correction en texte fantôme (virtuel)
vim.keymap.set("n", "<leader>s", function()
  local ligne_cible, lnum = obtenir_ligne_correction()
  if not ligne_cible then
    return
  end

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  local texte_affiche = ligne_cible:gsub("^%s*", "")
  if texte_affiche == "" then
    texte_affiche = "(ligne vide dans le corrigé)"
  end

  vim.api.nvim_buf_set_extmark(0, ns, lnum - 1, 0, {
    virt_text = { { "  💡 Corrigé : " .. texte_affiche, "DiagnosticVirtualTextInfo" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })
end, { desc = "Afficher la ligne du corrigé (Ghost text)" })

-- Raccourci <leader>S : Insérer directement la ligne du corrigé
vim.keymap.set("n", "<leader>S", function()
  local ligne_cible, lnum = obtenir_ligne_correction()
  if not ligne_cible then
    return
  end

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { ligne_cible })
  vim.notify("Ligne insérée depuis le corrigé !", vim.log.levels.INFO)
end, { desc = "Insérer la ligne du corrigé" })

-- Raccourci <leader>sc : Effacer l'aide affichée
vim.keymap.set("n", "<leader>sc", function()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, { desc = "Effacer les indices du corrigé" })
