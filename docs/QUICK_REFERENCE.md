# Fedora C# dev — quick reference

**Start in the solution directory** · Neovim leader = **Space** · tmux prefix = **Ctrl+b, release, then key** · Details: [MANUAL](MANUAL.md) · [Recovery](README.md)

| Start / tmux | Action | Neovim (normal mode) | Action |
|---|---|---|---|
| `cd path/to/solution` | Go to `.sln` / `.slnx` directory | `nvim .` | Open editor from solution root |
| `tmux new -s dev` | Start named session (outside tmux) | `i` / `Esc` | Insert / normal mode |
| `tmux ls` | List sessions | `:w` / `:q` / `:wq` | Save / quit / both |
| `tmux attach -t dev` | Reconnect | `:q!` | Quit, discard buffer edits |
| `Ctrl+b`, `%` or `|` | Split left/right | `Ctrl+n` | Toggle Neo-tree sidebar |
| `Ctrl+b`, `"` or `-` | Split top/bottom | `Space ff` / `Space fg` | Find files / grep project |
| `Ctrl+b`, arrows | Switch tmux panes | `Space fb` / `Space fh` | Buffers / help |
| `Ctrl+b`, `z` | Zoom / unzoom pane | `gd` / `gr` | Definition / references |
| `Ctrl+b`, `c` | New tmux window | `gi` / `gy` | Implementation / type |
| `Ctrl+b`, `n` / `p` | Next / previous window | `K` / `Ctrl+o` | Hover docs / jump back |
| `Ctrl+b`, `d` | Detach; leave tasks running | `[d` / `]d` / `Space e` | Prev/next diagnostic / details |
| `tmux kill-session -t dev` | End named session (save first) | `Ctrl+h/j/k/l` | Move **Neovim** windows |
| `tmux kill-server` | End **all** sessions (save first) | `:checktime` | Detect Claude's file edits |

| C# / build pane | Action | Claude / review / Git | Action |
|---|---|---|---|
| `dotnet --info` | Check SDK | `claude` | Start Claude in separate pane |
| `dotnet restore` | Restore dependencies | `git status --short` | List changed files |
| `dotnet build` | Build in solution/project directory | `git diff` | Review Claude/local changes |
| `dotnet test` | Test solution/project (if present) | `git add path/to/file` | Stage reviewed file only |
| `dotnet run --project path/App.csproj` | Run chosen app | `git commit -m "..."` | Record reviewed change |
| `dotnet watch --project path/App.csproj run` | Run with file watching | `git push` | Publish commit |
| `:Roslyn target` (in Neovim) | Choose C# project target | `git pull --ff-only` | Update clean checkout |
| `:Mason` / `:Lazy restore` | Server tools / locked plugins | `:checkhealth vim.lsp` | Diagnose Roslyn attachment |

**More Vim:** `/text` search · `n` / `N` next/previous · `u` undo · `Ctrl+r` redo · `yy` copy line · `dd` delete line · `p` paste · `:split` / `:vsplit` editor splits · `Ctrl+Space` completion, `Ctrl+y` accept (insert mode).

**Recommended 3-pane day:** tmux → `nvim .` → split `%`, `claude` → split `"` for `dotnet build` / `dotnet test`. Switch with `Ctrl+b` + arrows. **Save Neovim buffer before Claude edits; use `:checktime`, review `git diff`, then build/test.** tmux survives detach, **not reboot**.

**Restore config links:** `~/.config/nvim` → `~/.config/dotfiles/nvim`; `~/.config/tmux/tmux.conf` → `~/.config/dotfiles/tmux.conf`. Never commit secrets. This is a quick reference, not a guarantee of a single printed page with every font/printer.
