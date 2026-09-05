-- tmuxline: the one Vundle plugin with no LazyVim equivalent. It makes your
-- tmux statusline match the (neo)vim colorscheme. Loaded eagerly since it's a
-- small vimscript plugin that sets up on startup.
return {
  {
    "edkolev/tmuxline.vim",
    lazy = false,
  },
}
