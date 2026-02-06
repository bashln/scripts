#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando ferramentas Python (lsp, formatadores)"

    # Pacotes disponiveis no repositorio Fedora
    packages=(
        "python3-lsp-server"
        "python3-black"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    # Ruff via COPR (melhor linter/formatter Python moderno)
    info "Instalando ruff..."
    ensure_package "ruff" || {
        warn "ruff nao encontrado nos repos oficiais, tentando pip..."
        pip install --user ruff 2>/dev/null || warn "Falha ao instalar ruff via pip."
    }

    ok "Ferramentas Python instaladas."
}

main "$@"
