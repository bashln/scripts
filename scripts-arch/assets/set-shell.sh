#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
	info "Configurando Zsh como shell padrão"

	# Check if zsh is installed
	if ! command -v zsh &>/dev/null; then
		fail "Zsh não está instalado. Por favor, instale-o primeiro."
		exit 1
	fi

	# Get the path to zsh
	ZSH_PATH=$(which zsh)

	current_shell="${SHELL:-}"
	if command -v getent >/dev/null 2>&1; then
		passwd_shell=$(getent passwd "$USER" | cut -d: -f7 || true)
		if [ -n "$passwd_shell" ]; then
			current_shell="$passwd_shell"
		fi
	fi

	# Check if zsh is already the default shell
	if [ "$current_shell" = "$ZSH_PATH" ]; then
		ok "Zsh já é o seu shell padrão."
		return 0
	fi

	# Add zsh to /etc/shells if not already there
	if ! grep -q "^$ZSH_PATH$" /etc/shells; then
		info "Adicionando $ZSH_PATH ao /etc/shells..."
		echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
		ok "$ZSH_PATH adicionado ao /etc/shells."
	else
		ok "$ZSH_PATH já está em /etc/shells."
	fi

	# Change the default shell to zsh
	info "Alterando o shell padrão para zsh..."
	chsh -s "$ZSH_PATH"
	ok "Shell padrão alterado para zsh. Por favor, faça logout e login novamente para que a alteração tenha efeito."
}

main "$@"
