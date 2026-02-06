#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando bibliotecas 32-bit (para Wine/Gaming)"

    # No Fedora, pacotes 32-bit usam o sufixo .i686
    packages=(
        "glibc.i686"
        "libstdc++.i686"
        "mesa-dri-drivers.i686"
        "mesa-vulkan-drivers.i686"
        "vulkan-loader.i686"
        "alsa-lib.i686"
        "pulseaudio-libs.i686"
        "gnutls.i686"
        "libXcomposite.i686"
        "libXinerama.i686"
        "opencl-utils.i686"
        "SDL2.i686"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Bibliotecas 32-bit instaladas."
}

main "$@"
