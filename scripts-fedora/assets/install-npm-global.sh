#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# --- Configuracao ---
NPM_GLOBAL_DIR="$HOME/.npm-global"

install_npm_global_package() {
	local pkg="$1"

	if npm list -g "$pkg" --depth=0 >/dev/null 2>&1; then
		info "$pkg ja instalado via npm. Pulando."
		return 0
	fi

	if npm -g install "$pkg" >>"$LOG_FILE" 2>&1; then
		ok "Pacote npm '$pkg' instalado com sucesso."
		return 0
	fi

	fail "Falha ao instalar pacote npm '$pkg'. Verifique o log."
	return 1
}

main() {
	# 1. Verifica existencia do npm
	if ! command -v npm >/dev/null 2>&1; then
		warn "npm nao encontrado no PATH. Instale o nodejs/npm antes."
		return
	fi

	info "Configurando ambiente NPM Global (User Space)..."

	# 2. Cria o diretorio se nao existir
	if [ ! -d "$NPM_GLOBAL_DIR" ]; then
		mkdir -p "$NPM_GLOBAL_DIR"
		ok "Diretorio $NPM_GLOBAL_DIR criado."
	fi

	# 3. Configura o prefixo do npm
	npm config set prefix "$NPM_GLOBAL_DIR"
	ok "Prefixo npm configurado para: $NPM_GLOBAL_DIR"

	# 4. Instalacao dos Pacotes
	info "Instalando pacotes npm globais ausentes..."

	local npm_packages=(
		typescript
		typescript-language-server
		eslint_d
		prettier
		@vue/language-server
		@angular/language-service
		vscode-langservers-extracted
		yaml-language-server
		dockerfile-language-server-nodejs
		pyright
	)

	local pkg
	for pkg in "${npm_packages[@]}"; do
		install_npm_global_package "$pkg" || return 1
	done

	ok "Pacotes npm globais verificados/instalados com sucesso."

	# Verifica se o usuario usa Fish
	if [[ "$SHELL" == */fish ]]; then
		local fish_config="$HOME/.config/fish/config.fish"

		if [[ -f "$fish_config" ]]; then
			if ! grep -q "npm-global" "$fish_config"; then
				info "Configurando PATH no Fish Shell..."
				echo -e "\n# NPM Global Path" >>"$fish_config"
				echo "fish_add_path $HOME/.npm-global/bin" >>"$fish_config"
				ok "Fish config atualizado."
			else
				info "Fish ja esta configurado."
			fi
		fi
	fi

	# 5. Validacao do PATH
	if [[ ":$PATH:" != *":$NPM_GLOBAL_DIR/bin:"* ]]; then
		warn "O diretorio '$NPM_GLOBAL_DIR/bin' nao esta no seu PATH atual."
		warn "Adicione a seguinte linha ao seu .bashrc ou .zshrc:"
		warn "export PATH=\"$NPM_GLOBAL_DIR/bin:\$PATH\""
	fi
}

main "$@"
