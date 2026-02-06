#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    # Flatpak ja vem pre-instalado no Fedora, mas garantimos
    ensure_package "flatpak"

    # Adiciona o repositorio Flathub
    info "Adicionando repositorio Flathub..."

    if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
        ok "Flathub adicionado."
    else
        fail "Erro ao adicionar Flathub. Verifique internet ou DNS."
        exit 1
    fi
}

main "$@"
