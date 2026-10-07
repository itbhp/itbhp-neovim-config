-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Close-with-q for read-only utility windows that LazyVim's defaults miss.
-- LazyVim covers help/qf/notify, but checkhealth/lspinfo/dap-float etc. would
-- otherwise strand you.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("paolo_close_with_q", { clear = true }),
  pattern = {
    "checkhealth", "lspinfo", "startuptime", "query",
    "dap-float", "gitsigns-blame", "fugitive",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>",
      { buffer = ev.buf, silent = true, nowait = true, desc = "Close this window" })
  end,
})
