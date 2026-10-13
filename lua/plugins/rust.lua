-- rustaceanvim (loaded by LazyVim's lang.rust extra) expects `rust-analyzer`
-- on PATH, and the extra itself only ensures `codelldb`. Add rust-analyzer to
-- mason's ensure_installed so a fresh clone of this config gets a working
-- Rust LSP without a manual :MasonInstall step.
return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust-analyzer" })
    end,
  },
}
