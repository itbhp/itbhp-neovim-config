-- HTML / CSS language servers. The typescript extra covers JS/TS + eslint +
-- prettier, but not plain HTML/CSS, so enable those two servers here.
-- Same pattern as kotlin.lua: they auto-install via Mason once listed.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
      },
    },
  },
}
