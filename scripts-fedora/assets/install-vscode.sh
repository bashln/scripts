#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando VSCode..."

    if rpm -q code &>/dev/null; then
        info "VSCode ja instalado. Pulando."
        return 0
    fi

    # Adiciona repositorio oficial da Microsoft
    info "Adicionando repositorio Microsoft VSCode..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true

    if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
        sudo tee /etc/yum.repos.d/vscode.repo > /dev/null << 'REPO'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO
    fi

    info "Instalando VSCode..."
    if sudo dnf install -y code >> "$LOG_FILE" 2>&1; then
        ok "VSCode instalado."
    else
        fail "Falha ao instalar VSCode."
    fi
}

main "$@"
