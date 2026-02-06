#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Configurando Zsh como shell padrao"

    if ! command -v zsh &>/dev/null; then
        fail "Zsh nao esta instalado. Por favor, instale-o primeiro."
        exit 1
    fi

    ZSH_PATH=$(which zsh)

    if [ "$SHELL" = "$ZSH_PATH" ]; then
        ok "Zsh ja e o seu shell padrao."
        exit 0
    fi

    if ! grep -q "^$ZSH_PATH$" /etc/shells; then
        info "Adicionando $ZSH_PATH ao /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
        ok "$ZSH_PATH adicionado ao /etc/shells."
    else
        ok "$ZSH_PATH ja esta em /etc/shells."
    fi

    info "Alterando o shell padrao para zsh..."
    chsh -s "$ZSH_PATH"
    ok "Shell padrao alterado para zsh. Faca logout e login novamente."
}

main "$@"
