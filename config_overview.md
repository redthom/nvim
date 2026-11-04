# Neovim Config Overview

How this config is laid out, what each file does, and the order Neovim runs it in.
For keymaps see `commands.md`. For the Java debugger see `java_debugging.md`.

## Layout

```
~/.config/nvim/
├── init.lua                  entry point: loads lazy, enables LSP servers, keymaps, options
├── lazy-lock.json            exact plugin versions installed by lazy.nvim (commit this)
├── lua/
│   ├── config/
│   │   └── lazy.lua          installs lazy.nvim and sets the plugin list
│   └── plugins/              one file per plugin, all loaded by `{ import = "plugins" }`
│       ├── dap.lua           nvim-dap (debugger) + <leader>d… keymaps
│       ├── jdtls.lua         nvim-jdtls (Java language server + debugger wiring)
│       ├── mini_icons.lua    icons
│       ├── mini_statusline.lua  status line
│       ├── telescope.lua     fuzzy finder + <leader>f… keymaps
│       └── treesitter.lua    syntax parsers
├── lsp/
│   └── lua_ls.lua            settings for the Lua language server
├── after/ftplugin/           per-filetype settings, run when a file of that type opens
│   ├── c.lua
│   ├── gitcommit.lua
│   ├── java.lua              Java settings + starts jdtls
│   ├── lua.lua
│   └── markdown.lua
└── plugins/test.lua          NOT loaded (see "Notes" at the bottom)
```

## Startup order

