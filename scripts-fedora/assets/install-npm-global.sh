#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# --- Configuracao ---
NPM_GLOBAL_DIR="$HOME/.npm-global"

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
    info "Instalando/atualizando LSPs e ferramentas de Dev..."

    if npm -g install \
        typescript typescript-language-server \
        eslint_d \
        prettier \
        @vue/language-server \
        @angular/language-service \
        vscode-langservers-extracted \
        yaml-language-server \
        dockerfile-language-server-nodejs \
        pyright >> "$LOG_FILE" 2>&1; then

        ok "Pacotes npm globais instalados com sucesso."
    else
        fail "Falha ao instalar pacotes npm. Verifique o log."
        return 1
    fi

    # Verifica se o usuario usa Fish
    if [[ "$SHELL" == */fish ]]; then
        local fish_config="$HOME/.config/fish/config.fish"

        if [[ -f "$fish_config" ]]; then
            if ! grep -q "npm-global" "$fish_config"; then
                info "Configurando PATH no Fish Shell..."
                echo -e "\n# NPM Global Path" >> "$fish_config"
                echo "fish_add_path $HOME/.npm-global/bin" >> "$fish_config"
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
