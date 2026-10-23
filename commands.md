# Most-used commands

Leader is `<space>`. Local leader is `\`.

## Custom keymaps (init.lua)

| Key | Mode | What it does |
|---|---|---|
| `<space><space>x` | n | Source current file (`:source %`) — reload a config file |
| `<space>x` | n | Run current line as Lua |
| `<space>x` | v | Run selected lines as Lua |
| `<Esc>` | n | Clear search highlight |

## Telescope (`<leader>f…`)

| Key | What it does |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (ripgrep) across project |
| `<leader>fb` | Switch between open buffers |
| `<leader>fh` | Search help tags |

Inside a picker: `<C-n>`/`<C-p>` move, `<CR>` open, `<C-x>` split, `<C-v>` vsplit, `<C-t>` tab, `<Esc>` close.

## LSP (built-in Neovim defaults, active for `lua_ls` and `jdtls`)

| Key | What it does |
|---|---|
| `K` | Hover docs |
| `grn` | Rename symbol |
| `gra` | Code action (n/v) |
| `grr` | List references |
| `gri` | Go to implementation |
| `gd` | Go to definition |
| `grt` | Go to type definition |
| `gO` | Document symbols |
| `<C-s>` (insert) | Signature help |
| `<C-x><C-o>` (insert) | Omni-completion via LSP |
| `[d` / `]d` | Previous / next diagnostic |
| `<C-w>d` | Show diagnostic under cursor in a float |
| `:LspInfo` | Show attached LSP clients |
| `:LspRestart` | Restart LSP for the buffer |

## Plugins / maintenance

| Command | What it does |
|---|---|
| `:Lazy` | Open lazy.nvim UI (`U` update, `S` sync, `X` clean, `q` quit) |
| `:Lazy sync` | Install/update/clean plugins to match spec |
| `:TSUpdate` | Update treesitter parsers (go, java, lua, python, rust) |
| `:TSInstall <lang>` | Install a new parser |
| `:checkhealth` | Diagnose setup problems |

## Handy defaults enabled by your options

- `:%s/foo/bar/` — live preview in a split (`inccommand = 'split'`)
- Yank/paste uses system clipboard (`clipboard = 'unnamedplus'`) — `y`/`p` work with other apps
- Searches are case-insensitive unless you type a capital (`ignorecase` + `smartcase`)
- `:q` on a modified buffer prompts to save instead of erroring (`confirm`)
- Yanked text flashes briefly (TextYankPost highlight)
- In git commit messages: spell-check is on (`z=` suggest, `]s` next misspelling), guide columns at 51/73
