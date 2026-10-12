# Native C# debugging in Neovim — tested workflow

> Tested October 2026 on Fedora 44 / Neovim 0.12.5 / .NET SDK 10.0.112, using Mason `netcoredbg` 3.1.3-1 and `nvim-dap`. The game `sis-escape-run` launched successfully with F5. Keep the checked-in `nvim/lua/config/plugins/debug.lua` as the source of truth.

## The mental model

`dotnet run` builds and runs an app normally. `F5` starts or continues a **debugging session** using `netcoredbg`, allowing breakpoints, stepping, and variable inspection. F5 does **not** automatically build the code.

**F5 uses Neovim's working directory** (`:pwd`), not necessarily the directory of the current file or the shell in another tmux pane. The configured `program` callback executes:

```bash
dotnet msbuild -getProperty:OutputType -getProperty:TargetPath -property:Configuration=Debug
```

It reads JSON `Properties.OutputType` and `Properties.TargetPath`, accepts `Exe` or `WinExe`, and launches the existing Debug DLL returned by MSBuild. Unlike the earlier recursive `**/bin/Debug/**/*.dll` picker, this does not offer dependencies such as `Yak2D.Core.dll` or `Gas2d.dll`.

## Daily workflow (one runnable project)

In the **shell** (your build pane):

```bash
cd /path/to/application-project   # Directory containing the runnable .csproj
dotnet build -c Debug
```

In **Neovim** (Normal mode):

```vim
:pwd
:cd /path/to/application-project
:pwd
```

Open a `.cs` file using `Ctrl+n` (Neo-tree) or `:edit Program.cs`; toggle a breakpoint with `F9`; press `F5`. Use `F10` to step over, `F11` to step into, `Shift+F11` to step out if your terminal forwards it, and `Space dt` to terminate. `Space du` toggles the debug panels when DAP UI is installed. After changing code, rebuild in the shell before starting a fresh session.

**Tested example:**

```vim
:cd /home/alex/Projects/code/yak/sis-escape-run/src/sis-escape-run
:pwd
```

The corresponding Debug output was `bin/Debug/net10.0/sis-escape-run.dll`; F5 launched the game directly. The Yak2D/Gas2d DLLs are referenced dependencies, not alternative launch targets. Stepping into engine code additionally depends on source and symbols being available; that was not independently verified in this test.

## Key reference

| Keys / command | Action |
| --- | --- |
| `:pwd` | Show Neovim's current project directory |
| `:cd PATH` | Set directory used by the next F5 launch |
| `Ctrl+n` | Toggle Neo-tree |
| `F5` | Start / continue |
| `F9` or `Space db` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out; terminal may intercept |
| `Space dr` | Open DAP REPL |
| `Space dt` | Terminate debug session |
| `Space du` | Toggle DAP UI |

Breakpoints show `●`; the stopped execution line shows `➜` in the tested config.

## Dependencies and recovery

- `nvim-dap` is the Neovim debug adapter client.
- `netcoredbg` is the external debugger installed through Mason at `~/.local/share/nvim/mason/bin/netcoredbg`.
- `nvim-dap-ui` provides panels and depends on `nvim-nio`. The UI is separate from the project-selection logic.
- `lazy-lock.json` pins Neovim plugin revisions; **it does not pin Mason's netcoredbg executable**.

On a fresh machine, restore plugins with `:Lazy restore`, then inspect `:Mason` and install `netcoredbg` if needed. Verify the executable:

```bash
~/.local/share/nvim/mason/bin/netcoredbg --version
```

A plugin directory with only `.git` and no `lua/` files is an incomplete checkout. Inspect `:Lazy` and restore the missing plugins; don't rewrite `debug.lua` to work around a broken install.

## Troubleshooting

**F5 cannot identify the project:** run `:pwd` and `:cd` into the directory containing the runnable `.csproj`. The current approach assumes one unambiguous project in that directory; it does not automatically choose from a solution root.

**No Debug DLL:** in the same project directory, run `dotnet build -c Debug`. Verify MSBuild's reported path exists:

```bash
dotnet msbuild -getProperty:OutputType -getProperty:TargetPath -property:Configuration=Debug
```

**F5 doesn't pick up new edits:** it does not build automatically; rebuild first. Also save the buffer with `:w` before building.

**F5 opens terminal menus / keys don't reach Neovim:** check terminal keyboard accelerators (notably F10 in GNOME Terminal). `Shift+F11` support varies by terminal.

**Lua syntax error:** inspect the line reported and check syntax independently without loading plugins:

```bash
nvim --clean --headless -n \
  +"lua local f,err=loadfile(vim.fn.expand('~/.config/dotfiles/nvim/lua/config/plugins/debug.lua')); print(err or 'Lua syntax OK')" \
  +qa
```

Syntax validity does not guarantee that plugins are installed or that a DAP launch succeeds. Preserve a known-good copy before edits.

**Plugin not installed:** `:Lazy` / `:Lazy restore`; inspect `~/.local/share/nvim/lazy/nvim-dap-ui` and `nvim-nio` for actual plugin files. Avoid deleting active swap files or killing unrelated Neovim processes.

## Deliberate limits

The MSBuild query runs synchronously and may pause Neovim briefly. This setup intentionally does not handle automatic builds, launch profiles, command-line arguments, environment settings, multi-target framework selection, attaching to a running process, or selecting among multiple runnable projects. Use `dotnet run --project ...` for ordinary execution; use a project-specific terminal command or future explicit DAP configuration for exceptional launch requirements.

## Acceptance check

1. `dotnet build -c Debug` succeeds for a runnable project.
2. `dotnet msbuild` reports `OutputType: Exe` or `WinExe` and the expected `TargetPath`.
3. `:pwd` in Neovim points at that project directory.
4. A C# file is open; F9 sets a breakpoint.
5. F5 launches the application directly, without a dependency-DLL menu.
6. Breakpoints, stepping, and termination behave as expected; UI panels are checked separately.
