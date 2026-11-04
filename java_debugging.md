# Debugging Java in Neovim

Uses **nvim-dap** (debugger client), **nvim-jdtls** (Java language server integration) and the **java-debug** extension that runs inside jdtls.
How they're wired together is covered in `config_overview.md`.

## Before you start

- **The project needs a `src` folder.** jdtls treats the folder above `src` as the project root. If a Java file isn't under a `src` folder, jdtls doesn't start and you can't debug it.
  ```
  myproject/
  └── src/
      └── Main.java
  ```
- **The java-debug jar must exist.** If you see `java-debug jar not found ... (debugging disabled)` when you open a Java file, install it:
  ```sh
  mkdir -p ~/.local/share/java-debug && curl -fLo ~/.local/share/java-debug/com.microsoft.java.debug.plugin-0.53.1.jar \
    https://repo1.maven.org/maven2/com/microsoft/java/com.microsoft.java.debug.plugin/0.53.1/com.microsoft.java.debug.plugin-0.53.1.jar
  ```
  Restart Neovim afterwards. jdtls only checks for the jar when it starts.
- **Give jdtls a few seconds after opening a file.** It has to import the project before debugging works. On a new project the first import can take a while.

## Quick start

1. Open a Java file that has a `main` method: `nvim src/Main.java`
2. Move to a line and press `<leader>db` (`<space>db`) to set a breakpoint. A `B` appears in the left column.
3. Press `<leader>dc` to start.
   - If the project has more than one `main` method, pick one from the list.
   - The program starts in a terminal split. Its `System.out` output shows up there, not in the REPL.
4. When it hits the breakpoint, the current line is highlighted (`→` in the left column). Now you can:
   - step with `<leader>do` / `<leader>di` / `<leader>dO`
   - inspect variables in the REPL (`<leader>dr`)
   - press `<leader>dc` to run to the next breakpoint
5. `<leader>dt` stops the program. Otherwise the session ends when `main` returns.

## Keymaps

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint on the current line |
| `<leader>dc` | Start debugging, or continue to the next breakpoint |
| `<leader>do` | Step **over**: run the current line, don't enter method calls |
| `<leader>di` | Step **into**: go inside the method called on this line |
| `<leader>dO` | Step **out**: run until the current method returns |
| `<leader>dr` | Open the debug REPL |
| `<leader>dt` | Stop (terminate) the program |

## Commands

These are available in any Java buffer.

| Command | Action |
|---|---|
| `:DapToggleBreakpoint` | Same as `<leader>db` |
| `:DapClearBreakpoints` | Remove every breakpoint |
| `:DapContinue` | Same as `<leader>dc` |
| `:DapStepOver` / `:DapStepInto` / `:DapStepOut` | Stepping |
| `:DapPause` | Pause a running program (e.g. one stuck in a loop) |
| `:DapTerminate` | Stop the program |
| `:DapToggleRepl` | Open/close the REPL |
| `:DapEval` | Evaluate the expression under the cursor (or the selection) |
| `:DapShowLog` | Open nvim-dap's log, useful when something isn't working |
| `:JdtUpdateHotcode` | Apply code changes to the running program without restarting (hot code replace). Save the file first. Works for changes inside method bodies, not for new methods or fields. |
| `:JdtUpdateDebugConfig` | Re-scan the project for `main` methods (after you add a new one) |
| `:JdtCompile` | Compile the project to check for build errors |

## Special breakpoints

There are no keymaps for these. Run them from the command line with the cursor on the line you want.

```vim
" conditional: only stops when the expression is true
:lua require('dap').set_breakpoint('i == 50')

" hit count: only stops on the 10th time the line runs
:lua require('dap').set_breakpoint(nil, '10')

" logpoint: prints a message instead of stopping ({} evaluates Java)
:lua require('dap').set_breakpoint(nil, nil, 'i is {i}')

" put all breakpoints in the quickfix list
:lua require('dap').list_breakpoints(true)

" run to the cursor line without setting a breakpoint
:lua require('dap').run_to_cursor()
```

## Using the REPL

Open it with `<leader>dr`, then go into insert mode in the REPL window.

- **Evaluate Java expressions** in the current stack frame. Type one and press Enter:
  ```
  x
  x * 2 + 1
  myList.size()
  name.toUpperCase()
  ```
- **REPL commands** (start with a `.`):

  | Command | Action |
  |---|---|
  | `.scopes` | List the variables in the current frame |
  | `.frames` | Show the call stack |
  | `.up` / `.down` | Move up/down the call stack (to inspect the caller's variables) |
  | `.threads` | List threads |
  | `.c` / `.n` / `.into` / `.out` | Continue / step over / step into / step out |
  | `.p` | Pause |
  | `.clear` | Clear the REPL |
  | `.exit` | Close the REPL |
  | `.help` | List all commands |

## Hover to inspect a variable

While stopped, put the cursor on a variable and run:

```vim
:lua require('dap.ui.widgets').hover()
```

A popup shows the value. For objects, press `<CR>` on a field to expand it. You can map this if you use it often, e.g. add this to the `keys` in `lua/plugins/dap.lua`:

```lua
{ '<leader>dh', function() require('dap.ui.widgets').hover() end, desc = 'DAP hover value' },
```

## Passing program arguments

`<leader>dc` launches with no arguments. To pass some, start the debugger yourself:

```vim
:lua require('dap').run({ type = 'java', request = 'launch', name = 'with args', mainClass = 'Main', args = 'one two three' })
```

Other launch options: `vmArgs = '-Xmx512m'`, `cwd = '/some/dir'`, `env = { KEY = 'value' }`.

## Debugging a program that's already running (attach)

1. Start the JVM with debugging turned on:
   ```sh
   java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -cp out Main
   ```
   With `suspend=y` the JVM waits for the debugger before running `main`.
2. In Neovim (with a Java file from the project open):
   ```vim
   :lua require('dap').run({ type = 'java', request = 'attach', name = 'attach', hostName = '127.0.0.1', port = 5005 })
   ```

## Troubleshooting

| Problem | Fix |
|---|---|
| `<leader>dc` says there are no configurations | jdtls isn't running for this file. Check that the file is under a `src` folder, then run `:checkhealth vim.lsp` and look for `jdtls`. |
| Warning: `java-debug jar not found` | Install the jar (see "Before you start") and restart Neovim. |
| Debugging stopped working after adding a new class with `main` | Run `:JdtUpdateDebugConfig`. |
| Breakpoint shows `R` (rejected) or the program never stops | The line has no runnable code (blank line, comment, a lone `}`). Move the breakpoint to a line with a statement. |
| jdtls seems confused (old errors, missing classes) | `:JdtRestart`. If that doesn't help, delete `~/.cache/nvim/jdtls/workspace/<project>` and reopen. |
| Still stuck | `:DapShowLog`, and `:lua vim.cmd.edit(vim.lsp.log.get_filename())` for the jdtls log. |
