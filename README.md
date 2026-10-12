# Fedora Neovim C# Development Setup

Personal Neovim configuration for C# development on Fedora, managed with Git.

## Requirements

- Fedora Linux
- Neovim 0.12.5 (tested)
- .NET SDK 10
- Git
- ripgrep (`rg`)
- fd (`fd`)

Install missing Fedora packages:

```bash
sudo dnf install neovim git ripgrep fd-find
```

Install .NET SDK 10 separately if not already available.

## Install configuration

Clone the dotfiles repository into:

```text
~/.config/dotfiles
```

If an existing Neovim configuration is present, back it up first.

Then create the symlink:

```bash
ln -s ~/.config/dotfiles/nvim ~/.config/nvim
```

Verify:

```bash
readlink -f ~/.config/nvim
```

Expected:

```text
/home/YOUR_USERNAME/.config/dotfiles/nvim
```

## Restore Neovim plugins

Start Neovim:

```bash
nvim
```

lazy.nvim will bootstrap itself and install the configured plugins.

Run:

```vim
:Lazy restore
```

This restores plugin versions from `nvim/lazy-lock.json`.

## Install Roslyn

Open Mason:

```vim
:Mason
```

Find `roslyn-language-server` and install it.

Tested version: `5.12.0-1.26426.8`.

The plugin lockfile does not pin the Roslyn server version. Check the installed version in Mason and install the tested version when available.

## C# workflow

Open Neovim from the directory containing your `.sln` or `.slnx` file:

```bash
cd /path/to/solution
nvim .
```

Roslyn loads when a C# file is opened.

### Keymaps

| Keys | Action |
|---|---|
| `Ctrl+n` | Toggle file explorer |
| `Space f f` | Find files |
| `Space f g` | Search project text |
| `Space f b` | Switch buffers |
| `Space f h` | Search Neovim help |
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Show documentation |
| `Ctrl+o` | Return to previous location |
| `[d` / `]d` | Previous / next diagnostic |
| `Space e` | Show diagnostic details |
| `Ctrl+h/j/k/l` | Move between editor windows |

### Completion

| Keys | Action |
|---|---|
| `Ctrl+Space` | Trigger completion |
| `Ctrl+n` / `Ctrl+p` | Navigate suggestions |
| `Ctrl+y` | Accept suggestion |
| `Ctrl+e` | Dismiss suggestions |

## Maintenance

- Edit configuration in `~/.config/dotfiles/nvim/`.
- Commit changes to Git.
- Pull changes on the other Fedora machine.
- Use `:Lazy restore` to restore pinned plugin versions.
- Update plugins intentionally, then commit the updated `lazy-lock.json`.

Mason packages, plugin binaries, caches, and machine-specific data are not committed.
