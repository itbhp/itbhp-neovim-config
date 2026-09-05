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
6. [Languages / LSP set up](#languages--lsp-set-up)
7. [How to add a new plugin](#how-to-add-a-new-plugin)
8. [How to add a new language / LSP server](#how-to-add-a-new-language--lsp-server)
9. [How to change options and keymaps](#how-to-change-options-and-keymaps)
10. [Everyday commands & maintenance](#everyday-commands--maintenance)
11. [Outstanding toolchain gaps](#outstanding-toolchain-gaps)
12. [Rollback](#rollback)
13. [Learning resources](#learning-resources)

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

Compared to a stock LazyVim starter, I added/changed:

- **Ported my `.vimrc` settings** — `textwidth=100` (+ a `colorcolumn` marker) and
  `showbreak=+++`. Most other old settings (relative numbers, cursorline, smartcase,
  hlsearch…) are already LazyVim defaults, so they aren't repeated.
- **Re-created my old Vim plugins** with LazyVim's modern equivalents:
  vim-airline → **lualine**, ctrlp → **telescope/snacks picker**, nerdtree → **neo-tree**.
  My old keybinds (`<C-n>`, `<C-f>`, `<C-p>`) are mapped onto them.
- **tmuxline** — the one Vim plugin with no LazyVim equivalent, added as-is
  (`lua/plugins/tmuxline.lua`).
- **Language support** for Python, Lua, Web (JS/TS/HTML/CSS), Go, Rust, C/C++, Java, and
  **Kotlin** (see below).

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
│       ├── kotlin.lua           # manual Kotlin LSP (no official extra)
│       ├── web.lua              # html + css language servers
│       ├── tmuxline.lua         # the tmuxline plugin
│       └── example.lua          # LazyVim's commented example file (reference)
├── lazy-lock.json               # pinned plugin versions (auto-generated)
└── README.md                    # this file
```

> `lazyvim.json` (which tracks Extras enabled via `:LazyExtras`) is **not** present here —
> I enable Extras as explicit `import` lines in `lua/config/lazy.lua` instead, so they
> live in version control. If you ever use `:LazyExtras`, that file will appear.

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

## Languages / LSP set up

Enabled via LazyVim **Extras** in `lua/config/lazy.lua` (plus two manual files). All
servers auto-installed through Mason:

| Language | Server(s) | Where configured |
|----------|-----------|------------------|
| Python | basedpyright + ruff | `lazy.lua` + `vim.g.lazyvim_python_lsp` in `options.lua` |
| Lua | lua_ls | LazyVim core |
| JS / TS | vtsls + eslint + prettier | `lazy.lua` (typescript) |
| HTML / CSS | html, cssls | `web.lua` |
| Go | gopls, gofumpt, goimports | `lazy.lua` |
| Rust | rust-analyzer | `lazy.lua` — **run `rustup component add rust-analyzer`** |
| C / C++ | clangd | `lazy.lua` (clangd) |
| Java | jdtls | `lazy.lua` |
| Kotlin | kotlin_language_server | `kotlin.lua` (manual — no official extra) |

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
