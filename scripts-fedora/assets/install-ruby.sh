#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Ruby"

    # Carrega asdf se disponivel
    if [ -f "$HOME/.asdf/asdf.sh" ]; then
        source "$HOME/.asdf/asdf.sh"
    fi

    if ! command -v asdf &>/dev/null; then
        warn "asdf nao esta instalado. Execute install-asdf.sh se quiser instalar Ruby via asdf."
        return 0
    fi

    # Instala dependencias de build do Ruby (Fedora)
    info "Instalando dependencias de build do Ruby..."
    packages=(
        "gcc"
        "make"
        "openssl-devel"
        "readline-devel"
        "zlib-devel"
        "libyaml-devel"
        "libffi-devel"
        "gdbm-devel"
    )
    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    # Instala plugin Ruby para asdf
    if ! asdf plugin list | grep -q ruby; then
        info "Adicionando plugin Ruby para asdf."
        asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
    else
        ok "Plugin Ruby para asdf ja instalado."
    fi

    # Instala a versao mais recente do Ruby
    if ! asdf list ruby &>/dev/null || [ -z "$(asdf list ruby 2>/dev/null)" ]; then
        info "Instalando a versao mais recente do Ruby..."
        asdf install ruby latest
        asdf set -u ruby latest
        ok "Ruby instalado."
    else
        ok "Ruby ja instalado."
    fi

    ok "Instalacao e configuracao do Ruby concluidas!"
}

main "$@"
