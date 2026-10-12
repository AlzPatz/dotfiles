# Fedora + Neovim + C# + tmux + Claude Code: Recovery and Daily Development Manual

**Purpose:** This is the rebuild-from-zero and day-to-day operating guide for the personal development environment stored in the private GitHub repository `https://github.com/AlzPatz/dotfiles.git`.

**Quick reference:** [CHEATSHEET.md](CHEATSHEET.md) contains the one-page command and shortcut guide. **Complete Lua and tmux configuration reference:** [CONFIG_REFERENCE.md](CONFIG_REFERENCE.md).

**Scope:** Fedora workstation/laptop, Neovim 0.12-era configuration, .NET C# solutions, Roslyn LSP, Treesitter, Neo-tree, Telescope, blink.cmp, tmux, Git, and the separate Claude Code CLI. It documents the configuration actually established, and identifies optional or unconfigured features clearly.

**Known working baseline (recorded during setup, not universal requirements):** Fedora 44; Neovim 0.12.5; .NET SDK 10.0.112; ripgrep 15.2.0; fd 10.4.2; Mason `roslyn-language-server` 5.12.0-1.26426.8. Installed versions will change over time. Consult `TOOLS.md` and `nvim/lazy-lock.json` in the repository for the tracked snapshot.

---

## At a glance

**First-time or disaster recovery:** §2 → §12 (acceptance test), then §15 (recovery checklist). **Understand components:** §3. **Neovim shortcuts:** §4. **tmux:** §5. **Claude collaboration:** §§6–7. **Git:** §8. **Broken setup:** §9. **Daily routine:** §10. **AI-assisted rebuild:** [REBUILD_PROMPT.md](REBUILD_PROMPT.md). **Fast lookup:** [CHEATSHEET.md](CHEATSHEET.md).

**Provenance:** The configuration and shortcuts described here reflect the tested laptop setup as of October 2026; version numbers are historical, not promises of future compatibility. Commands for new machines are procedures to verify, not evidence they were tested on every Fedora release.

**Recovery order:** Fedora + network → packages + SDK → private GitHub authentication → clone dotfiles → safely link configs → restore plugins + Roslyn → clone project repos → install/sign in Claude → test Neovim + tmux + .NET → commit nothing until verified.

**Two recovery levels:** With GitHub access, restore the *actual tracked* `nvim/` configuration and `lazy-lock.json` (preferred, reproducible). If the repo itself is lost, [CONFIG_REFERENCE.md](CONFIG_REFERENCE.md) provides a best-effort, source-level reconstruction of every Neovim configuration file and `tmux.conf`; the lockfile and external binaries cannot be reconstructed exactly from prose.

**What this repo cannot restore:** credentials, project repositories, personal files, GNOME settings, installed SDKs, NuGet feeds, and running tmux sessions. Maintain independent backups.

## 1. Mental model: what runs where

```text
Fedora GNOME desktop
  └── Terminal application (a GNOME Terminal/Ptyxis/etc. window)
       └── tmux server and named session (e.g. yak2d)
            ├── tmux pane 1: shell → Neovim
            │    ├── Neo-tree file sidebar
            │    ├── C# source buffer(s) and Neovim splits
            │    ├── Roslyn LSP (starts for C# buffers)
            │    ├── Telescope search UI
            │    └── blink.cmp completion
            ├── tmux pane 2: shell → Claude Code CLI
            └── optional pane 3: shell → dotnet build/test/git
```

**Terminal application window** is a GUI window provided by Fedora. **tmux window** is a tab-like workspace within a tmux session. **tmux pane** is a terminal region inside a tmux window. **Neovim window** is an editor split *inside* Neovim, not a tmux pane. **Neovim buffer** is an open file/content object; buffers can exist without a visible window. These distinctions matter when choosing keyboard shortcuts.

Claude Code is **not embedded in Neovim** in this configuration. It runs as a separate command-line program in its own shell, usually a tmux pane, and edits the same files on disk. Neovim handles language intelligence through Roslyn, not Claude.

---

## 2. Disaster recovery: rebuild a new Fedora machine

### Recovery safety gate (read before running commands)

**Do not erase an existing system merely to restore these dotfiles.** On an existing machine, inspect and preserve local Neovim/tmux configuration, project files, and uncommitted changes first. On a new machine, verify that the GitHub account can access the private repository before relying on it as your only recovery source. The commands below are examples to run **after** checking their preconditions, not a blind paste-all installer.

**Authentication caveat:** `gh auth login` does not necessarily configure Git's HTTPS credential helper on every installation. If `git clone https://...` still asks for credentials or fails, run `gh auth setup-git`, verify `gh auth status`, then retry. Never paste access tokens into the terminal command line or a chat.

### 2.1 Before wiping or replacing an old machine

1. Save and commit any unpushed dotfiles changes: `git -C ~/.config/dotfiles status --short`, then review, commit, and push.
2. Push your actual project repositories separately. **Dotfiles do not contain project source code.**
3. Back up data not in Git: documents, SSH private keys, credentials, secrets, local databases, untracked project files, and any app-specific settings. Use secure backup methods; **never** add credentials to dotfiles.
4. Confirm access to GitHub (including MFA/recovery codes), your password manager, and any Claude account/subscription you use.
5. Record hardware-specific packages, SDK requirements, and anything customized outside this repository. `TOOLS.md` records the baseline, not every system package.

### 2.2 Install Fedora and update

Install Fedora Workstation, log in, open a terminal, connect to the internet, and update:

