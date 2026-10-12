# Fedora Development Dotfiles

Personal development environment for **Fedora, Neovim, C#/.NET, tmux, and Claude Code**.

This repository contains the configuration and documentation needed to reproduce my development setup on another Fedora machine.

## Features

- **Neovim** — Neo-tree, Telescope, Treesitter, Roslyn language server, and blink.cmp completion.
- **C# debugging** — F5 launches the current .NET application using `nvim-dap`, `netcoredbg`, and MSBuild project metadata.
- **tmux** — Persistent terminal sessions with separate panes for Neovim, Claude Code, and builds.
- **Claude Code** — Runs as a separate CLI alongside Neovim.
- **Reproducibility** — Tracked configuration, plugin lockfile, recovery instructions, and troubleshooting guides.

## Documentation

All detailed documentation is in [`docs/`](docs/).

| Guide | Description |
|---|---|
| [Documentation index](docs/README.md) | Start here |
| [Manual](docs/MANUAL.md) | Installation, daily workflow, and disaster recovery |
| [Cheatsheet](docs/CHEATSHEET.md) | Keyboard shortcuts and commands |
| [C# Debugging](docs/DEBUGGING.md) | F5, breakpoints, MSBuild, and `netcoredbg` |
| [Configuration Reference](docs/CONFIG_REFERENCE.md) | Neovim and tmux configuration details |
| [Rebuild Prompt](docs/REBUILD_PROMPT.md) | Recreate the environment with AI assistance |
| [Tools](docs/TOOLS.md) | Software requirements and tested versions |

## Quick Start

```bash
# Clone the private repository after authenticating with GitHub
git clone https://github.com/AlzPatz/dotfiles.git ~/.config/dotfiles
```

Follow the [installation and recovery manual](docs/MANUAL.md) to install dependencies, safely create configuration symlinks, restore Neovim plugins, and install Roslyn and `netcoredbg`.

For everyday C# development:

```bash
cd /path/to/application-project
dotnet build -c Debug
nvim .
```

Open a `.cs` file, press **Ctrl+N** for the file explorer, and **F5** to start debugging.

## Repository Layout

```text
dotfiles/
├── README.md
├── docs/
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/config/
└── tmux.conf
```

**Important:** This repository does not contain credentials, project source repositories, installed SDKs, or personal data. Back those up separately.

The tracked configuration files are the source of truth. See the [manual](docs/MANUAL.md) before modifying or rebuilding the environment.
