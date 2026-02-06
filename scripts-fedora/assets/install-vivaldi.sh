#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Vivaldi Browser"

    if rpm -q vivaldi-stable &>/dev/null; then
        info "Vivaldi ja instalado. Pulando."
        return 0
    fi

    # Adiciona o repositorio oficial do Vivaldi
    info "Adicionando repositorio Vivaldi..."
    sudo dnf config-manager addrepo --from-repofile=https://repo.vivaldi.com/stable/vivaldi-fedora.repo 2>/dev/null \
        || sudo dnf config-manager --add-repo https://repo.vivaldi.com/stable/vivaldi-fedora.repo 2>/dev/null \
        || warn "Repositorio Vivaldi pode ja estar adicionado."

    info "Instalando Vivaldi..."
    if sudo dnf install -y vivaldi-stable >> "$LOG_FILE" 2>&1; then
        ok "Vivaldi instalado."
    else
        fail "Falha ao instalar Vivaldi."
    fi
}

main "$@"
