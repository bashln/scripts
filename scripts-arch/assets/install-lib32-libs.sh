#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando bibliotecas 32-bit auxiliares"

    packages=(
        "lib32-giflib"
        "lib32-gnutls"
        "lib32-v4l-utils"
        "lib32-libpulse"
        "lib32-alsa-lib"
        "lib32-libxcomposite"
        "lib32-libxinerama"
        "lib32-opencl-icd-loader"
        "lib32-gst-plugins-base-libs"
        "lib32-sdl2"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Bibliotecas 32-bit instaladas."
}

main "$@"
