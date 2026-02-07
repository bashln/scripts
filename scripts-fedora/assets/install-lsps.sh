#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Iniciando instalacao das ferramentas de formatacao..."

    local packages=(
        "ShellCheck"
        "shfmt"
        "ripgrep"
        "fd-find"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ensure_npm_global "prettier" "prettier"

    # Ruff pode nao estar nos repos oficiais
    ensure_package "ruff" || {
        warn "ruff nao encontrado nos repos, tentando pip..."
        pip install --user ruff 2>/dev/null || warn "Falha ao instalar ruff."
    }

    ok "Ferramentas de formatacao instaladas."
}

main "$@"
