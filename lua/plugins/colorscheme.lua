-- gruvbox.nvim replaces LazyVim's stock tokyonight. The theme plugin itself is
-- loaded eagerly at high priority so it's on the runtimepath before any other
-- plugin defines highlight groups; LazyVim's own `colorscheme` option is what
-- actually applies it, which keeps its habamax fallback intact if the load fails.
--
-- `background` must be set before the colorscheme is applied — gruvbox reads it
-- to pick its dark/light palette — hence `init` rather than `config`.
return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = "dark"
    end,
    opts = {}, -- upstream defaults: italic comments/strings, no contrast override
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
