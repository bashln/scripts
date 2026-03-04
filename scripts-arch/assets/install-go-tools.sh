#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
	# Garante que Go existe
	ensure_package "go"

	if command -v gopls >/dev/null 2>&1; then
		info "gopls ja instalado. Pulando."
		return 0
	fi

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
