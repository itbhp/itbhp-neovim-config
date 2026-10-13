-- Kotlin support via kotlin.nvim (https://github.com/AlexandrosAlexiou/kotlin.nvim).
--
-- This replaces the previous hand-rolled kotlin_language_server LSP override.
-- kotlin.nvim drives JetBrains' new `kotlin-lsp` (the IntelliJ-based server,
-- installed through Mason as `kotlin-lsp`) and starts/manages the LSP client
-- itself, so we do NOT register kotlin under nvim-lspconfig's `servers`.
--
-- Because kotlin.nvim owns LSP startup, mason-lspconfig must NOT auto-enable
-- `kotlin_lsp` (that would spawn a second, conflicting client). We exclude it below.
--
-- First run: `:MasonInstall kotlin-lsp` (Mason may auto-install it as a dependency).
return {
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "stevearc/oil.nvim",
      "folke/trouble.nvim",
    },
    opts = {}, -- see plugin README for the full defaults (inlay_hints, jvm_args, ...)
    config = function(_, opts)
      require("kotlin").setup(opts)
    end,
  },

  -- Keep mason-lspconfig from auto-enabling kotlin_lsp; kotlin.nvim manages it.
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = { exclude = { "kotlin_lsp" } },
    },
  },

  -- Patch the kotlin-lsp Mason registry entry: upstream v263.4702.0+ URLs point
  -- at download-cdn.jetbrains.com, which 404s. The file lives at download.jetbrains.com.
  -- Hook `package:install:handle` so the spec is rewritten just before install
  -- runs — this fires every install regardless of registry cache state, and
  -- survives buffer reloads that would otherwise discard an eager mutation.
  -- Remove once mason-org/mason-registry ships a fixed entry.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local reg = require("mason-registry")
      reg:on("package:install:handle", function(handle)
        local pkg = handle and handle.package
        if not pkg or pkg.name ~= "kotlin-lsp" or not pkg.spec or not pkg.spec.source then
          return
        end
        for _, dl in ipairs(pkg.spec.source.download or {}) do
          for name, url in pairs(dl.files or {}) do
            dl.files[name] = url:gsub("download%-cdn%.jetbrains%.com", "download.jetbrains.com")
          end
        end
      end)
      return opts
    end,
  },

  -- Treesitter parser for Kotlin (LazyVim's dropped kotlin extra used to add it).
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "kotlin" } },
  },
}
