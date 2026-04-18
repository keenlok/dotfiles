#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_DIR="${REPO_ROOT}/configs"
STAMP="$(date +%Y%m%d%H%M%S)"
NODE_VERSION="${NODE_VERSION:-20}"
ZSH_CONFIG="${ZSH_CONFIG:-${CONFIG_DIR}/.zshrc_macos_intel}"

require_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "This setup script is for macOS only."
    exit 1
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi

  echo "Homebrew is not installed. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/usr/local/bin/brew shellenv)"
}

install_brew_package() {
  local formula_name="$1"
  local binary_name="$2"

  if command -v "${binary_name}" >/dev/null 2>&1; then
    return 0
  fi

  install_homebrew
  echo "${binary_name} is not installed. Installing ${formula_name} with Homebrew..."
  brew install "${formula_name}"
}

install_nvm() {
  local nvm_dir="${HOME}/.nvm"

  if [[ -s "${nvm_dir}/nvm.sh" || -s /usr/local/opt/nvm/nvm.sh ]]; then
    mkdir -p "${nvm_dir}"
    return 0
  fi

  install_homebrew
  echo "nvm is not installed. Installing with Homebrew..."
  brew install nvm
  mkdir -p "${nvm_dir}"
}

load_nvm() {
  export NVM_DIR="${HOME}/.nvm"

  if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    source "${NVM_DIR}/nvm.sh"
    return 0
  fi

  if [[ -s /usr/local/opt/nvm/nvm.sh ]]; then
    # shellcheck source=/dev/null
    source /usr/local/opt/nvm/nvm.sh
    return 0
  fi

  echo "nvm was not found after installation."
  exit 1
}

install_node() {
  load_nvm

  if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed. Installing ${NODE_VERSION} with nvm..."
    nvm install "${NODE_VERSION}"
    nvm alias default "${NODE_VERSION}"
    return 0
  fi

  local major_version
  major_version="$(node -p 'process.versions.node.split(".")[0]')"
  if (( major_version < 20 )); then
    echo "Node.js ${major_version} detected. Upgrading to ${NODE_VERSION} with nvm..."
    nvm install "${NODE_VERSION}"
    nvm alias default "${NODE_VERSION}"
  fi
}

install_global_npm_package() {
  local package_name="$1"
  local binary_name="$2"

  if command -v "${binary_name}" >/dev/null 2>&1; then
    return 0
  fi

  load_nvm

  echo "Installing ${package_name}..."
  npm install -g "${package_name}"
}

backup_if_exists() {
  local target="$1"

  if [[ -e "${target}" || -L "${target}" ]]; then
    mv "${target}" "${target}.bak.${STAMP}"
    echo "Backed up ${target} -> ${target}.bak.${STAMP}"
  fi
}

link_file() {
  local source_path="$1"
  local target_path="$2"

  ln -sfn "${source_path}" "${target_path}"
  echo "Linked ${target_path} -> ${source_path}"
}

require_macos
mkdir -p "${HOME}/.shortcuts"

install_homebrew
install_brew_package "zsh" "zsh"
install_nvm
install_node
install_global_npm_package "@openai/codex" "codex"
install_global_npm_package "@google/gemini-cli@latest" "gemini"

backup_if_exists "${HOME}/.gitconfig"
backup_if_exists "${HOME}/.zprofile"
backup_if_exists "${HOME}/.zshrc"
backup_if_exists "${HOME}/.shortcuts/lazy.rc"

link_file "${CONFIG_DIR}/.gitconfig" "${HOME}/.gitconfig"
link_file "${CONFIG_DIR}/.zprofile" "${HOME}/.zprofile"
link_file "${ZSH_CONFIG}" "${HOME}/.zshrc"
link_file "${CONFIG_DIR}/lazy.rc" "${HOME}/.shortcuts/lazy.rc"

if [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
  echo
  echo "Current login shell is not zsh."
  echo "Switch it with: chsh -s $(command -v zsh)"
fi

echo
echo "macOS Intel zsh setup is ready."
echo "Open a new shell or run: exec zsh"
