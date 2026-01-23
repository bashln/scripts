#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando ferramentas Python (pylsp, black)"

    packages=(
        "python-pylsp"
        "python-black"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    ok "Ferramentas Python instaladas."
}

main "$@"
