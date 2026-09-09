-- Both the file picker and the explorer hide git-ignored files by default. Because
-- ~/.gitconfig sets core.excludesfile = ~/.gitignore_global, that machine-wide list
-- (CLAUDE.md, .claude/, AGENTS.md, target/, .idea/, ...) is ignored in *every* repo,
-- which made those files invisible in any git checkout. Show them instead.
--
-- neo-tree itself is enabled via `vim.g.lazyvim_explorer` in lua/config/options.lua.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          -- lazy.nvim replaces list-valued opts rather than merging them, so the
          -- two neo-tree defaults (.DS_Store, thumbs.db) are respelled here.
          -- .git is added because unhiding dotfiles would otherwise expose it.
          hide_by_name = { ".git", ".DS_Store", "thumbs.db" },
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true, ignored = true },
        },
      },
    },
  },
}