```bash
sudo dnf upgrade --refresh
sudo reboot
```

After reboot, install general prerequisites:

```bash
sudo dnf install -y git gh neovim tmux ripgrep fd-find curl unzip gcc make
```

Package names and Fedora availability can change. If `dnf` reports a missing package, search with `dnf search NAME` or check Fedora's package listing instead of blindly substituting commands. `fd-find` is often invoked as `fd` on Fedora; verify using `command -v fd`.

Check tools:

```bash
git --version
gh --version
nvim --version | head -n 2
tmux -V
rg --version | head -n 1
fd --version
```

**Neovim compatibility:** This setup was tested with Neovim 0.12.5. An older distro version may not support the configured Treesitter or plugin APIs. If startup errors mention unsupported Neovim APIs, install a compatible Neovim version rather than randomly downgrading plugins.

### 2.3 Install .NET and verify C# tooling

Install a supported .NET SDK matching your projects. The previously tested machine used **SDK 10.0.112**; the SDK version is not guaranteed by this dotfiles repository. Follow Microsoft's current Fedora/.NET installation instructions if the required SDK is not available in your configured package repositories.

```bash
dotnet --info
dotnet --list-sdks
dotnet --list-runtimes
```

If your projects use `global.json`, its SDK selection can override your default. The repository's `TOOLS.md` records the historical version, but **does not install the SDK**. Some solutions need additional workloads or NuGet authentication.

### 2.4 Access your private GitHub repository

The repository is **private**, so an unauthenticated clone may fail.

```bash
gh auth login
gh auth status
gh auth setup-git
mkdir -p ~/.config
git clone https://github.com/AlzPatz/dotfiles.git ~/.config/dotfiles
```

Choose GitHub.com, HTTPS, and the browser login when prompted, unless your normal security setup uses SSH. Confirm:

```bash
git -C ~/.config/dotfiles remote -v
git -C ~/.config/dotfiles status --short
ls ~/.config/dotfiles/nvim/init.lua ~/.config/dotfiles/tmux.conf
```

If the directory already exists, **do not clone over it**. Inspect it first with `ls -la ~/.config/dotfiles` and `git -C ~/.config/dotfiles status`.

### 2.5 Safely link Neovim and tmux

The checked-in files live in `~/.config/dotfiles`. The applications use symlinks to those files. This makes edits visible in the Git working tree.

First inspect possible existing configuration:

```bash
ls -ld ~/.config/nvim ~/.config/tmux/tmux.conf ~/.config/tmux.conf 2>/dev/null || true
```

If `~/.config/nvim` or `~/.config/tmux/tmux.conf` exists and is **not** already the desired symlink, back it up with a unique name before proceeding. Example (adjust timestamp/name if necessary):

```bash
mv ~/.config/nvim ~/.config/nvim.backup-before-dotfiles
mv ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.backup-before-dotfiles
```

**Run only the `mv` lines for paths that actually exist**; never overwrite a prior backup. A dangling symlink also counts as an existing path for `ln -s`: check with `test -L PATH` if `ls` or `readlink -f` is confusing. If the existing path is already the correct symlink, leave it alone.

Create the links:

```bash
mkdir -p ~/.config/tmux
ln -s ~/.config/dotfiles/nvim ~/.config/nvim
ln -s ~/.config/dotfiles/tmux.conf ~/.config/tmux/tmux.conf
```

Verify:

```bash
readlink -f ~/.config/nvim
readlink -f ~/.config/tmux/tmux.conf
```

They should resolve to `/home/YOUR_USER/.config/dotfiles/nvim` and `/home/YOUR_USER/.config/dotfiles/tmux.conf`.

**Critical path detail:** The tmux XDG path is `~/.config/tmux/tmux.conf`. A file at `~/.config/tmux.conf` is **not** the same path and caused our original `mouse off` / `base-index 0` problem. The tmux configuration includes a reload shortcut that reads `~/.config/tmux/tmux.conf`.

### 2.6 Restore Neovim plugins and C# language server

Open Neovim:

```bash
nvim
```

`nvim/init.lua` loads settings, keymaps, and `lazy.nvim`. If lazy.nvim is absent, the bootstrap code clones it. The plugin specs are loaded from `nvim/lua/config/plugins/`. Internet access is required for initial installation.

Inside Neovim:

```vim
:Lazy
:Lazy restore
:checkhealth
:Mason
```

- `:Lazy` opens plugin management; `:Lazy restore` restores the locked plugin revisions from `nvim/lazy-lock.json` where available.
- `:Mason` manages external tools. Find and install `roslyn-language-server` if it is not installed. The prior working version was `5.12.0-1.26426.8`; Mason's current catalog may offer a different version. The Neovim lockfile **does not pin Mason-installed language-server binaries**.
- The Treesitter setup requests parsers for `c_sharp`, `lua`, `json`, `xml`, and `bash`; parser installation can take time. `:TSUpdate` is available if parsers need updating.
- `:checkhealth` helps identify missing dependencies.

**Do not assume everything is ready immediately after first launch.** Wait for plugin/parser installs, then restart Neovim and check a real solution.

### 2.7 Restore your projects and verify Roslyn

Clone your project repositories into the desired paths (they are separate from dotfiles), then open Neovim from the **solution directory**:

```bash
cd ~/Projects/code/yak/yak2d/src  # Existing example; adapt on a new machine
ls *.sln *.slnx 2>/dev/null
nvim .
```

Open a `.cs` file. Verify:

