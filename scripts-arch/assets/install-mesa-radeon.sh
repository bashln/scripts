#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Mesa e drivers Vulkan para Radeon"

    packages=(
        "mesa"
        "lib32-mesa"
        "vulkan-radeon"
        "lib32-vulkan-radeon"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Mesa + Radeon stack instaladas."
}

main "$@"
