# Fedora development dotfiles

Personal, version-controlled development environment for Fedora, Neovim, C#/.NET, and tmux. Claude Code runs as a separate CLI, commonly in an adjacent tmux pane.

> **Private repository:** `https://github.com/AlzPatz/dotfiles.git`. These files are configuration, not credentials. Never commit tokens, SSH keys, or Claude authentication data.

## What's included

| Path | Purpose |
| --- | --- |
| `nvim/init.lua` | Neovim entry point |
| `nvim/lua/config/options.lua` | Editor preferences and diagnostic appearance |
| `nvim/lua/config/keymaps.lua` | Global Neovim keybindings |
| `nvim/lua/config/lazy.lua` | lazy.nvim bootstrap and plugin loader |
| `nvim/lua/config/plugins/navigation.lua` | Neo-tree and Telescope |
| `nvim/lua/config/plugins/editor.lua` | Treesitter parsers and highlighting |
| `nvim/lua/config/plugins/csharp.lua` | Mason and Roslyn |
| `nvim/lua/config/plugins/completion.lua` | blink.cmp completion |
| `nvim/lazy-lock.json` | Plugin version lockfile |
| `tmux.conf` | tmux mouse, splits, terminal, numbering, and reload key |
| `TOOLS.md` | Recorded tool versions |
| `MANUAL.md` | Complete recovery, setup, daily usage, and troubleshooting guide |
| `CONFIG_REFERENCE.md` | Full Neovim Lua/tmux source-level reconstruction and plugin verification |
| `CHEATSHEET.md` | One-page quick reference for Neovim, tmux, C#, Claude, and Git |
| `REBUILD_PROMPT.md` | AI-assisted rebuild handoff and safety checklist |

## Start here

- **New machine or total rebuild:** follow [MANUAL.md §2](MANUAL.md#2-disaster-recovery-rebuild-a-new-fedora-machine) in order, then run the acceptance test.
- **Daily work:** use [CHEATSHEET.md](CHEATSHEET.md).
- **Recreate plugins/config from source:** use [CONFIG_REFERENCE.md](CONFIG_REFERENCE.md) (fallback only; actual repository files take precedence).
- **Ask an AI assistant to help rebuild:** give it [REBUILD_PROMPT.md](REBUILD_PROMPT.md) and this repository.
- **Changing config:** edit tracked files, test, then commit and push; never commit credentials.

## Quick setup on a new Fedora machine

Read **[MANUAL.md](MANUAL.md)** before starting, especially if Neovim or tmux is already configured on the target machine.

1. Install prerequisites (package names/availability may differ by Fedora release):

   ```bash
   sudo dnf install -y git gh neovim tmux ripgrep fd-find curl unzip gcc make
   ```

   Install the .NET SDK separately if required; check `dotnet --info` and the project’s `global.json`. Install and authenticate Claude Code separately if you use it. See the manual for complete verification and recovery.

2. Authenticate to GitHub and clone the **private** repo:

   ```bash
   gh auth login
   gh auth setup-git
   mkdir -p ~/.config
   git clone https://github.com/AlzPatz/dotfiles.git ~/.config/dotfiles
   ```

3. Back up existing configuration first, if any. Then link the files:

   ```bash
   ln -s ~/.config/dotfiles/nvim ~/.config/nvim
   mkdir -p ~/.config/tmux
   ln -s ~/.config/dotfiles/tmux.conf ~/.config/tmux/tmux.conf
   ```

   **Important:** tmux's XDG configuration path is `~/.config/tmux/tmux.conf`, **not** `~/.config/tmux.conf`. Do not run the `ln` commands if those destinations already exist; see the safe backup instructions in the manual.

4. Start Neovim to bootstrap plugins:

   ```bash
   nvim
   ```

   Then use `:Lazy restore` to restore plugin versions from `nvim/lazy-lock.json`, and `:Mason` to install `roslyn-language-server` if it is missing. See the manual for version and compatibility notes.

5. Verify tmux:

   ```bash
   tmux new -s dev
   tmux show-option -g mouse
   tmux show-option -g base-index
   ```

   Expect `mouse on` and `base-index 1`.

## Daily workflow

From the directory containing your `.sln` file:

```bash
cd ~/Projects/code/yak/yak2d/src  # Example: change for your machine
tmux new -s yak2d
```

Run `nvim .` in one pane, press `Ctrl+b` then `%` to split left/right, and run `claude` in the other pane. Switch tmux panes with `Ctrl+b` then an arrow key. Detach with `Ctrl+b` then `d`; reattach with `tmux attach -t yak2d`.

### Neovim shortcut highlights

| Keys (normal mode) | Action |
| --- | --- |
| `Ctrl+n` | Toggle Neo-tree |
| `Space ff` | Find files |
| `Space fg` | Search text across files |
| `Space fb` | Find open buffers |
| `gd`, `gr`, `gi`, `gy` | Definition, references, implementation, type definition |
| `K` | Symbol documentation |
| `[d`, `]d`, `Space e` | Previous/next diagnostic; diagnostic details |
| `Ctrl+h/j/k/l` | Move between **Neovim** windows |

For a concise everyday command reference, see **[CHEATSHEET.md](CHEATSHEET.md)**. For full shortcuts, debugging, Claude Code safety, and machine recovery, see **[MANUAL.md](MANUAL.md)**.

## Sync changes

```bash
cd ~/.config/dotfiles
git status --short
git diff --check
git add README.md MANUAL.md CHEATSHEET.md REBUILD_PROMPT.md CONFIG_REFERENCE.md
git diff --cached --stat
git commit -m "Update development environment documentation"
git push
```

On another machine, pull updates only when local changes have been saved or committed:

```bash
git -C ~/.config/dotfiles pull --ff-only
```

## What is NOT backed up

This repository stores **configuration and documentation**, not Fedora itself, project source repositories, SSH/GitHub/Claude credentials, NuGet secrets, installed .NET SDKs, terminal preferences, or personal files. Keep separate backups and recovery methods. A successful dotfiles clone is **not** a complete system restore.

## Acceptance test

After setup, verify: `readlink -f ~/.config/nvim`, `readlink -f ~/.config/tmux/tmux.conf`, `nvim --version`, `dotnet --info`, `gh auth status`, `claude --version`, and `tmux show-option -g mouse` **inside a fresh tmux session**. Open a `.cs` file from a real solution; confirm Roslyn, `gd`, `gr`, completion, `Space ff`, and `Space fg`. Run `dotnet build` and `dotnet test` where supported. Full expected results and troubleshooting are in the manual.