1. `:set filetype?` should report `cs`.
2. `:LspInfo` or `:checkhealth vim.lsp` should show Roslyn attached to the C# buffer. The working setup used `~/.local/share/nvim/mason/bin/roslyn-language-server`.
3. `gd` on a known C# symbol should navigate to its definition, including across projects when solution loading has finished.
4. `gr` should search references through Telescope.
5. Introduce a harmless temporary diagnostic and confirm the sign/underline; remove it afterward.
6. `:Roslyn target` is the available command to choose a target when necessary. **`:Roslyn info` is not a valid command** in the tested setup.

Roslyn can take time to load/index a large multi-project solution. If diagnostics are initially absent, give it time before assuming the settings are broken.

### 2.8 Install and authenticate Claude Code separately

Claude Code is a separate application and **is not installed by the dotfiles repo**. Install it using the current official Anthropic instructions for your operating system; avoid unverified installation scripts. Then:

```bash
command -v claude
claude --version
claude
```

Follow its sign-in prompts. The prior machine had `claude` under `~/.local/bin/claude`; that is not a required universal path. If a newly installed command is not found, check your shell `PATH` and the installer's instructions.

### 2.9 Validate tmux from a clean start

```bash
tmux new -s dev
```

Inside the session:

```bash
tmux show-option -g mouse
tmux show-option -g base-index
tmux show-option -g default-terminal
```

Expected values: `mouse on`, `base-index 1`, `default-terminal tmux-256color`.

Test `Ctrl+b` then `%` for a left/right split; `Ctrl+b` then `|` is the configured additional split shortcut. Test `Ctrl+b` then `d` to detach, followed by `tmux attach -t dev` to reconnect. End a disposable test session with `tmux kill-session -t dev` **only after saving work**.

### 2.10 Desktop-specific checks

- GNOME desktop defaults are **not** tracked in this repository. On the previous machine, VS Code was the default for C# files while GNOME Text Editor handled `.txt`. Recheck defaults on every machine; do not assume the dotfiles enforce them.
- Install VS Code independently if wanted. Check `xdg-mime query default text/x-csharp` and `xdg-mime query default text/plain`; desktop file identifiers vary by installation.
- Git identity and authentication may need setting per machine: `git config --global user.name`, `git config --global user.email`, `gh auth status`.
- Fonts, terminal emulator, GNOME extensions, SSH agents, SDK workloads, and project secrets are outside this repository unless added later.

---

## 3. The Neovim configuration: component-by-component

**Need exact setup code, not just explanations?** Read [CONFIG_REFERENCE.md](CONFIG_REFERENCE.md), which includes `init.lua`, options, keymaps, lazy.nvim bootstrap, Neo-tree/Telescope, Treesitter, Mason/Roslyn, blink.cmp, and tmux. The tracked repository files remain authoritative; the reference explicitly flags reconstructed portions.

### 3.1 Entry point and options

`nvim/init.lua` sets the global and local leader to **Space**, then loads `config.options`, `config.keymaps`, and `config.lazy`.

`config/options.lua` enables line numbers and relative numbers; 4-space indentation (`expandtab`, `shiftwidth=4`, `tabstop=4`, `smartindent`); mouse support; system clipboard via `unnamedplus`; persistent undo; case-smart searches; visible sign column; scrolling margin; right/below splits; true-color rendering; external file autoread; and a shorter key sequence timeout. The global diagnostic display uses signs, underlines, severity-sorted diagnostics, and inline virtual text for warnings/errors (not all hints/info).

**Important:** `autoread` alone is **not a guarantee of instantaneous refresh** after Claude edits files. See §7.3 for a safe reload routine.

### 3.2 lazy.nvim and version locking

`config/lazy.lua` bootstraps the plugin manager and loads everything in `config.plugins`. `nvim/lazy-lock.json` records specific Git revisions for the plugin dependencies. Use `:Lazy restore` to reproduce them, `:Lazy` to inspect, and commit the lockfile when deliberately updating plugins. The manager bootstrap and external Mason tools are separate from plugin locking; complete binary reproducibility is not yet automated.

### 3.3 Neo-tree: file sidebar

`navigation.lua` configures `neo-tree.nvim` on the left, width approximately 32 columns, with dotfiles and gitignored files visible. `Ctrl+n` toggles it. Use normal navigation keys or arrows to select a file, `Enter` to open it, and `?` inside Neo-tree to inspect the plugin's current context-sensitive mappings. Because Neo-tree has many built-in mappings, rely on its `?` help rather than assuming every default remains fixed across versions.

### 3.4 Telescope: find and search

`navigation.lua` also configures Telescope with:

- `Space ff` — fuzzy-find files.
- `Space fg` — live grep across project files (requires `rg`).
- `Space fb` — find open buffers.
- `Space fh` — search Neovim help.

Type to filter results, use the prompt's displayed mappings to navigate, press `Enter` to select, and `Esc` to close. `gr` opens Telescope's LSP references list. The search scope is influenced by Neovim's current working directory; starting in the solution root is useful.

### 3.5 Treesitter: code highlighting

`editor.lua` installs parsers for C#, Lua, JSON, XML, and Bash. It starts Treesitter highlighting on relevant filetypes and falls back to ordinary syntax highlighting if Treesitter cannot start. The C# parser name is `c_sharp`, while Neovim's C# filetype is `cs`. Treesitter understands syntax structure; it is **not** a C# compiler or semantic language server.

### 3.6 Mason and Roslyn: C# intelligence

