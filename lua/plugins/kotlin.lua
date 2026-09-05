-- Kotlin has no official LazyVim extra, so we enable it by hand.
-- This doubles as a worked example of how a LazyVim plugin/LSP override looks:
-- you merge into an existing plugin's `opts` rather than redefining the plugin.
--
-- Adding a server under nvim-lspconfig's `servers` is all LazyVim needs — it
-- auto-installs the matching Mason package (kotlin-language-server) and enables
-- the server. If auto-install ever doesn't fire, run `:MasonInstall kotlin-language-server`.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = {
          -- kotlin-language-server crashes on init ("Expected BEGIN_OBJECT but was
          -- BEGIN_ARRAY") when initializationOptions serializes to a JSON array,
          -- which an empty Lua table does. Passing a real (non-empty) object keeps
          -- it a JSON object through LazyVim's config merge and fixes the crash.
          init_options = {
            storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server",
          },
        },
      },
    },
  },
}
