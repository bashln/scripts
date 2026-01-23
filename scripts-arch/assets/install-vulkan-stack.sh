#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Vulkan stack (ICD loaders, vkd3d, 32-bit libs)"

    packages=(
        "vulkan-icd-loader"
        "lib32-vulkan-icd-loader"
        "vkd3d"
        "lib32-vkd3d"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Vulkan stack instalada."
}

main "$@"
