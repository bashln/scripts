#!/usr/bin/env bash
# =============================================================================
# install-devtools.sh - Dev tools via Homebrew (Exceto Node/Rust que tem scripts propios)
# =============================================================================

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/utils.sh"

check_root

info "Instalando dev tools via Homebrew"

ensure_homebrew
load_homebrew_env || {
	warn "Homebrew nao disponivel, pulando"
	return 0
}

brew_install "lazydocker"
brew_install "delta"
brew_install "ghq"
brew_install "bottom" # btop - monitor de sistema

ok "Dev tools instaladas"
