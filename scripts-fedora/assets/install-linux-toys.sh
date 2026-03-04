#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
	info "Instalando LinuxToys (script remoto)..."

	if command -v linuxtoys >/dev/null 2>&1 || command -v linux-toys >/dev/null 2>&1 || [ -d "$HOME/.config/linux-toys" ] || [ -d "$HOME/.local/share/linux-toys" ]; then
		info "LinuxToys ja instalado. Pulando."
		return 0
	fi

	if ! command -v curl >/dev/null 2>&1; then
		warn "curl nao encontrado; nao foi possivel instalar LinuxToys."
		return
	fi

	if curl -fsSL https://linux.toys/install.sh | sh; then
		ok "LinuxToys instalado (ou atualizado)."
	else
		fail "Falha ao instalar LinuxToys."
	fi
}

main "$@"
