-- onedark.nvim (navarasu) replaces LazyVim's stock tokyonight. The theme plugin
-- is loaded eagerly at high priority so it's on the runtimepath before any
-- other plugin defines highlight groups; LazyVim's own `colorscheme` option is
-- what actually applies it, which keeps its habamax fallback intact if the
-- load fails.
return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
    },
    config = function(_, opts)
      require("onedark").setup(opts)
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