1. Neovim runs `init.lua`.
2. `require("config.lazy")` runs `lua/config/lazy.lua`:
   1. Downloads lazy.nvim into `~/.local/share/nvim/lazy/lazy.nvim` if it isn't there yet.
   2. Sets the leader key to `<space>` and the local leader to `\`. This has to happen before any plugin keymaps are defined.
   3. Calls `require("lazy").setup(...)` with the plugin list. Lazy installs missing plugins and loads the ones that aren't lazy-loaded.
3. Back in `init.lua`: `vim.lsp.enable({ "lua_ls", "clangd" })` turns those language servers on (step 5 covers when they actually start).
4. `init.lua` sets keymaps and options, then creates the yank-highlight autocommand.
5. Later, whenever you open a file, Neovim detects its filetype and then:
   - runs the matching `after/ftplugin/<filetype>.lua`
   - starts any enabled LSP server for that filetype (`lua_ls` for Lua, `clangd` for C/C++)
   - for Java, `after/ftplugin/java.lua` starts jdtls itself

## `init.lua`

| Section | What it does |
|---|---|
| `require("config.lazy")` | Loads the plugin manager and all plugins (see below). |
| `vim.lsp.enable(...)` | Uses Neovim's built-in LSP client to enable `lua_ls` and `clangd`. Each server's default command and root detection come from **nvim-lspconfig**, which ships ready-made configs in its own `lsp/` folder. Anything in your `lsp/<name>.lua` gets merged on top. jdtls isn't listed here because nvim-jdtls starts it. |
| Key Maps | `<space><space>x` sources the current file, `<space>x` runs the current line (or selection) as Lua, `<Esc>` clears search highlights, `gd` goes to definition. |
| Appearance | Nerd font flag, hides `-- INSERT --` (the status line shows the mode instead), shows tabs/trailing spaces/nbsp, true color, highlights the cursor line. |
| Formatting | Absolute + relative line numbers, 2-space indent by default. |
| Work flow | Uses the system clipboard, smart-case search, live preview for `:s` substitutions (`inccommand = 'split'`), and asks before closing a buffer with unsaved changes (`confirm`). |
| Yank highlight | An autocommand on `TextYankPost` briefly highlights whatever you just yanked. |

`vim.opt` sets an option globally. `vim.opt_local` (used in the ftplugins) sets it only for the current buffer/window.

## `lua/config/lazy.lua`

- **Bootstrap block:** if `lazy.nvim` isn't on disk, it `git clone`s the stable branch. If the clone fails it shows the error and exits.
- **`vim.opt.rtp:prepend(lazypath)`** puts lazy.nvim on the runtime path so `require("lazy")` can find it.
- **`spec`** is the plugin list:
  - `glepnir/zephyr-nvim`: the colorscheme. Its `config` function runs `:colorscheme zephyr`. The commented-out kanagawa lines are other themes you can switch to.
  - `{ import = "plugins" }`: loads every file in `lua/plugins/`. Each file returns one **plugin spec** (see below).
  - `neovim/nvim-lspconfig`: has no setup of its own. It supplies the default server configs that `vim.lsp.enable` uses.

### What a plugin spec is

Each file in `lua/plugins/` returns a table that tells lazy **what** to install and **when** to load it:

| Key | Meaning |
|---|---|
| `'owner/repo'` (first entry) | GitHub repo to install. |
| `version = '*'` | Use the latest tagged release instead of the newest commit. |
| `dependencies` | Other plugins to install and load first. |
| `opts = {}` | Calls the plugin's `require('<name>').setup(opts)` for you. |
| `config = function() ... end` | Runs your own setup code once the plugin loads (use this instead of `opts` when you need more than `setup`). |
| `build` | Command to run after install/update (e.g. `make`, `:TSUpdate`). |
| `lazy = false` | Load at startup. |
| `keys = { ... }` | Don't load until one of these keys is pressed. The keys get mapped right away. |
| `ft = 'java'` | Don't load until a file of this type is opened. |

Also, calling `require('x')` on a plugin that hasn't loaded yet makes lazy load it on the spot.

## Plugins (`lua/plugins/`)

### `telescope.lua`: fuzzy finder
- Installs telescope from its latest release, plus its dependencies:
  - `plenary.nvim`: required Lua helper library
  - `telescope-fzf-native.nvim`: faster sorting, built with `make`
  - `nvim-web-devicons`: file icons
- `ripgrep` and `fd` are listed as dependencies, but they're command-line programs, not Neovim plugins. Telescope uses whatever `rg`/`fd` it finds on your `PATH`.
- `config` defines `<leader>ff` (files), `<leader>fg` (live grep), `<leader>fb` (buffers) and `<leader>fh` (help tags).

### `treesitter.lua`: syntax parsers
- `lazy = false`: loads at startup.
- `build = ':TSUpdate'` updates the parsers whenever the plugin itself updates.
- `config` installs parsers for go, java, lua, python and rust. Neovim uses them for syntax highlighting and other syntax-aware features.

### `mini_icons.lua` / `mini_statusline.lua`
- `opts = {}` runs each plugin's `setup()` with its default settings. mini.statusline draws the bottom bar (mode, git info, diagnostics, file info, cursor position).

### `dap.lua`: debugger (nvim-dap)
- nvim-dap is the debugger client. It talks to a language-specific **debug adapter** using the Debug Adapter Protocol (DAP).
- `keys` sets the `<leader>d…` mappings (breakpoint, continue, step over/into/out, REPL, terminate). Each mapping is a small function that calls `require('dap')`, so the plugin only loads the first time you press one.
- This file doesn't set up any adapters. Each language's adapter is set up elsewhere (Java: `jdtls.lua`).

### `jdtls.lua`: Java support (nvim-jdtls)
- Installs `mfussenegger/nvim-jdtls`. It's lazy-loaded when you open a Java file (`ft = 'java'`) and depends on nvim-dap, so nvim-dap loads first.
- The actual configuration is in `after/ftplugin/java.lua`, because it has to run once for every Java buffer.

## `lsp/lua_ls.lua`

Settings that get merged into lspconfig's defaults for `lua_ls`.
`workspace.library = vim.api.nvim_get_runtime_file("", true)` tells the Lua server about every folder on Neovim's runtime path, including all plugins, so it knows about `vim.*` and the plugin APIs. That gives you completion and fewer "undefined global `vim`" warnings.

## `after/ftplugin/*.lua`: per-filetype settings

Files in `after/ftplugin/` run **after** Neovim's built-in settings for that filetype, so yours take priority.

| File | Settings |
|---|---|
| `c.lua` | 4-space indent, line numbers |
| `lua.lua` | 2-space indent, line numbers |
| `markdown.lua` | 4-space indent, spell check, soft line wrap, line numbers |
| `gitcommit.lua` | guide columns at 51 and 73 (subject/body length), spell check |
| `java.lua` | 4-space indent, line numbers, **and starts jdtls** (below) |

### `after/ftplugin/java.lua` in detail

1. **Formatting:** 4-space indent and line numbers, like `c.lua`.
2. **Find the project root:** looks upward from the file for the nearest `src` folder and uses the folder above it as the root. If there's no `src` folder, the script stops here and jdtls doesn't start for that file.
3. **Find the java-debug jar:** looks for `com.microsoft.java.debug.plugin-*.jar` in `~/.local/share/java-debug/`. That jar is an extension that jdtls loads so you can debug. If it's missing, you get a warning once per Neovim session and everything works except debugging.
4. **Workspace folder:** jdtls stores its project index in `~/.cache/nvim/jdtls/workspace/<project-folder-name>`, one per project.
5. **`require('jdtls').start_or_attach({...})`:**
   - `cmd`: runs your manually installed jdtls (`~/.local/share/jdtls/bin/jdtls`) with `-data <workspace>`.
   - `root_dir`: the root found in step 2. If a jdtls for this root is already running, the buffer attaches to it instead of starting a second one.
   - `init_options.bundles`: the java-debug jar, which jdtls loads as an extension.
   - `settings.java`: treats `src` as the source folder, and stops jdtls from writing `.project`/`.classpath` files into your project.
6. When jdtls is ready, nvim-jdtls sees that java-debug is loaded and registers a `java` debug adapter with nvim-dap. It also adds `:JdtUpdateDebugConfig` and `:JdtUpdateHotcode`.

## External tools this config expects (installed manually, no Mason)

| Tool | Location | Used by |
|---|---|---|
| jdtls | `~/.local/share/jdtls/` | `after/ftplugin/java.lua` |
| java-debug jar | `~/.local/share/java-debug/` | Java debugging |
| lua-language-server, clangd | on `PATH` | `vim.lsp.enable` |
| ripgrep (`rg`), fd | on `PATH` | telescope |
| `make`, a C compiler | on `PATH` | building telescope-fzf-native |
| Java (JDK) | on `PATH` | jdtls and running/debugging programs |

## Notes

- `plugins/test.lua` (at the top level of the config) **never runs**. `{ import = "plugins" }` only looks in `lua/plugins/`, and Neovim doesn't load a top-level `plugins/` folder by itself. If you want that autocommand experiment to run, move it to `plugin/test.lua` (singular, which Neovim runs automatically at startup) or `require` it from `init.lua`.
- Useful lazy commands: `:Lazy` (dashboard), `:Lazy sync` (install/update/clean), `:Lazy restore` (go back to the versions in `lazy-lock.json`).
- Useful LSP commands: `:checkhealth vim.lsp` (which servers are attached), `:lsp restart` (restart the servers).
