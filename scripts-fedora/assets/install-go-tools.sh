#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    # No Fedora, o pacote se chama 'golang'
    ensure_package "golang"

    info "Instalando/atualizando gopls via 'go install'..."

    GOBIN="${GOBIN:-$HOME/go/bin}"
    mkdir -p "$GOBIN"

    if GO111MODULE=on GOBIN="$GOBIN" go install golang.org/x/tools/gopls@latest; then
        ok "gopls instalado/atualizado em $GOBIN."
    else
        fail "Falha ao instalar gopls via go install."
    fi
}

main "$@"
