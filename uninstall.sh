#!/bin/bash

# myrpi - Raspberry Pi Development Environment Uninstall Script
# This script removes tools installed by init.sh
# Usage: sudo ./uninstall.sh [command]

set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Installation directories
INSTALL_DIR="/usr/local"

# Logging functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
  echo -e "\n${CYAN}=== $1 ===${NC}\n"
}

# Check if running as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run with sudo"
    exit 1
  fi
}

# Get the actual user (not root when using sudo)
get_actual_user() {
  if [[ -n "${SUDO_USER:-}" ]]; then
    echo "$SUDO_USER"
  else
    echo "$USER"
  fi
}

# Check if command exists
check_command() {
  command -v "$1" &>/dev/null
}

# Confirm action with user
confirm() {
  local prompt="$1"
  local response
  read -r -p "$prompt [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================================================
# Uninstall Functions
# ============================================================================

# Uninstall apt packages
uninstall_apt_packages() {
  log_section "Uninstalling apt packages"

  local packages=(
    jq
    yq
    htop
    zoxide
    ripgrep
    tmux
    lazygit
    httpie
    sqlite3
  )

  for package in "${packages[@]}"; do
    if dpkg -l "$package" &>/dev/null; then
      log_info "Removing $package..."
      apt-get remove -y "$package"
    else
      log_info "$package is not installed, skipping"
    fi
  done

  log_info "Running apt autoremove..."
  apt-get autoremove -y

  log_info "apt packages removed"
}

# Uninstall GitHub CLI
uninstall_gh() {
  log_section "Uninstalling GitHub CLI (gh)"

  if dpkg -l gh &>/dev/null; then
    log_info "Removing gh..."
    apt-get remove -y gh
  else
    log_info "gh is not installed, skipping"
  fi

  # Remove repository and keyring
  if [[ -f /etc/apt/sources.list.d/github-cli.list ]]; then
    log_info "Removing GitHub CLI apt repository..."
    rm -f /etc/apt/sources.list.d/github-cli.list
  fi

  if [[ -f /usr/share/keyrings/githubcli-archive-keyring.gpg ]]; then
    log_info "Removing GitHub CLI GPG key..."
    rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg
  fi

  apt-get update
  log_info "GitHub CLI removed"
}

# Uninstall neovim
uninstall_neovim() {
  log_section "Uninstalling neovim"

  local actual_user=$(get_actual_user)
  local user_home=$(eval echo "~$actual_user")

  if [[ -f "$INSTALL_DIR/bin/nvim" ]]; then
    log_info "Removing neovim binary..."
    rm -f "$INSTALL_DIR/bin/nvim"
  fi

  # Remove neovim runtime files
  if [[ -d "$INSTALL_DIR/share/nvim" ]]; then
    log_info "Removing neovim runtime files..."
    rm -rf "$INSTALL_DIR/share/nvim"
  fi

  if [[ -d "$INSTALL_DIR/lib/nvim" ]]; then
    log_info "Removing neovim lib files..."
    rm -rf "$INSTALL_DIR/lib/nvim"
  fi

  log_info "neovim removed"
}

# Uninstall LazyVim config
uninstall_lazyvim() {
  log_section "Uninstalling LazyVim"

  local actual_user=$(get_actual_user)
  local user_home=$(eval echo "~$actual_user")
  local nvim_config="$user_home/.config/nvim"
  local nvim_data="$user_home/.local/share/nvim"
  local nvim_state="$user_home/.local/state/nvim"
  local nvim_cache="$user_home/.cache/nvim"

  if [[ -d "$nvim_config" ]]; then
    log_info "Removing neovim config directory..."
    rm -rf "$nvim_config"
  fi

  if [[ -d "$nvim_data" ]]; then
    log_info "Removing neovim data directory..."
    rm -rf "$nvim_data"
  fi

  if [[ -d "$nvim_state" ]]; then
    log_info "Removing neovim state directory..."
    rm -rf "$nvim_state"
  fi

  if [[ -d "$nvim_cache" ]]; then
    log_info "Removing neovim cache directory..."
    rm -rf "$nvim_cache"
  fi

  log_info "LazyVim configuration removed"
}

# Uninstall bat
uninstall_bat() {
  log_section "Uninstalling bat"

  if [[ -f "$INSTALL_DIR/bin/bat" ]]; then
    log_info "Removing bat..."
    rm -f "$INSTALL_DIR/bin/bat"
    log_info "bat removed"
  else
    log_info "bat is not installed, skipping"
  fi
}

# Uninstall fzf
uninstall_fzf() {
  log_section "Uninstalling fzf"

  if [[ -f "$INSTALL_DIR/bin/fzf" ]]; then
    log_info "Removing fzf..."
    rm -f "$INSTALL_DIR/bin/fzf"
    log_info "fzf removed"
  else
    log_info "fzf is not installed, skipping"
  fi
}

# Uninstall eza
uninstall_eza() {
  log_section "Uninstalling eza"

  if [[ -f "$INSTALL_DIR/bin/eza" ]]; then
    log_info "Removing eza..."
    rm -f "$INSTALL_DIR/bin/eza"
    log_info "eza removed"
  else
    log_info "eza is not installed, skipping"
  fi
}

# Uninstall asdf and Node.js
uninstall_asdf() {
  log_section "Uninstalling asdf"

  local actual_user=$(get_actual_user)
  local user_home=$(eval echo "~$actual_user")
  local asdf_dir="$user_home/.asdf"

  # Remove asdf binary from /usr/local/bin
  if [[ -f "$INSTALL_DIR/bin/asdf" ]]; then
    log_info "Removing asdf binary..."
    rm -f "$INSTALL_DIR/bin/asdf"
  fi

  # Remove asdf data directory (includes all installed versions)
  if [[ -d "$asdf_dir" ]]; then
    log_info "Removing asdf data directory (includes Node.js installations)..."
    rm -rf "$asdf_dir"
  fi

  log_info "asdf and all asdf-managed tools removed"
}

# Uninstall atuin
uninstall_atuin() {
  log_section "Uninstalling atuin"

  local actual_user=$(get_actual_user)
  local user_home=$(eval echo "~$actual_user")
  local atuin_bin="$user_home/.cargo/bin/atuin"
  local atuin_data="$user_home/.local/share/atuin"
  local atuin_config="$user_home/.config/atuin"

  if [[ -f "$atuin_bin" ]]; then
    log_info "Removing atuin binary..."
    rm -f "$atuin_bin"
  fi

  if [[ -d "$atuin_data" ]]; then
    log_info "Removing atuin data directory..."
    rm -rf "$atuin_data"
  fi

  if [[ -d "$atuin_config" ]]; then
    log_info "Removing atuin config directory..."
    rm -rf "$atuin_config"
  fi

  log_info "atuin removed"
}

# Uninstall uv and Python
uninstall_uv() {
  log_section "Uninstalling uv and Python"

  local actual_user=$(get_actual_user)
  local user_home=$(eval echo "~$actual_user")
  local uv_bin="$user_home/.local/bin/uv"
  local uvx_bin="$user_home/.local/bin/uvx"
  local uv_cache="$user_home/.cache/uv"
  local uv_data="$user_home/.local/share/uv"

  if [[ -f "$uv_bin" ]]; then
    log_info "Removing uv binary..."
    rm -f "$uv_bin"
  fi

  if [[ -f "$uvx_bin" ]]; then
    log_info "Removing uvx binary..."
    rm -f "$uvx_bin"
  fi

  if [[ -d "$uv_cache" ]]; then
    log_info "Removing uv cache directory..."
    rm -rf "$uv_cache"
  fi

  if [[ -d "$uv_data" ]]; then
    log_info "Removing uv data directory (includes Python installations)..."
    rm -rf "$uv_data"
  fi

  log_info "uv and managed Python installations removed"
}

# Remove myrpi configuration
uninstall_config() {
  log_section "Removing myrpi configuration"

  local actual_user=$(get_actual_user)
  local user_home=$(eval echo "~$actual_user")
  local config_dir="$user_home/.config/myrpi"
  local bashrc="$user_home/.bashrc"

  # Remove config directory
  if [[ -d "$config_dir" ]]; then
    log_info "Removing myrpi config directory..."
    rm -rf "$config_dir"
  fi

  # Remove source line from .bashrc
  if [[ -f "$bashrc" ]] && grep -q "source ~/.config/myrpi/env" "$bashrc"; then
    log_info "Removing myrpi source line from .bashrc..."
    # Remove the source line and the comment above it
    sed -i '/# Source myrpi environment/d' "$bashrc"
    sed -i '/source ~\/.config\/myrpi\/env/d' "$bashrc"
    # Clean up any resulting empty lines at the end
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$bashrc"
  fi

  log_info "myrpi configuration removed"
}

# Remove git aliases
uninstall_git_aliases() {
  log_section "Removing git aliases"

  local actual_user=$(get_actual_user)

  local aliases=(
    "s"
    "co"
    "publish"
    "branch-name"
    "pull-current"
    "lol"
    "fzf-branch"
    "fzf-co"
    "l"
    "com"
    "br"
    "unstage"
    "sha"
    "shortsha"
  )

  for alias_name in "${aliases[@]}"; do
    if sudo -u "$actual_user" git config --global --get "alias.$alias_name" &>/dev/null; then
      log_info "Removing git alias: $alias_name"
      sudo -u "$actual_user" git config --global --unset "alias.$alias_name"
    fi
  done

  log_info "Git aliases removed"
}

# ============================================================================
# Menu and Main Functions
# ============================================================================

# Show interactive menu
show_menu() {
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}        ${YELLOW}myrpi Uninstall Menu${NC}                           ${CYAN}║${NC}"
  echo -e "${CYAN}╠════════════════════════════════════════════════════════╣${NC}"
  echo -e "${CYAN}║${NC}  1) Uninstall apt packages (jq, yq, htop, etc.)        ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  2) Uninstall GitHub CLI (gh)                          ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  3) Uninstall neovim                                   ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  4) Uninstall LazyVim config                           ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  5) Uninstall bat                                      ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  6) Uninstall fzf                                      ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  7) Uninstall eza                                      ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  8) Uninstall asdf (includes Node.js)                  ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  9) Uninstall atuin                                    ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} 10) Uninstall uv (includes Python)                     ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} 11) Remove myrpi configuration                         ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} 12) Remove git aliases                                 ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} ${RED}all) Uninstall everything${NC}                              ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  q) Quit                                               ${CYAN}║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

# Run interactive menu
interactive_menu() {
  while true; do
    show_menu
    read -r -p "Select option(s) (comma-separated, e.g., 1,3,5): " choices

    if [[ "$choices" == "q" || "$choices" == "Q" ]]; then
      log_info "Exiting..."
      exit 0
    fi

    if [[ "$choices" == "all" ]]; then
      if confirm "Are you sure you want to uninstall EVERYTHING?"; then
        uninstall_all
        log_info "All myrpi components have been removed"
        log_info "Please restart your shell"
        exit 0
      fi
      continue
    fi

    # Parse comma-separated choices
    IFS=',' read -ra selected <<<"$choices"
    for choice in "${selected[@]}"; do
      choice=$(echo "$choice" | tr -d ' ')
      case "$choice" in
      1) uninstall_apt_packages ;;
      2) uninstall_gh ;;
      3) uninstall_neovim ;;
      4) uninstall_lazyvim ;;
      5) uninstall_bat ;;
      6) uninstall_fzf ;;
      7) uninstall_eza ;;
      8) uninstall_asdf ;;
      9) uninstall_atuin ;;
      10) uninstall_uv ;;
      11) uninstall_config ;;
      12) uninstall_git_aliases ;;
      *) log_warn "Invalid option: $choice" ;;
      esac
    done

    echo ""
    if confirm "Continue uninstalling?"; then
      continue
    else
      break
    fi
  done

  log_info "Uninstall complete. Please restart your shell."
}

