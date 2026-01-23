#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando VSCode via AUR..."
    ensure_aur_package "visual-studio-code-bin"
}

main "$@"
