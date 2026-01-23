#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando fontes (programação + nerd fonts)..."

    packages=(
        "ttf-fira-code"
        "ttf-jetbrains-mono"
        "ttf-ubuntu-font-family"
        "ttf-space-mono-nerd"
        "ttf-iosevka-nerd"
        "ttf-inconsolata-nerd"
        "ttf-jetbrains-mono-nerd"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Fontes instaladas."
}

main "$@"
