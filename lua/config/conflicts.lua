-- Finding conflicted files.
--
-- "Unmerged paths" is git's term for files left in conflict by a merge, rebase
-- or cherry-pick. `git diff --diff-filter=U` is the reliable way to list them —
-- more so than parsing `git status`, whose output format is meant for humans.

local M = {}

function M.unmerged()
  local root = vim.fs.root(0, ".git")
  if not root then return {} end

  local out = vim.system(
    { "git", "diff", "--name-only", "--diff-filter=U", "--relative" },
    { cwd = root, text = true }
  ):wait()

  if out.code ~= 0 then return {} end

  local files = {}
  for line in (out.stdout or ""):gmatch("[^\r\n]+") do
    if line ~= "" then
      table.insert(files, root .. "/" .. line)
    end
  end
  return files
end

function M.to_quickfix()
  local files = M.unmerged()
  if #files == 0 then
    vim.notify("No conflicts in this repo")
    return
  end

  local items = {}
  for _, path in ipairs(files) do
    -- Point at the first conflict marker in each file rather than line 1, so
    -- jumping to an entry lands where the work actually is.
    local lnum = 1
    local ok, lines = pcall(vim.fn.readfile, path)
    if ok then
      for i, line in ipairs(lines) do
        if line:match("^<<<<<<<") then lnum = i break end
      end
    end
    table.insert(items, { filename = path, lnum = lnum, text = "conflict" })
  end

  vim.fn.setqflist({}, " ", { title = "Conflicts", items = items })
  vim.cmd("copen")
end

return M
