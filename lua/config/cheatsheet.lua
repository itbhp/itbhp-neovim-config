-- The <leader>? cheatsheet.
--
-- Single source of truth for the keymap reference. Add a keymap in keymaps.lua
-- or a plugin spec, then add one line here and it shows up in the popup. Keep
-- the two in sync — this is the thing you'll actually read.

local M = {}

M.sections = {
  {
    "FIND & NAVIGATE",
    {
      { "<leader><space>", "Find file in project" },
      { "<leader>ff",      "Find files" },
      { "<leader>fg",      "Live grep across the project" },
      { "<leader>sw",      "Grep the word under the cursor" },
      { "<leader>fb",      "Switch between open buffers" },
      { "<leader>fr",      "Recently opened files" },
      { "<leader>ss",      "Symbols in this file" },
      { "<leader>sS",      "Symbols across the workspace" },
      { "<leader>sh",      "Search Neovim's help" },
      { "<leader>sk",      "Search all keymaps" },
      { "<C-n>",           "Toggle file tree (neo-tree)" },
      { "<C-f>",           "Reveal current file in the tree" },
      { "<C-p>",           "Find files (ctrlp muscle memory)" },
      { "s",               "Flash: jump to any word on screen" },
    },
  },
  {
    "BUFFERS",
    {
      { "<S-h> / <S-l>", "Previous / next buffer" },
      { "<leader>bd",   "Close this buffer" },
      { "<leader>bD",   "Close and discard changes" },
      { "<leader>bo",   "Close every other buffer" },
      { "<leader>bp",   "Pin buffer so it stays put" },
      { "<leader>`",    "Jump back to the last buffer" },
    },
  },
  {
    "CODE & LSP",
    {
      { "gd",         "Go to definition" },
      { "gr",         "Find all references" },
      { "gI",         "Go to implementation" },
      { "gy",         "Go to type definition" },
      { "K",          "Hover documentation" },
      { "<leader>ca", "Code actions (quick fixes, imports)" },
      { "<leader>cr", "Rename symbol" },
      { "<leader>cf", "Format file" },
      { "<leader>cd", "Line diagnostics" },
      { "[d / ]d",    "Previous / next diagnostic" },
      { "<leader>xx", "Diagnostics for this file (Trouble)" },
      { "<leader>xX", "Workspace diagnostics (Trouble)" },
      { "<leader>xt", "TODO / FIXME list" },
      { "<leader>uf", "Toggle format-on-save (session)" },
      { "<leader>uh", "Toggle inlay hints" },
    },
  },
  {
    "JAVA / KOTLIN",
    {
      { "<leader>cR",  "Jdtls: rename / refactor" },
      { ":JavaTestRunCurrentClass", "nvim-java: run current test class" },
      { ":JavaTestRunCurrentMethod", "nvim-java: run current test method" },
      { ":JavaDapConfig", "nvim-java: configure DAP for the project" },
      { ":KotlinBuild",  "kotlin.nvim: trigger a build" },
      { "",              "Kotlin LSP is JetBrains' kotlin-lsp (via Mason)" },
    },
  },
  {
    "GIT",
    {
      { "<leader>gg",  "lazygit for this repo  <- the main one" },
      { "<leader>gf",  "lazygit history for this file" },
      { "<leader>gl",  "lazygit commit log" },
      { "<leader>gb",  "Blame the current line" },
      { "<leader>gB",  "Blame the whole file" },
      { "<leader>gd",  "Diffview: working tree changes" },
      { "<leader>gm",  "Diffview: branch vs origin/master" },
      { "<leader>gH",  "Diffview: this file's history" },
      { "<leader>gq",  "Close diffview" },
      { "]h / [h",     "Next / previous changed hunk" },
      { "<leader>ghs", "Stage this hunk" },
      { "<leader>ghr", "Reset this hunk" },
      { "<leader>ghu", "Undo last stage" },
      { "<leader>ghp", "Preview this hunk" },
      { "<leader>ub",  "Toggle inline blame" },
    },
  },
  {
    "MERGE CONFLICTS",
    {
      { "<leader>gx", "Open the 3-pane merge view  <- start here" },
      { "<leader>gX", "List every conflicted file (quickfix)" },
      { "]x / [x",    "Next / previous conflict" },
      { "<leader>co", "Take OURS (what you had)" },
      { "<leader>ct", "Take THEIRS (what came in)" },
      { "<leader>cb", "Take both sides" },
      { "<leader>cn", "Take neither, delete the region" },
      { "<leader>cO", "Take ours for the WHOLE file (merge view)" },
      { "<leader>cT", "Take theirs for the WHOLE file (merge view)" },
      { "<leader>gg", "then stage the file and continue in lazygit" },
    },
  },
  {
    "GITHUB (octo)",
    {
      { "<leader>pl", "PRs in this repo" },
      { "<leader>pp", "The PR for this branch" },
      { "<leader>pr", "Start a review" },
      { "<leader>pR", "Submit the review" },
      { "<leader>pi", "Issues" },
      { "<leader>ps", "Search PRs and issues" },
    },
  },
  {
    "CLAUDE & TERMINAL",
    {
      { "<C-,>",       "Toggle Claude Code terminal" },
      { ":ClaudeCode", "Open Claude Code" },
      { ":ClaudeCodeContinue", "Continue the last Claude session" },
      { "<leader>ft",  "Floating terminal (LazyVim)" },
      { "<leader>fT",  "Terminal in a split" },
      { "<C-/>",       "Toggle terminal below" },
      { "<C-h/j/k/l>", "From a terminal, jump to the adjacent split" },
      { "<Esc><Esc>",  "Exit terminal mode" },
    },
  },
  {
    "WINDOWS & THE BASICS",
    {
      { "<C-h/j/k/l>",  "Move between splits" },
      { "<leader>|",    "Split vertically" },
      { "<leader>-",    "Split horizontally" },
      { "<leader>wd",   "Close this window" },
      { "<leader>wm",   "Maximise / restore (LazyVim)" },
      { "q",            "Closes help, quickfix, checkhealth etc." },
      { "<C-s>",        "Save" },
      { "<Esc>",        "Clear search highlight" },
      { "<leader>qq",   "Quit Neovim" },
      { "<leader>qs",   "Restore this project's session" },
      { "<leader>ql",   "Restore the last session" },
      { "<leader>um",   "Toggle markdown rendering" },
      { "<leader>uC",   "Pick a colorscheme" },
      { "<leader>?",    "This cheatsheet" },
    },
  },
}

-- Render the sections into a centred, scrollable floating window.
function M.open()
  local lines, highlights = {}, {}
  local pad = "  "

  table.insert(lines, "")
  table.insert(lines, pad .. "NEOVIM CHEATSHEET" .. "   (q or <Esc> to close)")
  table.insert(highlights, { line = #lines - 1, group = "Title" })
  table.insert(lines, "")

  for _, section in ipairs(M.sections) do
    local title, maps = section[1], section[2]
    table.insert(lines, pad .. title)
    table.insert(highlights, { line = #lines - 1, group = "Statement" })
    for _, m in ipairs(maps) do
      table.insert(lines, string.format("%s  %-18s %s", pad, m[1], m[2]))
      table.insert(highlights, { line = #lines - 1, group = "Comment", col = #pad + 20 })
    end
    table.insert(lines, "")
  end

  local width = 0
  for _, l in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(l)) end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace("cheatsheet")
  for _, h in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(buf, ns, h.line, h.col or 0, {
      end_row = h.line,
      end_col = #(lines[h.line + 1] or ""),
      hl_group = h.group,
    })
  end

  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "cheatsheet"
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Keymaps ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true, silent = true })
  end
end

return M
