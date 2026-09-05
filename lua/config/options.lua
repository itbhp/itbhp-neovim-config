-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Ported from ~/.vimrc.
-- Note: number, relativenumber, cursorline, ignorecase+smartcase, hlsearch and
-- incsearch are already LazyVim defaults, so they don't need to be repeated here.
-- Use basedpyright (installed via Mason) as the Python LSP. LazyVim's python
-- extra otherwise defaults to plain "pyright", whose binary we don't install.
vim.g.lazyvim_python_lsp = "basedpyright"

vim.opt.textwidth = 100 -- was `set textwidth=100`
vim.opt.colorcolumn = "100" -- visual marker at the textwidth column
vim.opt.showbreak = "+++" -- was `set showbreak=+++`
