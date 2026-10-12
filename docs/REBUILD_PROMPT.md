# REBUILD_PROMPT.md — AI assistant handoff for Fedora development environment

> **Purpose:** Give this file, the private dotfiles repository, and the current machine's command output to ChatGPT or Claude when rebuilding from scratch or setting up another Fedora system. This is an **instruction document, not an executable script**. It contains no credentials.

## Copy/paste this prompt to the assistant

You are helping me restore my Fedora C#/.NET development environment. Work **one stage at a time**. Give me a small set of commands, say what output to expect, and **wait for my pasted verification results** before continuing. Do not assume you can see or control my machine. Do not claim commands succeeded without evidence.

My private GitHub dotfiles repo is `https://github.com/AlzPatz/dotfiles.git`, normally cloned to `~/.config/dotfiles` on branch `main`. The source of truth is the **current repo**, not remembered setup details. Read `docs/README.md`, `docs/MANUAL.md`, `docs/CHEATSHEET.md`, `docs/TOOLS.md`, `tmux.conf`, `nvim/init.lua`, `nvim/lua/config/`, `nvim/lua/config/plugins/`, and `nvim/lazy-lock.json`, and `docs/CONFIG_REFERENCE.md` before proposing changes if you have access; otherwise ask me to paste relevant content. Do not assume the historical configuration is unchanged.

### My intended end state

- Fedora GNOME, Bash; minimal Neovim IDE for C#/.NET solutions.
- Neovim settings in `~/.config/dotfiles/nvim`, symlinked as `~/.config/nvim`.
- tmux settings in `~/.config/dotfiles/tmux.conf`, symlinked as `~/.config/tmux/tmux.conf` (**not** `~/.config/tmux.conf`).
- Neovim plugins managed by lazy.nvim; plugin revisions restored from `nvim/lazy-lock.json`.
- Neo-tree (`Ctrl+n`), Telescope (`Space ff/fg/fb/fh`), Treesitter, Mason Roslyn LSP, blink.cmp completion, C# cross-project navigation and diagnostics.
- Native C# debugging via `nvim-dap` and Mason `netcoredbg`; F5 resolves `OutputType` and `TargetPath` using MSBuild in Neovim `:pwd`, requiring `dotnet build -c Debug` first. `nvim-dap-ui` uses `nvim-nio`; verify both plugin checkouts are complete.
- Claude Code runs as an independent CLI, preferably in a neighboring tmux pane; optional third pane for `dotnet` builds/tests.
- VS Code may remain GNOME's graphical default for C# files; GNOME Text Editor for `.txt`; this preference is **not enforced by the dotfiles**.
- Project source is cloned separately; no project `.editorconfig` edits just to support my editor.

### Safety rules

1. **Inspect first:** Fedora version, shell, installed commands, existing configs/symlinks, Git status, SDK/project requirements, and whether this is a new machine or a machine with existing work.
2. **No destructive shortcuts:** never overwrite `~/.config/nvim`, `~/.config/tmux/tmux.conf`, projects, or Git changes. Back up conflicting files with unique names after showing the commands and receiving approval. Do not run `rm -rf`, reset repositories, wipe credentials, or change system defaults without explicit authorization.
3. **Secrets stay private:** never ask me to paste passwords, tokens, SSH private keys, or Claude credentials. Use interactive `gh auth login` and official Claude sign-in. Never commit secrets.
4. **Credential helper:** after interactive `gh auth login`, use `gh auth setup-git` if HTTPS Git authentication is not configured; never embed tokens in URLs or commands.
5. **Verify versions:** the previous working laptop used Neovim 0.12.5, .NET SDK 10.0.112, ripgrep 15.2.0, fd 10.4.2, and Mason Roslyn `5.12.0-1.26426.8`. These are historical reference points, **not fixed installation commands**. Check `TOOLS.md`, current Fedora packages, project `global.json`, and official installation guidance.
6. **One stage at a time:** each stage must include prerequisites, exact commands, expected outputs, and how to recover if something differs. Wait for confirmation.
7. **Do not improvise config:** if the repository is unavailable, use `docs/CONFIG_REFERENCE.md` as a documented best-effort fallback, not as proof of exact original plugin revisions. Prefer restoring the repo unchanged and testing it before adding plugins, mappings, tmux integrations, automation, or new dependencies.
8. **Distinguish tool layers:** Neovim splits are not tmux panes; tmux sessions are not persistent across reboot; lazy.nvim lockfile does not pin Mason language-server binaries; dotfiles do not back up the whole system.