`csharp.lua` configures Mason for installing language-server tools and `seblyng/roslyn.nvim` for C# buffers (`ft = "cs"`) with automatic file watching. Roslyn provides symbol navigation, references, diagnostics, and other LSP capabilities. For best solution-wide results, open from the directory containing the `.sln` or `.slnx` and allow project loading to complete. Some features depend on solution/project restore and Roslyn's state.

Use `:Mason` to inspect installed tools; use `:checkhealth vim.lsp` to diagnose attachment and root detection. `:Roslyn target` can help when there are multiple targets. Do not confuse LSP diagnostics with `dotnet build`: the build remains the authoritative compilation check.

### 3.7 blink.cmp: completion

`completion.lua` configures `blink.cmp` with LSP, filesystem paths, snippets, and current-buffer text as completion sources, using its default keymap preset. In insert mode, `Ctrl+Space` can open completion; `Ctrl+n` / `Ctrl+p` navigate choices; `Ctrl+y` accepts; `Ctrl+e` dismisses. Context and terminal key handling can affect these combinations; use `:Lazy` to check plugin status if completion disappears. Documentation popup is configured to appear automatically after a short delay.

---

### 3.8 Native C# debugging (tested October 2026)

The working debugger uses `mfussenegger/nvim-dap`, Mason-installed `netcoredbg`, and (when installed correctly) `rcarriga/nvim-dap-ui` with `nvim-neotest/nvim-nio`. The tested F5 launch **does not scan DLLs**. Instead it runs `dotnet msbuild -getProperty:OutputType -getProperty:TargetPath -property:Configuration=Debug` in Neovim's current directory (`:pwd`), checks for `Exe`/`WinExe`, checks that the returned DLL exists, and launches it through `netcoredbg`. It does not rebuild automatically. See [DEBUGGING.md](DEBUGGING.md) for the full workflow, implementation notes, and troubleshooting.

For the tested game: `:cd /home/alex/Projects/code/yak/sis-escape-run/src/sis-escape-run` in Neovim, `dotnet build -c Debug` in the shell, and `F5` from a C# buffer launched `sis-escape-run.dll`, not the dozens of copied dependency DLLs. `F9` sets a breakpoint; `F10` steps over, `F11` steps in, `Shift+F11` steps out (subject to terminal support); `Space dt` terminates; `Space du` toggles DAP UI when installed. `F5` continues when paused.

**Directory distinction:** Starting Neovim from a solution root helps Roslyn see the solution, but the current F5 resolver requires `:pwd` to point to the **application project directory** containing one unambiguous `.csproj`. `:cd` changes Neovim's directory; it does not change the shell in an existing tmux pane. Opening a source file alone does not change `:pwd`.

**Known limitation:** The project metadata query is synchronous and may briefly block the UI. It assumes a single project in `:pwd` and a conventional runnable .NET assembly; it does not handle launch profiles, automatic builds, multi-target selection, arguments, or special application startup. This is intentionally simpler than a full IDE launch-profile manager.

## 4. Neovim daily keyboard reference

**Notation:** `Space ff` means press Space, then `f`, then `f` in **normal mode**. `Ctrl+b`, `%` means hold Ctrl and press b, release, then press `%`. `Esc` returns from insert mode to normal mode.

### 4.1 Custom configured mappings

| Keys | Mode | Result |
| --- | --- | --- |
| `Ctrl+n` | Normal | Toggle Neo-tree |
| `F5` | Normal, C# | Start/continue debugging the project in `:pwd` |
| `F9` | Normal | Toggle breakpoint |
| `F10` / `F11` / `Shift+F11` | Normal | Step over / into / out (terminal dependent) |
| `Space db` / `Space dt` / `Space du` | Normal | Breakpoint / terminate / toggle DAP UI |
| `Space ff` | Normal | Telescope: find files |
| `Space fg` | Normal | Telescope: live grep |
| `Space fb` | Normal | Telescope: buffers |
| `Space fh` | Normal | Telescope: help tags |
| `gd` | Normal | Go to definition |
| `gr` | Normal | Find LSP references with Telescope |
| `gi` | Normal | Go to implementation |
| `gy` | Normal | Go to type definition |
| `K` | Normal | Hover documentation |
| `[d` | Normal | Previous diagnostic, with float |
| `]d` | Normal | Next diagnostic, with float |
| `Space e` | Normal | Show diagnostic at cursor |
| `Ctrl+h/j/k/l` | Normal | Move to Neovim split left/down/up/right |
| `Esc` | Normal | Clear search highlighting |

### 4.2 Essential built-in Vim/Neovim controls

