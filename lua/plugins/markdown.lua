-- render-markdown.nvim: renders markdown inside the buffer using treesitter +
-- virtual text — heading icons, code-block backgrounds, aligned tables, bullets,
-- checkboxes, callouts. Nothing in this config handled markdown before.
--
-- Deliberately NOT LazyVim's `lang.markdown` extra: that bundles marksman,
-- markdownlint-cli2, markdown-toc, prettier-on-save for .md and a browser
-- preview. Only the in-buffer renderer is wanted here.
--
-- The `markdown` + `markdown_inline` treesitter parsers already ship in
-- LazyVim's default `ensure_installed`, so no parser spec is needed.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- markdown / markdown_inline parsers
      "nvim-mini/mini.icons", -- icons above code blocks; owner must match LazyVim's spec
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {}, -- defaults: renders in normal/command/terminal mode, raw markdown while editing
    config = function(_, opts)
      require("render-markdown").setup(opts)
      -- <leader>um matches the key LazyVim's markdown extra uses, so muscle
      -- memory survives if that extra is ever enabled instead.
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },
}
