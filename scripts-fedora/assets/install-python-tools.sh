#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

install_ruff() {
	if command -v ruff >/dev/null 2>&1 || pip show ruff >/dev/null 2>&1; then
		info "ruff ja instalado. Pulando."
		return 0
	fi

	info "Instalando ruff..."
	ensure_package "ruff" || {
		warn "ruff nao encontrado nos repos oficiais, tentando pip..."
		if pip install --user ruff >>"$LOG_FILE" 2>&1; then
			ok "ruff instalado via pip."
		else
			warn "Falha ao instalar ruff via pip."
		fi
	}

	return 0
}

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

	# Ruff via repositorio/pip
	install_ruff

	ok "Ferramentas Python instaladas."
}

main "$@"