| Keys/command | Result |
| --- | --- |
| `i` / `a` / `o` | Insert before cursor / after cursor / on new line |
| `Esc` | Back to normal mode |
| `:w` / `:q` / `:wq` | Save / quit / save and quit |
| `:q!` | Quit without saving current changes (destructive) |
| `u` / `Ctrl+r` | Undo / redo |
| `yy` / `dd` / `p` | Copy line / delete line / paste |
| `v` / `V` | Characterwise / linewise visual selection |
| `/text` then `Enter` | Search forward; `n` / `N` next/previous match |
| `gg` / `G` | Start / end of file |
| `0` / `$` | Start / end of line |
| `w` / `b` | Next / previous word |
| `Ctrl+o` / `Ctrl+i` | Back / forward in jump list |
| `:split` / `:vsplit` | Horizontal / vertical Neovim split |
| `:edit PATH` | Open file |
| `:buffers` / `:bnext` / `:bprevious` | Inspect and cycle buffers |
| `:pwd` / `:cd PATH` | Show / change Neovim working directory |
| `:terminal` | Open a terminal **inside Neovim** (optional; not the standard Claude workflow) |
| `Ctrl+\` then `Ctrl+n` | Leave Neovim terminal-input mode |
| `:checktime` | Check whether disk files changed externally |
| `:checkhealth` | Neovim health checks |

**Unsaved changes:** Neovim may refuse to quit or reload when a buffer is modified. Save or deliberately discard changes; do not force a reload over edits you care about.

### 4.3 Completion keys (insert mode)

| Keys | Action |
| --- | --- |
| `Ctrl+Space` | Request/show completion |
| `Ctrl+n` / `Ctrl+p` | Next / previous completion item |
| `Ctrl+y` | Accept completion |
| `Ctrl+e` | Close completion |

These are the intended blink.cmp default-preset behaviors in this setup. Actual handling can depend on whether a menu is visible and the terminal's key encoding.

---

## 5. tmux: sessions, windows, panes, and keys

### 5.1 Why tmux

A tmux session survives closing/detaching from the terminal window **as long as the tmux server and host remain running**. It does **not** survive a reboot by itself, and it is not a backup system. It allows Neovim, Claude, and build/test shells to run side by side without embedding one tool inside another.

### 5.2 Create and reconnect

```bash
cd ~/Projects/code/yak/yak2d/src
tmux new -s yak2d           # New named session (run from a normal shell)
tmux ls                     # List sessions
tmux attach -t yak2d        # Reconnect to detached session
```

If `yak2d` already exists, use `tmux attach -t yak2d` instead of creating a duplicate. From inside tmux, use `Ctrl+b` then `d` to detach.

### 5.3 tmux key reference

The tmux prefix is **Ctrl+b**. Press prefix, release, then press the command key.

| Keys | Result |
| --- | --- |
| `Ctrl+b`, `%` | Split left/right (tmux built-in) |
| `Ctrl+b`, `"` | Split top/bottom (tmux built-in) |
| `Ctrl+b`, `\|` | Split left/right (configured; new pane inherits current directory) |
| `Ctrl+b`, `-` | Split top/bottom (configured; inherits current directory) |
| `Ctrl+b`, arrow | Move between tmux panes |
| `Ctrl+b`, `o` | Cycle panes |
| `Ctrl+b`, `z` | Zoom/unzoom current pane |
| `Ctrl+b`, `c` | Create a new tmux window in current directory |
| `Ctrl+b`, `n` / `p` | Next / previous tmux window |
| `Ctrl+b`, `1`, `2`, ... | Select numbered tmux window |
| `Ctrl+b`, `d` | Detach session |
| `Ctrl+b`, `r` | Reload `~/.config/tmux/tmux.conf` |
| `Ctrl+b`, `[` | Enter tmux copy/scroll mode; `q` exits |
| `Ctrl+b`, `x` | Kill active pane (asks for confirmation) |
| `Ctrl+b`, `?` | Display tmux's complete keybinding list |

**Terminal caveat:** `%` normally requires Shift+5, and `|` may require Shift+backslash. The original test showed `%` worked before the configuration was correctly linked. If a custom binding fails, check that `mouse on` and `base-index 1` are active.

### 5.4 Kill versus detach

| Command/action | Effect |
| --- | --- |
| `Ctrl+b`, `d` | Leave session running |
| `tmux kill-session -t yak2d` | End only `yak2d` and all its processes |
| `tmux kill-server` | End **all** sessions and their processes |
| `tmux ls` | List sessions, or report no server |

**Before killing a session:** Save Neovim buffers, finish/stop builds, and ensure Claude is not in the middle of writing files. Killing the server is not equivalent to detaching.

### 5.5 Config specifics

`tmux.conf` enables mouse support, 1-based window/pane numbering, window renumbering, 20,000 lines of scrollback, `tmux-256color`, RGB support for `xterm-256color`, low escape delay for Neovim, an active-pane border, directory-preserving extra splits, and a reload shortcut. Verify:

```bash
tmux show-option -g mouse
tmux show-option -g base-index
tmux show-option -g default-terminal
readlink -f ~/.config/tmux/tmux.conf
```

To reload without restarting a running session:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

---

## 6. Three ways to run Neovim and Claude

### A. Recommended: Neovim + Claude in separate tmux panes

```bash
cd /path/to/solution-directory
tmux new -s projectname
nvim .
```

While Neovim is visible, press `Ctrl+b`, then `%` to create a second pane. In the new pane:

```bash
claude
```

Use `Ctrl+b`, left/right arrow to move between them. The shell in the Claude pane inherits tmux's pane working directory (the built-in `%` split usually uses the session's default/current context; the configured `|` binding explicitly inherits the active pane's current directory). Check `pwd` in the Claude pane before giving it project instructions.

Add a third pane for `dotnet build`, `dotnet test`, or Git. Use `Ctrl+b`, `z` to focus temporarily on one pane. This is the most practical and resilient setup.

### B. Separate terminal application windows

Open one Fedora terminal window with `nvim .` and another with `claude`. This is simple and requires no tmux. Window switching is managed by GNOME, and closing a window usually terminates its running process. Use this when you prefer GUI window management.

### C. Neovim's own `:terminal` split

