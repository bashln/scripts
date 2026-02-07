#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando fontes (programacao + nerd fonts)..."

    # Fontes disponiveis nos repos oficiais do Fedora
    packages=(
        "fira-code-fonts"
        "fira-mono-fonts"
        "jetbrains-mono-fonts-all"
        "google-noto-fonts-common"
        "google-noto-emoji-fonts"
        "google-noto-sans-fonts"
        "google-noto-serif-fonts"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    # Nerd Fonts via COPR
    info "Instalando Nerd Fonts via COPR..."
    ensure_copr_package "che/nerd-fonts" "iosevka-term-nerd-fonts" || true
    ensure_copr_package "che/nerd-fonts" "jetbrains-mono-nerd-fonts" || true
    ensure_copr_package "che/nerd-fonts" "inconsolata-nerd-fonts" || true
    ensure_copr_package "che/nerd-fonts" "space-mono-nerd-fonts" || true

    ok "Fontes instaladas."
}

main "$@"
