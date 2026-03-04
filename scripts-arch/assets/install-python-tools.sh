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
		warn "ruff nao encontrado no repositorio, tentando pip..."
		if pip install --user ruff >>"$LOG_FILE" 2>&1; then
			ok "ruff instalado via pip."
		else
			warn "Falha ao instalar ruff via pip."
		fi
	}

	return 0
}

main() {
	info "Instalando ferramentas Python (pylsp, black)"

	packages=(
		"python-pylsp"
		"python-black"
	)

	for pkg in "${packages[@]}"; do
		ensure_package "$pkg"
	done

	install_ruff

	ok "Ferramentas Python instaladas."
}

main "$@"
