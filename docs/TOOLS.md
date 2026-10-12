# Development tools

## Neovim

- Tested version: 0.12.5
- Plugin manager: lazy.nvim
- Plugin versions: `nvim/lazy-lock.json`

## C# language server

- Installer: Mason
- Package: `roslyn-language-server`
- Tested version: `5.12.0-1.26426.8`

## Requirements

- Fedora Linux
- .NET SDK 10
- Git
- ripgrep (`rg`)
- fd (`fd`)

The Neovim plugin lockfile pins plugin revisions.
Mason-installed language servers must be installed separately.

## Native C# debugger (verified October 2026)

- Neovim plugin: `mfussenegger/nvim-dap`
- Debug panels: `rcarriga/nvim-dap-ui` and dependency `nvim-neotest/nvim-nio` (restore via lazy.nvim and verify complete checkout)
- Adapter: Mason `netcoredbg`, tested version `3.1.3-1`; executable `~/.local/share/nvim/mason/bin/netcoredbg`
- F5 resolves the current project's Debug `TargetPath` via `dotnet msbuild`; requires a previously built application
- See [DEBUGGING.md](DEBUGGING.md) for commands, caveats, and acceptance tests.