Inside Neovim, `:vsplit` then `:terminal`, and run `claude` in the terminal buffer. This can work, but mixes editor-window navigation with terminal-input mode and is **not configured as the default workflow**. To return from terminal-input mode to Neovim normal mode, press `Ctrl+\` then `Ctrl+n`. The `Ctrl+h/j/k/l` mappings were defined for normal mode; don't assume they work directly while the terminal is capturing keystrokes. tmux is easier to operate and recover.

**Other terminal terms:** A shell (bash) is the command interpreter inside each pane; the GNOME terminal app is the graphical terminal emulator; tmux is a terminal multiplexer; Neovim's `:terminal` is an embedded terminal buffer. None of these is the same thing as Roslyn or Claude.

---

## 7. Safe Claude Code + Neovim collaboration

### 7.1 Typical session

1. Open the project root in tmux and start Neovim.
2. Use `Space ff` to open a file, `gd`/`gr` to explore the code, and `Space fg` to search text.
3. Switch to Claude's pane, explain the task, and ask it to inspect or change files. Check its proposed actions before approving tool operations.
4. Return to Neovim and inspect changed files and Roslyn diagnostics.
5. Run `dotnet build` and `dotnet test` as appropriate; use Git diff to review all changes.
6. Commit only the intended source changes to the **project repository**, not the dotfiles repository.

### 7.2 Keep one writer at a time

The safest rule: **avoid editing the same file simultaneously in Neovim and Claude Code**. Save Neovim changes before Claude modifies that file. After Claude edits, refresh/reopen the file in Neovim and review the diff. Use `git diff` and `git status` in the project directory to catch unexpected changes.

### 7.3 External file reloads: what is actually configured

`vim.opt.autoread = true` is configured. That allows Neovim to reload externally modified files **when it checks their timestamps**, provided it is safe to do so. There is **not yet** a custom `FocusGained`/`BufEnter`/`CursorHold` `:checktime` autocmd in the committed setup, so don't expect immediate automatic refresh in every situation.

After Claude modifies a file:

```vim
:checktime
```

If the file looks stale, switch away and back or reopen it; `:edit` can reload an unmodified buffer. **Never use `:edit!` unless you intend to discard unsaved Neovim changes.** If you have unsaved changes and Claude also edited the file, preserve a copy and compare versions rather than forcing a reload.

**External-edit verification:** Open a tracked file in Neovim with no unsaved changes. From the Claude/build pane, make a small reversible edit (or have Claude do so), then run `:checktime` in Neovim. Confirm the new contents appear, inspect `git diff`, and undo the test edit safely. Do not perform this test on an uncommitted or sensitive file.

### 7.4 Validation commands for .NET solutions

Run from the appropriate project/solution directory:

```bash
dotnet restore
dotnet build
dotnet test
```

On a large solution, select a particular `.sln` or `.csproj` if needed. Compilation and tests catch issues that Roslyn diagnostics or AI-generated edits may miss. Some repositories require extra workloads, secrets, platform-specific tooling, or external services.

### 7.5 Claude session continuity and caution

Claude's own conversation/session management is separate from tmux. Detaching tmux leaves the running Claude process alive; killing tmux terminates it. Don't assume an interrupted Claude operation is safe to resume without inspecting the filesystem and Git diff. Never paste secrets into prompts or allow broad destructive operations without checking scope.

---

## 8. Git: dotfiles versus project code

There are at least two different Git repositories in normal use:

1. `~/.config/dotfiles`: Neovim, tmux, documentation, lockfile.
2. `/path/to/your/project`: application source code, tests, solution files.

Always check which repository you are in:

```bash
pwd
git rev-parse --show-toplevel
git status --short
```

### Update dotfiles on the main machine

```bash
cd ~/.config/dotfiles
git diff
git status --short
git add docs/ tmux.conf nvim
git commit -m "Document development setup and recovery"
git push
```

Only commit changes you actually intend to share. `git add -A` is convenient but risks adding unrelated files; review `git status` first.

### Sync on another machine

```bash
cd ~/.config/dotfiles
git status --short
git pull --ff-only
```

If you have local modifications, commit/stash/back them up before pulling. After plugin spec or lockfile changes, open Neovim and run `:Lazy restore`; after tmux changes, reload the config or start a new tmux session. Git syncing does **not** install missing OS packages, .NET SDKs, or Mason language-server binaries.

### Updating plugins deliberately

Inspect changes using `:Lazy`, update only when intended, test C# navigation/completion/Treesitter, and commit the updated `nvim/lazy-lock.json`. Do not treat a lockfile update as an automatic Roslyn binary upgrade. Keep the older working state recoverable through Git history.

---

## 9. Troubleshooting decision tree

### tmux opens, but mouse is off / window numbers start at zero

Likely wrong config path. Verify `readlink -f ~/.config/tmux/tmux.conf` and run `tmux source-file ~/.config/tmux/tmux.conf`; check `tmux show-option -g mouse` and `base-index`. Do not use `~/.config/tmux.conf` as the expected XDG path.

### `tmux new -s NAME` says duplicate session

Use `tmux attach -t NAME`, or choose a different session name. `tmux ls` lists sessions.

### tmux is gone after a reboot

Expected: tmux is not persistent across machine reboot without additional session restoration tooling, which has not been configured. Restart `tmux new -s NAME` and your applications.

### F5 launches wrong DLL or does not launch

Check `:pwd`: it must be the application project directory, not the solution root or a library. From that directory run `dotnet msbuild -getProperty:OutputType -getProperty:TargetPath -property:Configuration=Debug`; confirm `OutputType` is `Exe`/`WinExe`, build with `dotnet build -c Debug`, and check that `TargetPath` exists. If the DAP UI plugin reports missing, inspect `:Lazy` and restore plugins using the tracked lockfile; an empty directory containing only `.git` is not a complete plugin checkout. Do not delete Neovim swap files to solve Lua syntax errors. See [DEBUGGING.md](DEBUGGING.md).

### Neovim starts with plugin errors

Check `nvim --version`, `:Lazy`, `:checkhealth`, network access, and lockfile compatibility. On a fresh machine, allow first-run installation to finish. The recorded Neovim version was 0.12.5.

### C# highlighting missing

Confirm `:set filetype?` returns `cs`. Check `:checkhealth nvim-treesitter` where supported, parser installation, and `:TSUpdate`. Syntax highlighting is independent of Roslyn attachment.

### `gd` or `gr` does nothing / diagnostics are missing

Open a real `.cs` file from the solution directory. Check `:checkhealth vim.lsp` and `:Mason`; ensure `roslyn-language-server` is installed and the SDK/project restores successfully. Give Roslyn time to index. Try `:Roslyn target` if target selection is relevant. `:Roslyn info` is not a supported command here.

### Inline diagnostics appear late

The configured virtual text shows **warnings/errors**, not all hints/info. Roslyn indexing and diagnostic publishing may be delayed. Use `Space e` or `]d` to inspect individual diagnostics. The configured underlines and signs are also severity dependent.

### Telescope live grep returns nothing

Check `rg --version`, the current directory via `:pwd`, and whether the text exists under that search root. Gitignore behavior and hidden-file defaults may affect results.

### Clipboard paste/copy not working

The `unnamedplus` option uses the system clipboard, but clipboard providers and the desktop session must support it. Run `:checkhealth` and test within GNOME; remote/SSH sessions may behave differently.

### Claude edited a file, but Neovim still shows old text

Save any local changes first, then `:checktime`. Compare `git diff` before forcing any reload. No custom periodic file-check autocmd is configured yet.

### tmux keybindings conflict with Neovim

`Ctrl+b` commands go to tmux; `Ctrl+h/j/k/l` operate inside Neovim normal mode. `Ctrl+b` then arrows crosses tmux panes. If the key doesn't work, verify which program currently has focus and whether you're in Neovim insert/terminal mode.

### Project doesn't build after restoring the editor

Dotfiles are only the editor/multiplexer configuration. Check `dotnet --info`, `global.json`, NuGet sources, workloads, secrets, environment variables, and external dependencies. The editor cannot reconstruct a missing SDK or project repository.

---

## 10. A practical day from start to finish

**Morning**

```bash
cd ~/Projects/code/yak/yak2d/src
tmux attach -t yak2d  # if it exists; otherwise: tmux new -s yak2d
```

Open `nvim .` in the first pane. Split with `Ctrl+b`, `%`; run `claude` in the second pane. Optionally split again for a build shell.

**While coding:** `Space ff` for files, `Space fg` for text, `gd` to follow a symbol, `Ctrl+o` to return, `gr` to inspect references, `K` for hover, `[d` / `]d` for diagnostics. Use `Ctrl+b`, arrow to ask Claude for help; return to Neovim to inspect and edit. Use `:checktime` after external file changes.

**Before committing:** Save (`:w`), run build/tests, inspect `git status` and `git diff`, and stage only intended project files. Keep dotfiles commits separate from source commits.

**Break:** `Ctrl+b`, `d` detaches without terminating your session.

**End of day:** Save all files and commit/push work. If you want processes to stop, exit Neovim/Claude and terminate the tmux session; otherwise detach. **A detached session is not a substitute for saving or backing up work.**

---

## 11. Quick command lookup

Keep **[CHEATSHEET.md](CHEATSHEET.md)** beside this manual. It summarizes how to start a project, create tmux panes, navigate Neovim, run Claude Code, build/test C#, inspect Git changes, and close or reattach sessions. For first-time setup, use the complete recovery steps in section 2 rather than the abbreviated cheat sheet.

**Practical reminder:** tmux's `Ctrl+b` prefix applies to tmux panes and windows; Neovim's `Ctrl+h/j/k/l` applies only to Neovim splits. `dotnet build` and `dotnet test` run in a shell, not as built-in Neovim shortcuts.

---

## 12. Verified acceptance test: from zero to productive

Perform these **after** following §2. Stop and fix a failing stage before continuing; do not assume a command succeeding means the whole system works.

| Stage | Run or perform | Pass condition | If not |
| --- | --- | --- | --- |
| Repository | `git -C ~/.config/dotfiles status --short` | Repo exists; no unexpected changes | Verify private GitHub access and clone path |
| Links | `readlink -f ~/.config/nvim`; `readlink -f ~/.config/tmux/tmux.conf` | Both point into `~/.config/dotfiles` | Revisit §2.5; back up conflicts |
| Tools | `command -v nvim tmux rg fd git gh dotnet claude` | Every required executable resolves (Fedora may expose `fdfind` instead of `fd`) | Install missing tool; check `PATH` |
| .NET | `dotnet --info` | SDK installed and compatible with project `global.json` | Install correct SDK/workload |
| GitHub | `gh auth status` | Authorized for private repo | Reauthenticate securely |
| Plugins | `nvim` → `:Lazy restore` | Plugins installed; no startup error | Check network, `:Lazy`, `:checkhealth` |
| tmux | Start **fresh** `tmux new -s verify`; run `tmux show-option -g mouse` | `mouse on`; `base-index 1` | Confirm XDG symlink; reload/restart tmux |
| Split | `Ctrl+b`, `%`; arrows after prefix | Two independent shell panes | Check prefix/terminal keyboard |
| C# | From solution root `nvim .`; open `.cs`; `:checkhealth vim.lsp` | Roslyn attached after solution loads | Check Mason, SDK, root and indexing |
| Navigation | `gd`, `gr`, `Space ff`, `Space fg` | Definition, references, file finder, grep work | Check Roslyn, ripgrep, plugins |
| Completion | Type C# in insert mode; `Ctrl+Space` | blink.cmp suggestions appear | Check LSP and completion plugin |
| Claude | Run `claude` in other tmux pane | Authenticated CLI opens | Follow official installer/sign-in |
| Build/test | `dotnet build` / `dotnet test` at appropriate solution/project | Expected project build and tests succeed | Diagnose project/toolchain separately |
| Detach | `Ctrl+b`, `d`; `tmux attach -t verify` | Session survives detach | Check session name with `tmux ls` |

End disposable verification session with `tmux kill-session -t verify` **only after saving work**. A real project's tests can require services or credentials; distinguish environment problems from existing project failures.

## 13. Common decision points and safe defaults

**Where should I start Neovim?** Start in the directory containing the solution (`.sln` or `.slnx`) when practical, rather than a random subdirectory. Roslyn's project selection is solution-aware; `:Roslyn target` can help if needed.

**Should I run Claude inside Neovim?** Default to a separate tmux pane. `:terminal` is available but adds Neovim terminal-mode complexity and isn't required for this setup. A separate GNOME Terminal window also works but isn't preserved by tmux unless you start tmux in it.

**Who should edit a file?** Avoid simultaneous unsaved Neovim edits and Claude edits to the same file. Save or explicitly discard your local buffer first. After Claude writes, `:checktime` checks for external modifications; if Neovim reports a conflict, inspect both versions rather than force-reloading.

**Where do builds and tests go?** A third tmux pane or window is ideal: it preserves build output while Claude and Neovim remain open. From the correct solution/project directory use `dotnet restore`, `dotnet build`, `dotnet test`, and `dotnet run --project path/to/App.csproj` as applicable. Some repos need custom scripts or credentials.

**Which keys are configured?** `Space` is Neovim leader; tmux uses `Ctrl+b` followed by a second key. `Ctrl+h/j/k/l` moves between Neovim windows **only**; tmux panes use `Ctrl+b` then arrow. The `|` split is an extra custom tmux mapping; the built-in `%` works too.

**Should I update everything on a new machine?** No. Restore locked Neovim plugins first. Verify current Roslyn/Mason compatibility and the project SDK before deliberately upgrading. The Mason Roslyn binary is **not** pinned by `lazy-lock.json`.

## 14. Maintaining documentation as the configuration evolves

When you change a Neovim keymap, tmux binding, plugin, Roslyn version, or installation path: (1) test it in a real session, (2) update `README.md` only if setup changes, (3) update this manual's authoritative explanation, (4) update `CHEATSHEET.md` if a daily command changes, (5) update `TOOLS.md` for tested versions, and (6) update `REBUILD_PROMPT.md` if the recovery workflow changes. Commit docs and config together, then verify `git status --short` is clean after pushing.

**Rebuild assistant handoff:** [REBUILD_PROMPT.md](REBUILD_PROMPT.md) is designed to be pasted into ChatGPT or Claude. It tells the assistant to inspect the actual repository, avoid destructive commands, work incrementally, and verify each step rather than inventing the state of a fresh machine.


---

## 15. Recovery checklist (printable)

- [ ] Fedora installed and updated.
- [ ] Git, GitHub CLI, Neovim (compatible version), tmux, ripgrep, fd, and build prerequisites installed.
- [ ] Required .NET SDK installed; `dotnet --info` checked.
- [ ] GitHub authenticated; private dotfiles repo cloned to `~/.config/dotfiles`.
- [ ] Existing config safely backed up, if present.
- [ ] `~/.config/nvim` resolves to `~/.config/dotfiles/nvim`.
- [ ] `~/.config/tmux/tmux.conf` resolves to `~/.config/dotfiles/tmux.conf`.
- [ ] `nvim` opens; `:Lazy restore` completed; Treesitter parsers available.
- [ ] Mason `roslyn-language-server` installed and Roslyn attaches in a real C# solution.
- [ ] `gd`, `gr`, diagnostics, completion, Telescope, and Neo-tree tested.
- [ ] Claude Code installed and authenticated independently.
- [ ] tmux `mouse on`, `base-index 1`, and split/reattach tested.
- [ ] Project repositories restored separately; `dotnet build` and tests run.
- [ ] Git identity, SSH keys, app defaults, and other machine-local settings reviewed.
- [ ] No credentials or project secrets accidentally committed to dotfiles.

## 16. What is **not** yet configured

To keep this manual accurate, these are *not* part of the currently verified dotfiles: seamless Neovim↔tmux navigation with the same Ctrl+h/j/k/l keys; automatic tmux resurrection after reboot; a dedicated Neovim Claude plugin; a custom periodic `:checktime` autocmd; a fully pinned Roslyn Mason installation script; a fully automated Fedora bootstrap installer; GNOME file-association settings; .NET SDK installation; and project repository cloning. They can be added later, tested, committed, and then documented as actual behavior.

---

**Maintenance rule:** Whenever a keyboard mapping, plugin, tmux option, or recovery step changes, test it first, commit it to the private dotfiles repo, and update this manual and `README.md` in the same commit.


---