### Stages to guide me through

1. **Inventory and backups:** ask if this is fresh Fedora or an existing system; collect `cat /etc/fedora-release`, `uname -m`, `command -v git gh nvim tmux rg fd dotnet claude`, `ls -ld ~/.config/nvim ~/.config/tmux/tmux.conf ~/.config/dotfiles 2>/dev/null`, and relevant `git status` if a repo exists. Identify any files needing backup.
2. **Base packages:** install Fedora prerequisites (`git`, `gh`, `neovim`, `tmux`, `ripgrep`, `fd-find`, `curl`, `unzip`, `gcc`, `make` as available). Verify executable names; do not assume Fedora version/package naming is unchanged.
3. **SDK:** inspect project's `global.json`, `.sln`/`.slnx`, workloads and feeds; install appropriate .NET SDK using official instructions. Verify `dotnet --info` and `dotnet --list-sdks`.
4. **GitHub and clone:** guide interactive `gh auth login`, verify `gh auth status`, configure Git HTTPS with `gh auth setup-git` if needed, clone private repo to `~/.config/dotfiles` only if absent. If present, inspect status and remote first; do not overwrite.
5. **Safe links:** ensure `~/.config/nvim` and `~/.config/tmux/tmux.conf` resolve into the repo; back up conflicts rather than overwrite. Verify with `readlink -f`.
6. **Neovim plugins and Roslyn:** launch Neovim, use `:Lazy restore`, `:Mason` for `roslyn-language-server` if missing, `:checkhealth`, `:checkhealth vim.lsp`, and test with a real `.cs` file opened from solution root. Wait for indexing. Test `gd`, `gr`, Telescope and completion.
7. **Native debugger:** inspect tracked `nvim/lua/config/plugins/debug.lua` and lockfile; use `:Lazy restore` to restore `nvim-dap`, `nvim-dap-ui`, and `nvim-nio`; use `:Mason` to install `netcoredbg` if missing. Verify adapter version and project metadata. From a runnable project directory build Debug, check `:pwd`, then press F5 with a C# file open. Confirm breakpoint/step/terminate. Do not replace a working Lua config wholesale. See `docs/DEBUGGING.md`.
8. **Claude:** follow official installation and interactive login; verify `claude --version` and launch `claude`. Never paste authentication secrets into chat.
9. **tmux:** start a fresh named session, verify `mouse on` and `base-index 1`, split with `Ctrl+b` then `%`, run Neovim and Claude in separate panes, detach/reattach, and explain session termination.
10. **Projects:** clone/restore project repositories separately, run `dotnet restore`, `dotnet build`, and `dotnet test` from the appropriate root, investigate failures without attributing all project issues to the editor.
11. **Finish:** walk through the manual's acceptance checklist; record differences in `TOOLS.md` or docs only after verification, then review `git diff` and ask permission before committing/pushing changes.

### When we're done

Give me a concise summary of what was installed, the versions actually verified, symlinks and plugin state, Roslyn and .NET test results, outstanding issues, and exactly what is **not** covered by this backup. Point me to `docs/CHEATSHEET.md` for daily usage and `docs/MANUAL.md` for troubleshooting.

## For the human operator

Start a new chat, attach this file or paste the section above, and provide the repository link. If the assistant cannot access the private repository, authenticate with a trusted tool or paste the relevant files; **do not make the repository public**. Keep the conversation open while following one stage at a time. On an existing machine, **do not run fresh-install symlink commands blindly**.

**Do not treat these instructions as permission to install software or change files autonomously.** Ask before system-wide changes, overwrites, commits, pushes, or running commands with side effects.
