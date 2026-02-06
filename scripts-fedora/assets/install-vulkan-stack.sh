#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Vulkan stack"

    packages=(
        "vulkan-loader"
        "vulkan-tools"
        "vulkan-validation-layers"
        "vkd3d"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Vulkan stack instalada."
}

main "$@"
