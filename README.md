# My Neovim configuration

This is a **[LazyVim](https://lazyvim.github.io/)**-based Neovim setup, written in Lua. This
directory only affects `nvim`.

> Migrated on 2026-09-05 from a 3-line `init.vim` shim that just sourced `~/.vimrc`. The old
> Vim/Vundle config and the `~/.config/nvim.bak` backup have both since been removed — `vim` is
> still installed at `/usr/bin/vim` (9.1) but now runs with no config at all.

Verified versions at the time of writing: **Neovim v0.12.5**, **LazyVim v16.0.0**, 51 plugins
pinned in `lazy-lock.json`.

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

Vim and Neovim read **completely different files by default** — the only reason they were ever
coupled here is that the old `init.vim` deliberately repointed Neovim back at Vim's files. Now
that it's gone, they share nothing:

| | Vim | Neovim (this config) |
|---|---|---|
| Config entry | `~/.vimrc` *(no longer present)* | `~/.config/nvim/init.lua` |
| Plugin dir | `~/.vim/bundle` (Vundle) *(no longer present)* | `~/.local/share/nvim/lazy` (lazy.nvim) |
| Data / state / cache | `~/.vim` | `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim` |

So editing this config can never affect Vim, and vice-versa. On this machine the Vim side is
empty anyway — `~/.vim` holds only a `.netrwhist` file.

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
modern replacement for Vundle / packer / vim-plug. You describe plugins as Lua tables
("specs"); lazy.nvim installs them. Managed with the `:Lazy` command.

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
- `vim.g.lazyvim_explorer = "neo-tree"` — replace LazyVim's default `snacks.explorer` with
  neo-tree, so the ported `<C-n>` / `<C-f>` NERDTree keymaps below actually resolve.
- `textwidth = 100` + `colorcolumn = "100"` — ported from the old `.vimrc`, with a visual marker.
- `showbreak = "+++"` — ported from the old `.vimrc`.
- (Other old vim settings — relative numbers, cursorline, smartcase, hlsearch… — are
  already LazyVim defaults, so they aren't repeated.)

### Keymaps added (`lua/config/keymaps.lua`)
Old Vim muscle memory, on top of all LazyVim defaults: `<C-n>` (neo-tree toggle),
`<C-f>` (reveal file), `<C-p>` (find files). See the [table below](#keymaps-i-brought-over-from-vim).

### lazy.nvim behaviour changed (`lua/config/lazy.lua`)
Non-default plugin-manager settings, worth knowing because they change how updates behave:

- `defaults.lazy = false` — plugins in `lua/plugins/` load **eagerly** at startup (LazyVim's
  own plugins are still lazy-loaded).
- `version = false` — track the latest git commit rather than the latest tag.
- `checker = { enabled = true, notify = false }` — lazy.nvim checks for plugin updates
  periodically but stays quiet about it; `:Lazy` shows what's pending.
- `install.colorscheme = { "tokyonight", "habamax" }` — colorscheme used while installing.
- `performance.rtp.disabled_plugins` — Neovim's built-in `gzip`, `tarPlugin`, `tohtml`,
  `tutor`, `zipPlugin` are switched off for startup time.

### LazyVim Extras enabled (`import` lines in `lua/config/lazy.lua`)
Each extra pulls in its own language servers/formatters/debug adapters and plugins:

| Extra | Adds |
|-------|------|
| `lang.python` | ruff, `nvim-dap-python`, `venv-selector.nvim`, `ninja`/`rst` parsers. Note: the extra's *default* server is plain pyright — basedpyright comes from the `vim.g` override above. Its `neotest-python` spec is `optional` and never loads (see [Run tests](#run-tests)) |
| `lang.go` | gopls, `gofumpt` + `goimports`, `golangci-lint` (via nvim-lint), `delve` + `nvim-dap-go`. Its `neotest-golang` spec is `optional` and never loads |
| `lang.rust` | `rustaceanvim`, `crates.nvim`, `codelldb`. It sets `rust_analyzer = { enabled = false }` in lspconfig on purpose — rustaceanvim owns the server itself |
| `lang.clangd` | clangd + `clangd_extensions.nvim` (C / C++), `codelldb` and the C/C++ DAP launch configs, `<leader>ch` to switch source/header |
| `lang.typescript` | **vtsls only** (+ `js-debug-adapter` and the pwa-node/chrome/msedge DAP adapters). It does *not* include eslint or prettier — those are separate `linting.eslint` / `formatting.prettier` extras, neither of which is imported here |
| `dap.core` | `nvim-dap`, `nvim-dap-ui`, `nvim-nio`, `nvim-dap-virtual-text`, `mason-nvim-dap` — the debugging UI + `<leader>d` keymaps |

### Standalone plugins added (`lua/plugins/*.lua`)
- **nvim-java** (`java.lua`) — `nvim-java/nvim-java`, plus the
  `github:nvim-java/mason-registry` and the `java` treesitter parser. This file declares only
  `nvim-lspconfig` as a dependency; `spring-boot.nvim`, `nui.nvim` and `nvim-dap` come
  transitively from nvim-java's own spec. This **replaces** LazyVim's `lang.java` extra (see
  [Java](#languages--lsp-set-up) below).
- **kotlin.nvim** (`kotlin.lua`) — `AlexandrosAlexiou/kotlin.nvim`, loaded on `ft = kotlin`,
  with deps `mason.nvim`, `mason-lspconfig.nvim`, `oil.nvim`, `trouble.nvim`. It drives
  JetBrains' `kotlin-lsp` (the IntelliJ-based server) and starts the client itself. Also adds
  the `kotlin` treesitter parser and an `automatic_enable = { exclude = { "kotlin_lsp" } }`
  override on mason-lspconfig. See the [Kotlin note](#languages--lsp-set-up) — **the server
  binary is not installed yet**.
- **claude-code.nvim** (`claude-code.lua`) — `greggh/claude-code.nvim` + `plenary.nvim`;
  toggles a Claude Code terminal inside Neovim. `<C-,>` toggles it in **both** normal and
  terminal mode; the plugin also maps `<leader>cC` (continue) and `<leader>cV` (verbose), and
  defines `:ClaudeCode`, `:ClaudeCodeContinue`, `:ClaudeCodeResume`, `:ClaudeCodeVerbose`,
  `:ClaudeCodeVersion`. Two gotchas: `<leader>cC` collides with LazyVim's *Refresh & Display
  Codelens* (which is buffer-local on LSP attach, so it wins in any LSP buffer), and inside the
  Claude terminal buffer the plugin remaps `<C-h/j/k/l>` (window navigation) and `<C-f>`/`<C-b>`
  (page up/down) — so `<C-f>` does *not* reveal files there.
- **explorer / picker overrides** (`explorer.lua`) — neo-tree's `filtered_items` and the snacks
  `files` picker are both set to show dotfiles **and** git-ignored files. Why: `~/.gitconfig`
  sets `core.excludesfile = ~/.gitignore_global`, so that machine-wide list (`CLAUDE.md`,
  `.claude/`, `AGENTS.md`, `target/`, `.idea/`, …) is ignored in *every* repo, which made those
  files invisible in any git checkout. Note that lazy.nvim **replaces** list-valued opts rather
  than merging them, which is why `hide_by_name` respells neo-tree's two defaults
  (`.DS_Store`, `thumbs.db`) alongside `.git`.
- **render-markdown.nvim** (`markdown.lua`) — renders markdown in-buffer (heading icons,
  code-block backgrounds, aligned tables, bullets, checkboxes). Toggle with `<leader>um`.
  LazyVim's `lang.markdown` extra was deliberately *not* used: it also pulls in marksman,
  markdownlint, markdown-toc, prettier-on-save for `.md` and a browser preview.
- **tmuxline** (`tmuxline.lua`) — `edkolev/tmuxline.vim`, the one old Vim plugin with no
  LazyVim equivalent; makes the tmux statusline match the colorscheme.
- **html + cssls** (`web.lua`) — the two servers the typescript extra doesn't cover, added
  via an `nvim-lspconfig` `servers` override.

> `lua/plugins/example.lua` is **inert** — its third line is `if true then return {} end`, so
> none of the sample specs below it are in effect. It's kept as a reference only.

### Re-created old Vim plugins (already shipped by LazyVim — no install needed)
vim-airline → **lualine**, ctrlp → **snacks picker**, nerdtree → **neo-tree**.
Only the keybinds above were added to point at them.

### Net language support
Python, Lua, Web (JS/TS/HTML/CSS), Go, C/C++ and **Java** are wired up and have their servers
installed. **Rust** and **Kotlin** are configured but their servers are missing — see
[Outstanding toolchain gaps](#outstanding-toolchain-gaps). Step-debugging (DAP) is available for
the languages whose extras provide an adapter; there is currently **no test runner** installed.

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
│       ├── kotlin.lua           # kotlin.nvim, driving JetBrains' kotlin-lsp
│       ├── web.lua              # html + css language servers
│       ├── markdown.lua         # render-markdown.nvim (in-buffer markdown rendering)
│       ├── claude-code.lua      # claude-code.nvim (Claude Code terminal, <C-,>)
│       ├── explorer.lua         # neo-tree + picker overrides (show git-ignored files)
│       ├── tmuxline.lua         # the tmuxline plugin
│       └── example.lua          # LazyVim's example file — DISABLED, reference only
├── lazy-lock.json               # pinned plugin versions (auto-generated, 51 plugins)
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

Two more keymaps come from this config's **plugin** files rather than `keymaps.lua`:

| Key | Action | Defined in |
|-----|--------|------------|
| `<C-,>` | Toggle the Claude Code terminal (normal **and** terminal mode) | `claude-code.lua` (the plugin's own default — the file sets no `keys`) |
| `<leader>um` | Toggle in-buffer markdown rendering | `markdown.lua` (via `Snacks.toggle`) |

LazyVim's own equivalents still work too: `<leader>e` (explorer), `<leader>ff` (find
files), `<leader>/` (grep in root dir). Press `<Space>` and wait — **which-key** pops up a menu
of every available binding.

---

## Useful LazyVim shortcuts & workflows

Leader is `<Space>`. These are LazyVim / Neovim defaults (I didn't add them) — the ones
you'll reach for constantly. **Forgotten a binding?** Press `<Space>` and wait for the
which-key popup, or run `<leader>sk` (search keymaps).

### Navigate the code (LSP)

| Key | Action |
|-----|--------|
| `gd` | **Go to definition** (jump to where a symbol is defined) |
| `gD` | Go to declaration |
| `gr` | **See usages / references** (everywhere the symbol is used) |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | **Hover docs** — show signature/docs for the symbol under the cursor |
| `gK` | Signature help (parameter hints) — `<C-k>` in insert mode |
| `<leader>ca` | Code action (quick fixes, imports, refactors) — normal **and** visual mode |
| `<leader>cr` | Rename symbol (project-wide) |
| `<leader>ss` | Search symbols in this file · `<leader>sS` = workspace symbols |
| `<leader>cl` | Show LSP info for the current buffer |

> In LazyVim v16 the results for `gd`, `gr`, `<leader>ss` and `<leader>sS` open in the **snacks
> picker** rather than a quickfix list.

### Come back / move through jumps

These are **plain Neovim builtins** — they work in vanilla vim too, with or without LazyVim:

| Key | Action |
|-----|--------|
| `<C-o>` | **Jump back** to where you were before `gd`/search (backwards in the jumplist) |
| `<C-i>` | Jump forward again (reverse of `<C-o>`) |
| `<C-t>` | Pop back up the tag stack (also returns from a definition jump) |
| `<C-6>` | Toggle to the previously-edited buffer (`<C-^>`) |
| `` `` `` | Jump to the position before the last jump |

And one from LazyVim:

| Key | Action |
|-----|--------|
| `<leader>bb` | Switch to the other (previous) buffer — `<leader>`` ` is an alias |

> Mental model: `gd` to dive in, `<C-o>` to come back. They pair up.

### Diagnostics (errors / warnings)

| Key | Action |
|-----|--------|
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous **error** only |
| `]w` / `[w` | Next / previous **warning** only |
| `<leader>cd` | Show the diagnostics for the current line |
| `<leader>xx` | Diagnostics list (Trouble) for the whole **workspace** |
| `<leader>xX` | Diagnostics list (Trouble) for the current **buffer** only |

### Run a `main` / debug

Debugging keymaps come from the `dap.core` extra; the `<leader>d` group is the debugger.

| Key / command | Action |
|---------------|--------|
| `<leader>db` | Toggle breakpoint on the current line |
| `<leader>dc` | **Start / continue** a debug session (pick/attach a launch config) |
| `<leader>di` / `<leader>dO` / `<leader>do` | Step into / over / out |
| `<leader>du` | Toggle the DAP UI (variables, call stack, breakpoints) |
| `<leader>de` | Evaluate the expression under the cursor (normal **and** visual mode) |
| `<leader>dt` | Terminate the session |
| `:JavaRunnerRunMain` | **Java only:** run the current file's `main` (no debugger). `:JavaRunnerStopMain` to stop, `:JavaRunnerToggleLogs` to see output |

> ⚠️ Java debugging does not work yet — `java-debug-adapter` isn't installed. See
> [Outstanding toolchain gaps](#outstanding-toolchain-gaps). Once it is, `<leader>dc` works on
> Java too and nvim-java wires the adapter into DAP automatically; `:JavaRunnerRunMain` only
> *runs* the program, with no breakpoints.

### Run tests

**There is no test runner installed in this config.** LazyVim drives tests through
[neotest](https://github.com/nvim-neotest/neotest), which comes from the `test.core` extra —
that extra is **not imported**. The `lang.python` and `lang.go` extras each declare a neotest
adapter, but marked `optional = true`, meaning they only *configure* neotest if something else
installs it. Nothing does, so neotest is absent from `lazy-lock.json` and **none of the
`<leader>t*` test keymaps exist**.

To enable it, add one line to `lua/config/lazy.lua`:

```lua
{ import = "lazyvim.plugins.extras.test.core" },
```

That would install neotest plus the Python and Go adapters, and create the `<leader>t` group
(`tr` run nearest, `tt` run file, `tT` run all files, `td` debug nearest, `ts` toggle summary,
`to`/`tO` output, `tS` stop, `tw` watch).

**Java** uses nvim-java's own commands instead of neotest — these are real and registered by the
plugin, but ⚠️ they need the `java-test` Mason package, which **isn't installed yet**:

| Command | Action |
|---------|--------|
| `:JavaTestRunCurrentMethod` | Run the test method under the cursor |
| `:JavaTestRunCurrentClass` | Run all tests in the current class |
| `:JavaTestRunAllTests` | Run every test |
| `:JavaTestDebugCurrentMethod` / `:JavaTestDebugCurrentClass` / `:JavaTestDebugAllTests` | Same, under the debugger |
| `:JavaTestViewLastReport` | Reopen the last test report |

nvim-java also registers `:JavaProfile`, `:JavaDapConfig`, `:JavaSettingsChangeRuntime`,
`:JavaRunnerSwitchLogs`, and — once jdtls attaches — `:JavaRefactorExtract*` and
`:JavaBuildBuildWorkspace` / `:JavaBuildCleanWorkspace`.

---

## Git with lazygit

LazyVim bundles [**lazygit**](https://github.com/jesseduffield/lazygit) — a full terminal
UI for git — and opens it in a floating window. The keymap is guarded on
`vim.fn.executable("lazygit")`, so it only appears if the binary is on `PATH` (installed here
via Homebrew: `/opt/homebrew/bin/lazygit`, 0.63.1). It's the fastest way to stage, commit,
branch, and push without leaving the editor.

### Opening it (from Neovim)

| Key | Action |
|-----|--------|
| `<leader>gg` | **Open lazygit** at the git repo root |
| `<leader>gG` | Open lazygit in the current working directory |
| `<leader>gf` | History for the **current file** (a snacks picker, not lazygit) |
| `<leader>gl` | Git log (repo root) · `<leader>gL` = log for cwd |
| `<leader>gb` | Git blame for the current line |
| `<leader>gB` | Open the current line/file on the git host in a browser (normal **and** visual) |
| `<leader>gY` | Same, but copy the URL instead of opening it |

The whole `<leader>g` group is git; `<leader>gh…` are the per-hunk staging actions
(gitsigns, buffer-local): `<leader>ghs` stage hunk and `<leader>ghr` reset hunk (both work in
visual mode too), `<leader>ghp` preview the hunk **inline**, `<leader>ghb` blame line.

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
`java.lua`, `kotlin.lua`, `web.lua`). Servers are auto-installed through Mason unless noted:

| Language | Server(s) | Where configured | Installed? |
|----------|-----------|------------------|-----------|
| Python | basedpyright + ruff | `lazy.lua` + `vim.g.lazyvim_python_lsp` in `options.lua` | ✅ |
| Lua | lua_ls | LazyVim core | ✅ |
| JS / TS | vtsls | `lazy.lua` (typescript) | ✅ (no eslint/prettier — see below) |
| HTML / CSS | html, cssls | `web.lua` | ✅ |
| Go | gopls, gofumpt, goimports, golangci-lint | `lazy.lua` | ✅ |
| Rust | rust-analyzer (driven by rustaceanvim, not Mason) | `lazy.lua` | ⚠️ **missing** — see [gaps](#outstanding-toolchain-gaps) |
| C / C++ | clangd | `lazy.lua` (clangd) | ✅ |
| Java | jdtls (+ spring-boot) | `java.lua` (**nvim-java** — not the LazyVim extra) | ⚠️ jdtls only; spring-boot / debug / test tooling **missing** |
| Kotlin | kotlin-lsp (JetBrains) | `kotlin.lua` (**kotlin.nvim** — not an lspconfig server) | ⚠️ **missing** — see [gaps](#outstanding-toolchain-gaps) |

**eslint / prettier are not set up.** The `lang.typescript` extra provides vtsls only; eslint
and prettier live in separate `linting.eslint` and `formatting.prettier` extras, neither of
which is imported, and neither binary is installed.

Mason also has these installed, used by the extras above but not shown in the table:
`codelldb`, `debugpy`, `delve`, `js-debug-adapter`, `shfmt`, `stylua`.

**Note on Java (`java.lua`):** this uses the [`nvim-java`](https://github.com/nvim-java/nvim-java)
plugin instead of LazyVim's built-in `lang.java` extra. The extra drives Java via `nvim-jdtls`,
which **conflicts with nvim-java** — the two cannot coexist, so the extra import was removed.
nvim-java is an all-in-one (jdtls + DAP + Spring Boot + Lombok + test runner). Two setup details
matter and are handled in `java.lua`: (1) `require("java").setup()` must run **before**
`lspconfig.jdtls.setup()`, so it's deferred to nvim-lspconfig's `setup.jdtls` hook (LazyVim runs
that first); (2) nvim-java's own Mason registry (`github:nvim-java/mason-registry`) is listed
**before** the default so its pinned `jdtls`/`java-debug-adapter`/`java-test` versions win —
though that only matters once those last two are actually installed, which they aren't yet. So
today a `.java` file attaches `jdtls` alone; the `spring-boot` client can't start without its
server binary. (nvim-java provides no `:checkhealth java`.)

**Note on Kotlin (`kotlin.lua`):** LazyVim v16 *does* ship a `lang.kotlin` extra, but this
config uses [`kotlin.nvim`](https://github.com/AlexandrosAlexiou/kotlin.nvim) instead, which
drives JetBrains' newer IntelliJ-based `kotlin-lsp`. Two consequences:

1. kotlin.nvim **starts and manages the LSP client itself**, so Kotlin is deliberately *not*
   registered under nvim-lspconfig's `servers` — unlike `web.lua`.
2. Because of that, mason-lspconfig must **not** auto-enable `kotlin_lsp`, or a second,
   conflicting client spawns. Hence `automatic_enable = { exclude = { "kotlin_lsp" } }`.

First run needs `:MasonInstall kotlin-lsp` — see [gaps](#outstanding-toolchain-gaps).
For a worked example of a plain **manual LSP override**, read `lua/plugins/web.lua` instead.

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

> Careful: deep-merge applies to *tables*, but **list-valued** opts are **replaced**, not
> appended. `lua/plugins/explorer.lua` shows the consequence — it has to respell neo-tree's
> default `hide_by_name` entries because setting that key wipes them.

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
| `:Lazy clean` | Delete plugins on disk that no longer appear in any spec |
| `:Mason` | Browse/install/update language servers, formatters, linters |
| `:MasonInstall kotlin-lsp` | One-time install of the Kotlin language server (see gaps) |
| `:LazyExtras` | Toggle LazyVim language/feature packs |
| `:LazyHealth` / `:checkhealth` | Diagnose config/plugin/tool problems |
| `:LazyRoot` | Show the root directory LazyVim resolved for this buffer |
| `:LspInfo` | Now just an alias for `:checkhealth vim.lsp`; `<leader>cl` is the native equivalent |
| `:LspLog` | Tail the LSP log (for debugging a server that won't start) |
| `:Neotree` | Open the file explorer |
| `:ClaudeCode` | Open/toggle the Claude Code terminal (same as `<C-,>`) |

> The full set of LazyVim commands is `:LazyExtras`, `:LazyHealth`, `:LazyRoot`, `:LazyFormat`
> and `:LazyFormatInfo` — there is no `:LazyVim` command.

Plugin versions are pinned in `lazy-lock.json` (already present in this dir). Commit it if
you version-control this config so installs are reproducible; run `:Lazy update` to bump.

---

## Outstanding toolchain gaps

Four things are configured but not yet working:

- **Kotlin — no server installed.** `kotlin.lua` expects `kotlin-lsp`, but Mason only has the
  older `kotlin-language-server`, a leftover from the previous hand-rolled setup. Fix:
  ```
  :MasonInstall kotlin-lsp
  :MasonUninstall kotlin-language-server   # stale, no longer referenced
  ```
- **Java — no debugger, tests, or Spring Boot.** Mason has `jdtls` but not
  `java-debug-adapter`, `java-test`, or the spring-boot language server, so `<leader>d*` and
  the `:JavaTest*` commands will fail on Java files and only the `jdtls` client attaches.
  Install those three via `:Mason`.
- **Rust — the analyzer isn't installed.** `cargo` and `rustup` are present, and
  `~/.cargo/bin/rust-analyzer` exists, but it's only a rustup **proxy symlink** — running it
  errors with `Unknown binary 'rust-analyzer'`. Fix:
  ```
  rustup component add rust-analyzer
  ```
- **No test runner.** neotest isn't installed; see [Run tests](#run-tests) for the one-line fix.

Verified working: Python, Lua, Web (HTML/CSS/TS), **Go**, C/C++, and Java's `jdtls`. Go 1.26.5
was installed via Homebrew, after which Mason built `gopls`/`gofumpt`/`goimports`.
**ripgrep** (15.2.0, used by the pickers) is installed via Homebrew; **`fd` is not** — install
it with `brew install fd` if the pickers or venv detection want it.

One oddity worth knowing: `~/.local/share/nvim/lazy/goto-line.nvim` exists on disk but appears
in no plugin spec and no `lazy-lock.json` entry — an orphan from an earlier experiment.
`:Lazy clean` would remove it.

---

## Rollback

This directory is version-controlled, so git *is* the rollback mechanism:

```sh
cd ~/.config/nvim
git log --oneline        # find the commit you want
git revert <commit>      # undo one change
```

There's nothing else to restore — the old `~/.config/nvim.bak` shim and the Vim/Vundle config
it pointed at have both been deleted. `vim` still runs, with no config.

---

## Learning resources

- LazyVim docs: <https://lazyvim.github.io/>
- lazy.nvim (plugin spec reference): `:help lazy.nvim` or <https://lazy.folke.io/>
- Mason: `:help mason` / <https://github.com/mason-org/mason.nvim>
- Neovim LSP: `:help lsp`
- Learn Lua quickly: `:help lua-guide` (Neovim's own Lua guide)
