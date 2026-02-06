#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando dependencias para Yazi"

    packages=(
        "ffmpeg"
        "p7zip"
        "jq"
        "poppler-utils"
        "fd-find"
        "ripgrep"
        "fzf"
        "zoxide"
        "ImageMagick"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    # ffmpegthumbnailer pode precisar de RPM Fusion
    ensure_package "ffmpegthumbnailer" || warn "ffmpegthumbnailer nao encontrado (pode precisar de RPM Fusion)."

    ok "Dependencias para Yazi instaladas."
}

main "$@"
