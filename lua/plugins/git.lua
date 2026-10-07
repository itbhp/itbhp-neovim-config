-- Git: lazygit for anything involved, gitsigns for hunks, diffview for review,
-- git-conflict for in-buffer conflict resolution, octo for GitHub PRs/issues.
return {

  -- lazygit in a floating window --------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (repo)" },
      { "<leader>gf", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit (file history)" },
      { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "LazyGit (commit log)" },
    },
    init = function()
      vim.g.lazygit_floating_window_scaling_factor = 0.95
      vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.g.lazygit_use_neovim_remote = 0
    end,
  },

  -- Gutter signs, hunk staging, inline blame ---------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = false,
      current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", function() gs.blame() end, "Blame file")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle inline blame")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- GitHub pull requests, in the editor --------------------------------------
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      picker = "snacks",
      use_local_fs = false,
      enable_builtin = true,
      suppress_missing_scope = { projects_v2 = true },
    },
    keys = {
      { "<leader>pl", "<cmd>Octo pr list<cr>", desc = "PRs in this repo" },
      { "<leader>pp", "<cmd>Octo pr<cr>", desc = "PR for this branch" },
      { "<leader>pr", "<cmd>Octo review start<cr>", desc = "Start a review" },
      { "<leader>pR", "<cmd>Octo review submit<cr>", desc = "Submit the review" },
      { "<leader>pi", "<cmd>Octo issue list<cr>", desc = "Issues" },
      { "<leader>ps", "<cmd>Octo search<cr>", desc = "Search PRs and issues" },
    },
  },

  -- In-buffer conflict resolution -------------------------------------------
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      default_mappings = false,
      default_commands = true,
      disable_diagnostics = false,
      highlights = {
        current = "DiffAdd",
        incoming = "DiffText",
        ancestor = "DiffChange",
      },
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictDetected",
        callback = function(ev)
          local buf = ev.buf or 0
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
          end
          map("<leader>co", "<cmd>GitConflictChooseOurs<cr>", "Conflict: take ours")
          map("<leader>ct", "<cmd>GitConflictChooseTheirs<cr>", "Conflict: take theirs")
          map("<leader>cb", "<cmd>GitConflictChooseBoth<cr>", "Conflict: take both")
          map("<leader>cn", "<cmd>GitConflictChooseNone<cr>", "Conflict: take neither")
          map("]x", "<cmd>GitConflictNextConflict<cr>", "Next conflict")
          map("[x", "<cmd>GitConflictPrevConflict<cr>", "Previous conflict")

          -- Whole-file "take ours / take theirs" for when the per-hunk choice
          -- isn't what you want. Works in the Diffview 3-pane merge view where
          -- OURS is //2 and THEIRS is //3 relative to the merged buffer.
          map("<leader>cO", "<cmd>%diffget //2<cr>", "Conflict: take ours (whole file)")
          map("<leader>cT", "<cmd>%diffget //3<cr>", "Conflict: take theirs (whole file)")

          pcall(function()
            require("which-key").add({ "<leader>c", group = "conflict", buffer = buf })
          end)

          vim.diagnostic.enable(false, { bufnr = buf })

          vim.notify("Conflicts in this file — <leader>co / ct / cb, ]x to move",
            vim.log.levels.WARN)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictResolved",
        callback = function(ev)
          local buf = ev.buf or 0
          for _, lhs in ipairs({ "<leader>co", "<leader>ct", "<leader>cb", "<leader>cn", "<leader>cO", "<leader>cT", "]x", "[x" }) do
            pcall(vim.keymap.del, "n", lhs, { buffer = buf })
          end
          vim.diagnostic.enable(true, { bufnr = buf })
          pcall(function()
            require("which-key").add({ "<leader>c", group = "code", buffer = buf })
          end)
        end,
      })
    end,
  },

  -- Diffview: review a whole branch or PR inside Neovim ----------------------
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview (working tree)" },
      { "<leader>gm", "<cmd>DiffviewOpen origin/master...HEAD<cr>", desc = "Diff vs master" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (diffview)" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
      {
        "<leader>gx",
        function()
          local files = require("config.conflicts").unmerged()
          if #files == 0 then
            vim.notify("No conflicts in this repo")
            return
          end
          vim.notify(#files .. " conflicted file(s)")
          vim.cmd("DiffviewOpen")
        end,
        desc = "Resolve conflicts (3-pane)",
      },
      {
        "<leader>gX",
        function() require("config.conflicts").to_quickfix() end,
        desc = "List conflicted files",
      },
    },
    opts = {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = "diff3_mixed" } },
    },
  },
}
