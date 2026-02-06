#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Brave Browser..."

    if rpm -q brave-browser &>/dev/null; then
        info "Brave ja instalado. Pulando."
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        fail "curl nao encontrado; nao foi possivel instalar Brave Browser."
        exit 1
    fi

    # Adiciona repositorio oficial do Brave
    info "Adicionando repositorio Brave..."
    sudo dnf install -y dnf-plugins-core >> "$LOG_FILE" 2>&1 || true

    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc 2>/dev/null || true

    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo 2>/dev/null \
        || sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo 2>/dev/null \
        || warn "Repositorio Brave pode ja estar adicionado."

    info "Instalando Brave..."
    if sudo dnf install -y brave-browser >> "$LOG_FILE" 2>&1; then
        ok "Brave Browser instalado."
    else
        fail "Falha ao instalar Brave Browser."
    fi
}

main "$@"
