# dotfiles

Personal shell and tool configuration.

## Setup

Pick the script for the machine you are setting up.

### macOS Apple Silicon

Use this for the current Apple Silicon Mac:

```bash
./scripts/setup-macos-apple-silicon-zsh.sh
```

This script only runs on macOS `arm64`. It uses Homebrew from `/opt/homebrew` and links:

- `configs/.gitconfig` to `~/.gitconfig`
- `configs/.zprofile` to `~/.zprofile`
- `configs/.zshrc_macos_apple_silicon` to `~/.zshrc`
- `configs/lazy.rc` to `~/.shortcuts/lazy.rc`

### macOS Intel

Use this for an Intel Mac:

```bash
./scripts/setup-macos-intel-zsh.sh
```

This script is for macOS Intel machines. It uses Homebrew from `/usr/local` and links:

- `configs/.gitconfig` to `~/.gitconfig`
- `configs/.zprofile` to `~/.zprofile`
- `configs/.zshrc_macos_intel` to `~/.zshrc`
- `configs/lazy.rc` to `~/.shortcuts/lazy.rc`

### Ubuntu

Use this for Ubuntu/Linux:

```bash
./scripts/setup-ubuntu-zsh.sh
```

This script uses `apt-get` where needed and links:

- `configs/.gitconfig` to `~/.gitconfig`
- `configs/.zprofile` to `~/.zprofile`
- `configs/.zshrc_ubuntu` to `~/.zshrc`
- `configs/lazy.rc` to `~/.shortcuts/lazy.rc`

## What The Scripts Install

The setup scripts install or configure:

- zsh
- nvm
- Node.js 20 by default
- `@openai/codex`
- `@google/gemini-cli`

You can override the Node.js version when running a setup script:

```bash
NODE_VERSION=22 ./scripts/setup-macos-apple-silicon-zsh.sh
```

## Backups

Before linking files, the scripts back up existing targets with a timestamp suffix:

```text
~/.zshrc.bak.YYYYMMDDHHMMSS
```

The same backup behavior applies to:

- `~/.gitconfig`
- `~/.zprofile`
- `~/.zshrc`
- `~/.shortcuts/lazy.rc`

## Work Config

The work zsh config is kept separate:

```text
configs/.zshrc_work
```

The macOS and Ubuntu setup scripts do not link the work zsh config.
