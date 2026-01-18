# myrpi

> Transform your Raspberry Pi into a powerful development machine in minutes.

One command. Zero hassle. Everything you need to start coding on your Raspberry Pi.

## Quick Start

**One-liner install** (recommended):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://g50.setup.katbutler.com | sudo bash -s setup
```

**Or clone and run locally**:

```bash
git clone https://github.com/katbutler/myrpi.git
cd myrpi
sudo ./init.sh setup
source ~/.bashrc
```

## What is myrpi?

**myrpi** is an automated setup script that transforms a fresh Raspberry Pi into a fully-configured development environment. It installs modern developer tools, configures your shell with helpful aliases and functions, and sets up git workflows - all automatically.

## Why myrpi?

- **Save Hours of Setup Time** - What takes hours to install manually happens in minutes
- **Reliable & Safe** - SHA256 verification ensures you get legitimate software
- **Idempotent** - Run it multiple times safely; it won't break existing configurations
- **Modern Tools** - Get the latest development tools: neovim, fzf, ripgrep, lazygit, and more
- **Enhanced Shell** - Beautiful prompts, smart aliases, and powerful completions out of the box
- **Extensible** - Easy to add your own tools and configurations

## What Gets Installed?

| Category | Tools |
|----------|-------|
| **Text Editor** | neovim (v0.11.5) with LazyVim |
| **Version Managers** | asdf (v0.18.0) for Node.js, uv for Python |
| **CLI Enhancements** | bat, eza, fzf, ripgrep, zoxide, atuin |
| **Git Tools** | lazygit, GitHub CLI (gh), custom aliases |
| **Dev Utilities** | jq, yq, httpie, tmux, htop |
| **Languages** | Python 3.14 (via uv), Node.js v24.13.0 (via asdf) |

Plus automatic configuration of your shell with:
- Smart command aliases (`cat` → `bat`, `cd` → `zoxide`, `ls` → `eza`)
- Git shortcuts (`git s`, `git co`, `git lol`, etc.)
- Custom functions (`mkcd`, `extract`, `note`)
- Informative prompt with git branch display
- Enhanced shell history with atuin

## Requirements

- Raspberry Pi 4 Model B (ARM64)
- Raspberry Pi OS (Debian-based)
- Internet connection
- `sudo` privileges

## Uninstalling

To remove tools installed by myrpi:

```bash
# Interactive menu - select what to remove
sudo ./uninstall.sh

# Remove everything
sudo ./uninstall.sh all

# Remove specific components
sudo ./uninstall.sh neovim
sudo ./uninstall.sh asdf
sudo ./uninstall.sh config
```

Available uninstall commands:
- `apt` - apt packages (jq, yq, htop, zoxide, ripgrep, tmux, lazygit, httpie)
- `gh` - GitHub CLI and apt repository
- `neovim` - neovim binary and runtime files
- `lazyvim` - LazyVim configuration and cache
- `bat`, `fzf`, `eza` - Individual CLI tools
- `asdf` - asdf and all managed tools (Node.js)
- `atuin` - Shell history tool
- `uv` - Python version manager and installed Pythons
- `config` - myrpi configuration and .bashrc modifications
- `aliases` - Git aliases

## Git Aliases

The setup configures these global git aliases:

| Alias | Command |
|-------|---------|
| `git s` | `git status` |
| `git co` | `git checkout` |
| `git br` | `git branch -vv` |
| `git com` | `git commit` |
| `git l` | `git log` |
| `git lol` | Pretty formatted log with colors |
| `git publish` | `git push origin main` |
| `git unstage` | `git reset HEAD` |
| `git sha` | Get full commit SHA |
| `git shortsha` | Get short commit SHA |
| `git fzf-branch` | List branches with fzf |
| `git fzf-co` | Checkout branch using fzf |

## Extending the Setup

### Adding apt packages

Edit `init.sh` and add to the `packages` array in `install_apt_packages()`:

```bash
local packages=(
  git
  jq
  # add your package here
)
```

### Adding GitHub releases

Call `install_github_release` in the `setup()` function:

```bash
install_github_release "tool-name" "https://github.com/.../tool.tar.gz" "sha256hash" "extracted-dir-name"
```

### Adding curl-based installers

Call `install_curl_script` in the `setup()` function:

```bash
install_curl_script "tool-name" "bash <(curl -sSL https://...)"
```

### Environment configuration

Edit `config/env` to add:
- PATH modifications
- Aliases
- Shell functions
- Environment variables

Changes take effect after restarting your shell or running `source ~/.bashrc`.

## License

MIT License
