-- Ensure ~/.local/bin is in PATH for Neovim session
if not string.find(vim.env.PATH or "", vim.fn.expand("~/.local/bin")) then
  vim.env.PATH = vim.fn.expand("~/.local/bin:") .. (vim.env.PATH or "")
end

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      anti_conceal = {
        enabled = true,
        disabled_modes = false,
        above = 0,
        below = 0,
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
      },
      checkbox = {
        enabled = true,
      },
      latex = {
        enabled = true,
        converter = { vim.fn.expand("~/.local/bin/latex2text"), "latex2text", "utftex" },
        highlight = "RenderMarkdownMath",
        position = "center",
      },
    },
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    keys = {
      {
        "<leader>um",
        function()
          require("render-markdown").toggle()
        end,
        desc = "Toggle Render Markdown",
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      if Snacks and Snacks.toggle then
        Snacks.toggle({
          name = "Render Markdown",
          get = function()
            return require("render-markdown").get()
          end,
          set = function(enabled)
            require("render-markdown").set(enabled)
          end,
        }):map("<leader>um")
      end
    end,
  },
}
