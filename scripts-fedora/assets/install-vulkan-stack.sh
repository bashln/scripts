#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Vulkan stack"

    packages=(
        "vulkan-loader"
        "vulkan-tools"
        "vulkan-validation-layers"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ensure_package "vkd3d" || warn "vkd3d nao encontrado nos repos (opcional)."

    ok "Vulkan stack instalada."
}

main "$@"
