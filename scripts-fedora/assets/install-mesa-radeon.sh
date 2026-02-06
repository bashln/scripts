#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Mesa e drivers Vulkan para Radeon"

    packages=(
        "mesa-dri-drivers"
        "mesa-vulkan-drivers"
        "mesa-va-drivers"
        "xorg-x11-drv-amdgpu"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Mesa + Radeon stack instaladas."
}

main "$@"
