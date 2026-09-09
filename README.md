# My Neovim configuration

This is a **[LazyVim](https://lazyvim.github.io/)**-based Neovim setup, written in Lua and
kept completely **separate from my old Vim/Vundle config**. Vim still works exactly as
before (`~/.vimrc` + `~/.vim/bundle`); this directory only affects `nvim`.

> Migrated on 2026-09-05 from a 3-line `init.vim` shim that just sourced `~/.vimrc`.
> The old shim is backed up at `~/.config/nvim.bak/init.vim`.

---

## Table of contents

1. [How Neovim and Vim stay isolated](#how-neovim-and-vim-stay-isolated)
2. [Key concepts: LazyVim, lazy.nvim, Mason, LSP](#key-concepts)
3. [What this config contains](#what-this-config-contains)
4. [Directory layout](#directory-layout)
5. [Keymaps I brought over from Vim](#keymaps-i-brought-over-from-vim)
6. [Useful LazyVim shortcuts & workflows](#useful-lazyvim-shortcuts--workflows)
7. [Git with lazygit](#git-with-lazygit)
8. [Languages / LSP set up](#languages--lsp-set-up)
9. [How to add a new plugin](#how-to-add-a-new-plugin)
10. [How to add a new language / LSP server](#how-to-add-a-new-language--lsp-server)
11. [How to change options and keymaps](#how-to-change-options-and-keymaps)
12. [Everyday commands & maintenance](#everyday-commands--maintenance)
13. [Outstanding toolchain gaps](#outstanding-toolchain-gaps)
14. [Rollback](#rollback)
15. [Learning resources](#learning-resources)

---

## How Neovim and Vim stay isolated

Vim and Neovim read **completely different files by default** — the only reason they were
ever coupled is that the old `init.vim` deliberately repointed Neovim back at Vim's files.
Now that it's gone, they share nothing:

| | Vim | Neovim (this config) |
|---|---|---|
| Config entry | `~/.vimrc` | `~/.config/nvim/init.lua` |
| Plugin dir | `~/.vim/bundle` (Vundle) | `~/.local/share/nvim/lazy` (lazy.nvim) |
| Data / state / cache | `~/.vim` | `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim` |

So editing this config can never affect Vim, and vice-versa.

---

## Key concepts

These are **different layers** and are often confused. From highest-level to lowest:

### LazyVim — a *distribution* (a pre-built config)
LazyVim is a curated, opinionated Neovim configuration built on top of the `lazy.nvim`
plugin manager. Think of it as "Neovim, pre-assembled into an IDE": it ships sensible
defaults, a statusline, file explorer, fuzzy finder, git integration, completion, and a
framework for enabling language support ("Extras"). You customize it by *overriding* small
pieces, not by writing everything from scratch. **LazyVim uses all the tools below
internally.**

### lazy.nvim — the *plugin manager*
The engine that downloads, updates, lazy-loads, and version-locks plugins. It's the
modern replacement for Vundle (what my Vim uses) / packer / vim-plug. You describe plugins
as Lua tables ("specs"); lazy.nvim installs them. Managed with the `:Lazy` command.

### LSP — the *protocol* for IDE features
LSP (Language Server Protocol) is how the editor gets autocomplete, go-to-definition,
diagnostics, rename, hover docs, etc. For each language you run a **language server** (a
separate background program). Neovim is the *client*; the server does the analysis. Three
plugins wire this up:

- **nvim-lspconfig** — community-maintained recipes telling Neovim how to talk to each
  server (command to run, which filetypes, how to find the project root).
- **Mason (`mason.nvim`)** — a package manager *inside* Neovim that downloads the actual
  server/formatter/linter **binaries** (e.g. `basedpyright`, `clangd`, `gopls`). Managed
  with the `:Mason` command. This is the piece that installs the tools; without it you'd
  install every server by hand.
- **mason-lspconfig** — the glue that auto-installs a server via Mason as soon as you
  enable it in lspconfig.

> **In short:** LazyVim (the whole config) **contains** lazy.nvim (installs plugins), which
> installs lspconfig + Mason (which install and wire up language servers). "Mason" and
> "LazyVim" are not alternatives to each other — one lives inside the other.

---

## What this config contains

This is the complete list of everything that differs from a **bare LazyVim starter**
(the `LazyVim/starter` template, whose `config/*.lua` and `plugins/example.lua` are all
empty). A stock starter enables *no* languages and *no* extras; everything below is added.

### Options / globals changed (`lua/config/options.lua`)
- `vim.g.lazyvim_python_lsp = "basedpyright"` — use basedpyright instead of LazyVim's
  default pyright.
- `textwidth = 100` + `colorcolumn = "100"` — ported from `.vimrc`, with a visual marker.
- `showbreak = "+++"` — ported from `.vimrc`.
- (Other old vim settings — relative numbers, cursorline, smartcase, hlsearch… — are
  already LazyVim defaults, so they aren't repeated.)

### Keymaps added (`lua/config/keymaps.lua`)
Old Vim muscle memory, on top of all LazyVim defaults: `<C-n>` (neo-tree toggle),
`<C-f>` (reveal file), `<C-p>` (find files). See the [table below](#keymaps-i-brought-over-from-vim).

### LazyVim Extras enabled (`import` lines in `lua/config/lazy.lua`)
Each extra pulls in its own language servers/formatters/debug adapters and plugins:

| Extra | Adds |
|-------|------|
| `lang.python` | basedpyright + ruff, `nvim-dap-python`, `neotest-python`, venv-selector |
| `lang.go` | gopls/gofumpt/goimports, `nvim-dap-go`, `neotest-go`, `gopher.nvim` |
| `lang.rust` | `rustaceanvim`, `crates.nvim` (rust-analyzer) |
| `lang.clangd` | clangd + `clangd_extensions.nvim` (C / C++) |
| `lang.typescript` | vtsls + eslint + prettier (JS / TS) |
| `dap.core` | `nvim-dap`, `nvim-dap-ui`, `nvim-nio`, `mason-nvim-dap` — the debugging UI + `<leader>d` keymaps |

### Standalone plugins added (`lua/plugins/*.lua`)
- **nvim-java** stack (`java.lua`) — `nvim-java/nvim-java` + its deps `spring-boot.nvim`,
  `nui.nvim`, `nvim-dap`; plus the `github:nvim-java/mason-registry` and the `java`
  treesitter parser. This **replaces** LazyVim's `lang.java` extra (see [Java](#languages--lsp-set-up) below).
- **tmuxline** (`tmuxline.lua`) — `edkolev/tmuxline.vim`, the one old Vim plugin with no
  LazyVim equivalent; makes the tmux statusline match the colorscheme.
- **html + cssls** (`web.lua`) — the two servers the typescript extra doesn't cover, added
  via an `nvim-lspconfig` `servers` override.
- **kotlin_language_server** (`kotlin.lua`) — Kotlin has no official extra, enabled by hand.
- **render-markdown.nvim** (`markdown.lua`) — renders markdown in-buffer (heading icons,
  code-block backgrounds, aligned tables, bullets, checkboxes). Toggle with `<leader>um`.
  LazyVim's `lang.markdown` extra was deliberately *not* used: it also pulls in marksman,
  markdownlint, markdown-toc, prettier-on-save for `.md` and a browser preview.

### Re-created old Vim plugins (already shipped by LazyVim — no install needed)
vim-airline → **lualine**, ctrlp → **telescope/snacks picker**, nerdtree → **neo-tree**.
Only the keybinds above were added to point at them.

### Net language support
Python, Lua, Web (JS/TS/HTML/CSS), Go, Rust, C/C++, **Java** (via nvim-java), **Kotlin**,
plus step-debugging (DAP) for the languages whose extras provide an adapter.

---

## Directory layout

```
~/.config/nvim/
├── init.lua                     # Entry point (bootstraps lazy.nvim). Don't edit.
├── lua/
│   ├── config/
│   │   ├── lazy.lua             # lazy.nvim bootstrap + language Extras + spec sources
│   │   ├── options.lua          # my ported vim options + a couple of globals
│   │   ├── keymaps.lua          # my custom keymaps (on top of LazyVim defaults)
│   │   └── autocmds.lua         # custom autocommands (empty for now)
│   └── plugins/                 # ← one file per plugin/override. Add files here.
│       ├── java.lua             # nvim-java (replaces LazyVim's lang.java extra)
│       ├── kotlin.lua           # kotlin.nvim (no official extra)
│       ├── web.lua              # html + css language servers
│       ├── markdown.lua         # render-markdown.nvim (in-buffer markdown rendering)
│       ├── claude-code.lua      # claude-code.nvim (Claude Code terminal, <C-,>)
│       ├── explorer.lua         # neo-tree + picker overrides (show git-ignored files)
│       ├── tmuxline.lua         # the tmuxline plugin
│       └── example.lua          # LazyVim's commented example file (reference)
├── lazy-lock.json               # pinned plugin versions (auto-generated)
├── lazyvim.json                 # Extras tracked by :LazyExtras (empty — see note below)
├── .neoconf.json                # neoconf/lua_ls project settings
├── stylua.toml                  # Lua formatting (2 spaces, 120 cols)
└── README.md                    # this file
```

> `lazyvim.json` (which tracks Extras enabled via `:LazyExtras`) exists but its `extras`
> list is **empty** — I enable Extras as explicit `import` lines in `lua/config/lazy.lua`
> instead, so they live in version control. Using `:LazyExtras` would populate that file.

**The two places you'll actually edit:** `lua/config/*.lua` (settings & keymaps) and
`lua/plugins/*.lua` (plugins). Everything under `~/.local/share/nvim/lazy` is
downloaded plugin code — never edit that.

---

## Keymaps I brought over from Vim

Leader key is `<Space>`. In addition to all of LazyVim's defaults, `lua/config/keymaps.lua`
adds my old muscle-memory bindings:

| Key | Action | Old Vim equivalent |
|-----|--------|--------------------|
| `<C-n>` | Toggle file explorer (neo-tree) | `:NERDTreeToggle` |
| `<C-f>` | Reveal current file in explorer | `:NERDTreeFind` |
| `<C-p>` | Find files (fuzzy) | CtrlP |

LazyVim's own equivalents still work too: `<leader>e` (explorer), `<leader>ff` (find
files), `<leader>/` (live grep). Press `<Space>` and wait — **which-key** pops up a menu
of every available binding.

---

## Useful LazyVim shortcuts & workflows

Leader is `<Space>`. These are LazyVim / Neovim defaults (I didn't add them) — the ones
you'll reach for constantly. **Forgotten a binding?** Press `<Space>` and wait for the
which-key popup, or run `:LazyVim` / `<leader>sk` (search keymaps).

### Navigate the code (LSP)

| Key | Action |
|-----|--------|
| `gd` | **Go to definition** (jump to where a symbol is defined) |
| `gD` | Go to declaration |
| `gr` | **See usages / references** (everywhere the symbol is used) |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | **Hover docs** — show signature/docs for the symbol under the cursor |
| `gK` | Signature help (parameter hints) |
| `<leader>ca` | Code action (quick fixes, imports, refactors) |
| `<leader>cr` | Rename symbol (project-wide) |
| `<leader>ss` | Search symbols in this file · `<leader>sS` = workspace symbols |

### Come back / move through jumps

| Key | Action |
|-----|--------|
| `<C-o>` | **Jump back** to where you were before `gd`/search (backwards in the jumplist) |
| `<C-i>` | Jump forward again (reverse of `<C-o>`) |
| `<C-t>` | Pop back up the tag stack (also returns from a definition jump) |
| `<C-6>` / `<leader>bb` | Toggle to the previously-edited buffer |
| `` `` `` | Jump to the position before the last jump |

> Mental model: `gd` to dive in, `<C-o>` to come back. They pair up.

### Diagnostics (errors / warnings)

| Key | Action |
|-----|--------|
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous **error** only |
| `<leader>cd` | Show the diagnostics for the current line |
| `<leader>xx` | Open the diagnostics list (Trouble) for the whole buffer/project |

### Run a `main` / debug

Debugging keymaps come from the `dap.core` extra; the `<leader>d` group is the debugger.

| Key / command | Action |
|---------------|--------|
| `<leader>db` | Toggle breakpoint on the current line |
| `<leader>dc` | **Start / continue** a debug session (pick/attach a launch config) |
| `<leader>di` / `<leader>dO` / `<leader>do` | Step into / over / out |
| `<leader>du` | Toggle the DAP UI (variables, call stack, breakpoints) |
| `<leader>de` | Evaluate the expression under the cursor |
| `<leader>dt` | Terminate the session |
| `:JavaRunnerRunMain` | **Java only:** run the current file's `main` (no debugger). `:JavaRunnerStopMain` to stop, `:JavaRunnerToggleLogs` to see output |

> For Java, `:JavaRunnerRunMain` just *runs* the program; use `<leader>dc` (or
> `:JavaTestDebug…`) when you want breakpoints. nvim-java wires the Java debug adapter into
> DAP automatically.

### Run tests

Two systems, depending on language:

**Neotest** (Python & Go here — provided by their `lang.*` extras). The `<leader>t` group:

| Key | Action |
|-----|--------|
| `<leader>tr` | **Run the nearest test** (the one under the cursor) |
| `<leader>tt` | Run all tests in the current file |
| `<leader>tT` | Run all test files |
| `<leader>td` | Debug the nearest test |
| `<leader>ts` | Toggle the test summary sidebar |
| `<leader>to` / `<leader>tO` | Show output / toggle the output panel |
| `<leader>tS` | Stop running tests · `<leader>tw` toggles watch mode |

**Java** uses nvim-java's own commands (not neotest):

| Command | Action |
|---------|--------|
| `:JavaTestRunCurrentMethod` | Run the test method under the cursor |
| `:JavaTestRunCurrentClass` | Run all tests in the current class |
| `:JavaTestRunAllTests` | Run every test |
| `:JavaTestDebugCurrentMethod` / `:JavaTestDebugCurrentClass` | Same, under the debugger |
| `:JavaTestViewLastReport` | Reopen the last test report |

---

## Git with lazygit

LazyVim bundles [**lazygit**](https://github.com/jesseduffield/lazygit) — a full terminal
UI for git — and opens it in a floating window (requires the `lazygit` binary on `PATH`;
install with `brew install lazygit`). It's the fastest way to stage, commit, branch, and
push without leaving the editor.

### Opening it (from Neovim)

| Key | Action |
|-----|--------|
| `<leader>gg` | **Open lazygit** at the git repo root |
| `<leader>gG` | Open lazygit in the current working directory |
| `<leader>gf` | Lazygit-style history for the **current file** |
| `<leader>gl` | Git log (repo root) · `<leader>gL` = log for cwd |
| `<leader>gb` | Git blame for the current line |
| `<leader>gB` | Open the current line/file on the git host in a browser |

The whole `<leader>g` group is git; `<leader>gh…` are the per-hunk staging actions
(gitsigns): `<leader>ghs` stage hunk, `<leader>ghr` reset hunk, `<leader>ghp` preview,
`<leader>ghb` blame line.

### Inside the lazygit window

lazygit has its own keybindings (press `?` any time for context help). The essentials:

| Key | Action |
|-----|--------|
| `?` | Help — the full keymap for the current panel |
| `←` / `→` or `Tab` | Switch panels (Status · Files · Branches · Commits · Stash) |
| `↑` / `↓` or `j` / `k` | Move within a panel |
| `<Space>` | Stage / unstage the selected file or hunk |
| `a` | Stage / unstage **all** |
| `c` | Commit (opens the message editor) · `A` amend last commit |
| `P` | Push · `p` pull · `f` fetch |
| `b` | Branch menu (create / checkout / merge) · `<Space>` on a branch checks it out |
| `Enter` | Drill into the selected item (files in a commit, hunks in a file) |
| `d` | Discard changes / delete (context-dependent) |
| `x` | Open the menu of actions for the current panel |
| `q` | Quit lazygit and return to Neovim |

> lazygit is a standalone tool — these keys are its own, not Neovim's. Anything you can do
> here you could also do from a plain `lazygit` in a terminal; LazyVim just launches it
> pointed at the right repo.

---

## Languages / LSP set up

Enabled via LazyVim **Extras** in `lua/config/lazy.lua` (plus the manual files
`java.lua`, `kotlin.lua`, `web.lua`). All servers auto-installed through Mason:

| Language | Server(s) | Where configured |
|----------|-----------|------------------|
| Python | basedpyright + ruff | `lazy.lua` + `vim.g.lazyvim_python_lsp` in `options.lua` |
| Lua | lua_ls | LazyVim core |
| JS / TS | vtsls + eslint + prettier | `lazy.lua` (typescript) |
| HTML / CSS | html, cssls | `web.lua` |
| Go | gopls, gofumpt, goimports | `lazy.lua` |
| Rust | rust-analyzer | `lazy.lua` — **run `rustup component add rust-analyzer`** |
| C / C++ | clangd | `lazy.lua` (clangd) |
| Java | jdtls + spring-boot | `java.lua` (**nvim-java** — not the LazyVim extra) |
| Kotlin | kotlin_language_server | `kotlin.lua` (manual — no official extra) |

**Note on Java (`java.lua`):** this uses the [`nvim-java`](https://github.com/nvim-java/nvim-java)
plugin instead of LazyVim's built-in `lang.java` extra. The extra drives Java via `nvim-jdtls`,
which **conflicts with nvim-java** — the two cannot coexist, so the extra import was removed.
nvim-java is an all-in-one (jdtls + DAP + Spring Boot + Lombok + test runner). Two setup details
matter and are handled in `java.lua`: (1) `require("java").setup()` must run **before**
`lspconfig.jdtls.setup()`, so it's deferred to nvim-lspconfig's `setup.jdtls` hook (LazyVim runs
that first); (2) nvim-java's own Mason registry (`github:nvim-java/mason-registry`) is listed
**before** the default so its pinned `jdtls`/`java-debug-adapter`/`java-test` versions win. Opening
a `.java` file attaches both the `jdtls` and `spring-boot` LSP clients. (nvim-java provides no
`:checkhealth java`.)

**Note on Kotlin (`kotlin.lua`):** it has no official LazyVim extra, so it's enabled by
hand. It also needs a non-empty `init_options` — an empty Lua table serializes to a JSON
array (`[]`) and crashes the server on startup (`Expected BEGIN_OBJECT but was
BEGIN_ARRAY`), so we pass a real `storagePath`. That file is a good worked example of a
manual LSP override.

---

## How to add a new plugin

Create a new file in `lua/plugins/` (the name doesn't matter) that **returns a table of
plugin specs**. lazy.nvim automatically picks up every file in that directory.

Minimal example — `lua/plugins/surround.lua`:

```lua
return {
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
}
```

Spec fields you'll use most:
- `"owner/repo"` — the GitHub repo (first positional value).
- `opts = { ... }` — options passed to the plugin's `setup()`. LazyVim/lazy.nvim calls
  `require("plugin").setup(opts)` for you.
- `config = function() ... end` — use instead of `opts` when you need custom setup code.
- `keys = { ... }` — keymaps that also lazy-load the plugin on first use.
- `event` / `ft` / `cmd` — lazy-load triggers (on an event, a filetype, or a command).
- `dependencies = { ... }` — other plugins to load first.

**To override or tweak a plugin LazyVim already ships** (e.g. change lualine, telescope,
treesitter), don't re-declare it from scratch — just add a spec with the same repo name and
your `opts`; lazy.nvim deep-merges them. Example — add treesitter parsers:

```lua
return {
  { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "toml", "dockerfile" } } },
}
```

After editing, run `:Lazy` and press `I` (install) / `U` (update / sync), or just restart
Neovim — lazy.nvim installs anything new on startup.

---

## How to add a new language / LSP server

Two ways:

**1. If LazyVim has an Extra for it (easiest).** Run `:LazyExtras`, find `lang.<name>`,
press `x` to enable it. This edits `lazyvim.json`. (I keep mine as explicit `import`
lines in `lua/config/lazy.lua` instead, which is equivalent and version-controlled —
add a line like `{ import = "lazyvim.plugins.extras.lang.ruby" },`.)

**2. If there's no Extra (manual).** Add the server under nvim-lspconfig's `servers` in a
plugins file — LazyVim auto-installs the matching Mason package. See `lua/plugins/web.lua`
for the pattern:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- name = lspconfig server name; {} = default settings
        bashls = {},
      },
    },
  },
}
```

If auto-install doesn't fire, install the binary manually: `:MasonInstall <package>`
(browse names with `:Mason`).

---

## How to change options and keymaps

- **Options** → `lua/config/options.lua`. Use `vim.opt.<name> = value`
  (e.g. `vim.opt.wrap = false`). These load *before* plugins.
- **Keymaps** → `lua/config/keymaps.lua`. Use
  `vim.keymap.set("n", "<key>", "<action>", { desc = "..." })`.
- **Autocommands** → `lua/config/autocmds.lua`.

LazyVim's own defaults for each of these are linked at the top of the respective file.

---

## Everyday commands & maintenance

| Command | What it does |
|---------|--------------|
| `:Lazy` | Plugin manager UI — install (`I`), update (`U`), clean, profile startup |
| `:Mason` | Browse/install/update language servers, formatters, linters |
| `:LazyExtras` | Toggle LazyVim language/feature packs |
| `:LazyHealth` / `:checkhealth` | Diagnose config/plugin/tool problems |
| `:LspInfo` | Show which language servers are attached to the current buffer |
| `:LspLog` | Tail the LSP log (for debugging a server that won't start) |
| `:Neotree` | Open the file explorer |

Plugin versions are pinned in `lazy-lock.json` (already present in this dir). Commit it if
you version-control this config so installs are reproducible; run `:Lazy update` to bump.

---

## Outstanding toolchain gaps

One language still needs a one-time host step before its server works:

- **Rust** — `cargo` is present, but the analyzer isn't:
  ```
  rustup component add rust-analyzer
  ```

Everything else (Python, Lua, Web, **Go**, C/C++, Java, Kotlin) is installed and verified
working. Go 1.27 was installed via Homebrew, after which Mason built
`gopls`/`gofumpt`/`goimports`. `fd` and `ripgrep` (used by the pickers and venv detection)
are also installed via Homebrew.

---

## Rollback

To go back to the old Vim-shim behavior:

```sh
rm -rf ~/.config/nvim
mv ~/.config/nvim.bak ~/.config/nvim
```

(Vim itself was never touched, so nothing to restore there.)

---

## Learning resources

- LazyVim docs: <https://lazyvim.github.io/>
- lazy.nvim (plugin spec reference): `:help lazy.nvim` or <https://lazy.folke.io/>
- Mason: `:help mason` / <https://github.com/mason-org/mason.nvim>
- Neovim LSP: `:help lsp`
- Learn Lua quickly: `:help lua-guide` (Neovim's own Lua guide)
