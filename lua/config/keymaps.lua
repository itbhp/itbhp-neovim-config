-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Old muscle memory from ~/.vimrc, remapped onto LazyVim's modern equivalents.
-- (LazyVim's own <leader>e / <leader>ff still work too.)
local map = vim.keymap.set

-- was `nnoremap <C-n> :NERDTreeToggle<CR>`  ->  neo-tree
map("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Explorer (toggle)" })

-- was `nnoremap <C-f> :NERDTreeFind<CR>`  ->  neo-tree reveal current file
map("n", "<C-f>", "<cmd>Neotree reveal<cr>", { desc = "Reveal file in explorer" })

-- was CtrlP (`<C-p>`)  ->  LazyVim's find-files picker (remap keeps it backend-agnostic)
map("n", "<C-p>", "<leader>ff", { remap = true, desc = "Find Files" })
