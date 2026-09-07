-- nvim-java: all-in-one Java support (jdtls + dap + spring-boot + lombok + tests).
-- Replaces LazyVim's lang.java extra, which was removed from lua/config/lazy.lua
-- because it drives Java via nvim-jdtls and cannot coexist with nvim-java.
--
-- Follows nvim-java's official LazyVim recipe: initialization is deferred to the
-- nvim-lspconfig `setup.jdtls` hook, which LazyVim runs BEFORE lspconfig.jdtls.setup().
-- That ordering (require("java").setup() first) is required by nvim-java.
return {
  {
    "nvim-java/nvim-java",
    config = false,
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            jdtls = {}, -- jdtls-specific settings can go here later
          },
          setup = {
            jdtls = function()
              require("java").setup()
            end,
          },
        },
      },
    },
  },

  -- nvim-java ships its own Mason registry with pinned jdtls / java-debug /
  -- java-test versions; it must be listed BEFORE the default so those win.
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:nvim-java/mason-registry",
        "github:mason-org/mason-registry",
      },
    },
  },

  -- We dropped LazyVim's lang.java extra (it used nvim-jdtls, which conflicts
  -- with nvim-java), so re-add the Java treesitter parser it used to provide.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
}