# Uninstall everything
uninstall_all() {
  log_info "Uninstalling all myrpi components..."

  uninstall_apt_packages
  uninstall_gh
  uninstall_neovim
  uninstall_lazyvim
  uninstall_bat
  uninstall_fzf
  uninstall_eza
  uninstall_asdf
  uninstall_atuin
  uninstall_uv
  uninstall_config
  uninstall_git_aliases
}

# Show usage
show_usage() {
  echo "Usage: sudo ./uninstall.sh [command]"
  echo ""
  echo "Commands:"
  echo "  menu      Interactive menu to select components (default)"
  echo "  all       Uninstall all components"
  echo "  apt       Uninstall apt packages"
  echo "  gh        Uninstall GitHub CLI"
  echo "  neovim    Uninstall neovim"
  echo "  lazyvim   Uninstall LazyVim config"
  echo "  bat       Uninstall bat"
  echo "  fzf       Uninstall fzf"
  echo "  eza       Uninstall eza"
  echo "  asdf      Uninstall asdf and Node.js"
  echo "  atuin     Uninstall atuin"
  echo "  uv        Uninstall uv and Python"
  echo "  config    Remove myrpi configuration"
  echo "  aliases   Remove git aliases"
  echo ""
}

# Main entry point
main() {
  check_root

  case "${1:-menu}" in
  menu) interactive_menu ;;
  all)
    if confirm "Are you sure you want to uninstall EVERYTHING?"; then
      uninstall_all
      log_info "All myrpi components have been removed"
      log_info "Please restart your shell"
    fi
    ;;
  apt) uninstall_apt_packages ;;
  gh) uninstall_gh ;;
  neovim) uninstall_neovim ;;
  lazyvim) uninstall_lazyvim ;;
  bat) uninstall_bat ;;
  fzf) uninstall_fzf ;;
  eza) uninstall_eza ;;
  asdf) uninstall_asdf ;;
  atuin) uninstall_atuin ;;
  uv) uninstall_uv ;;
  config) uninstall_config ;;
  aliases) uninstall_git_aliases ;;
  help | --help | -h) show_usage ;;
  *)
    log_error "Unknown command: $1"
    show_usage
    exit 1
    ;;
  esac
}

main "$@"
