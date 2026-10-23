# Spell Check Quick Reference

Spell check is enabled in `after/ftplugin/markdown.lua` and `after/ftplugin/gitcommit.lua`
via `set.spell = true`. No custom mappings are defined, so these are Neovim's built-in keys.
All commands are used in Normal mode with the cursor on the word.

## Add a word or ignore a word

| Key | Action |
|---|---|
| **`zg`** | **Adds the word to your dictionary permanently** ("good word"). Saved to `~/.config/nvim/spell/en.utf-8.add`. |
| **`zG`** | **Ignores the word for this session only.** Cleared when you quit Neovim. |
| `zw` | Marks the word as wrong permanently ("wrong word"). |
| `zW` | Marks the word as wrong for this session only. |
| `zug` / `zuw` | Undoes a `zg` or `zw` (removes the word from the dictionary). |
| `zuG` / `zuW` | Undoes a `zG` or `zW`. |

Prefix with a count to choose which file to use when `spellfile` lists more than one, e.g. `2zg`.

## Navigation

| Key | Action |
|---|---|
| `]s` | Jumps to the next misspelled word. |
| `[s` | Jumps to the previous misspelled word. |
| `]S` / `[S` | Same as above, but only stops at "bad" words (skips rare/regional ones). |

## Fixing words

| Key | Action |
|---|---|
| `z=` | Shows a list of suggestions. Type the number and press Enter. |
| `1z=` | Replaces the word with the first suggestion without showing the list. |
| `:spellrepall` | Applies the same fix to every match of the word you just replaced with `z=`. |
| `Ctrl-x s` (Insert mode) | Shows completion suggestions for the bad word before the cursor. |

## Turning spell check on or off

- `:set spell!` toggles spell check.
- `:setlocal nospell` turns it off for the current buffer only.

## Options

- `set.spelllang = "en_us"` sets the language (add to the ftplugin).
- `set.spellfile = ...` sets a custom location for your word list.
