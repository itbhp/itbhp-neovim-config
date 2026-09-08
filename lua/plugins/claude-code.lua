-- claude-code.nvim: toggle a Claude Code terminal inside Neovim.
-- Toggle with <C-,> (normal & terminal mode); :ClaudeCode / :ClaudeCodeContinue.
return {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required for git operations
    },
    config = function()
      require("claude-code").setup()
    end,
  },
}
