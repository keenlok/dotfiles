#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_DIR="${REPO_ROOT}/configs"
STAMP="$(date +%Y%m%d%H%M%S)"
NVM_VERSION="${NVM_VERSION:-v0.40.3}"
NODE_VERSION="${NODE_VERSION:-20}"

install_zsh() {
  if command -v zsh >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "zsh is not installed and apt-get is unavailable."
    echo "Install zsh manually, then rerun this script."
    exit 1
  fi

  echo "zsh is not installed. Installing with apt-get..."
  sudo apt-get update
  sudo apt-get install -y zsh
}

install_nvm() {
  local nvm_dir="${HOME}/.nvm"

  if [[ -s "${nvm_dir}/nvm.sh" ]]; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is not installed. Installing with apt-get..."
    sudo apt-get update
    sudo apt-get install -y curl
  fi

  echo "nvm is not installed. Installing ${NVM_VERSION}..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
}

load_nvm() {
  export NVM_DIR="${HOME}/.nvm"

  if [[ ! -s "${NVM_DIR}/nvm.sh" ]]; then
    echo "nvm install completed, but ${NVM_DIR}/nvm.sh was not found."
    exit 1
  fi

  # shellcheck source=/dev/null
  source "${NVM_DIR}/nvm.sh"
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

mkdir -p "${HOME}/.shortcuts"

install_zsh
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
link_file "${CONFIG_DIR}/.zshrc_ubuntu" "${HOME}/.zshrc"
link_file "${CONFIG_DIR}/lazy.rc" "${HOME}/.shortcuts/lazy.rc"

if [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
  echo
  echo "Current login shell is not zsh."
  echo "Switch it with: chsh -s $(command -v zsh)"
fi

echo
echo "Ubuntu zsh setup is ready."
echo "Open a new shell or run: exec zsh"
