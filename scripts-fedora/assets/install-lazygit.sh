#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando lazygit"
    # lazygit esta disponivel via COPR no Fedora
    ensure_copr_package "atim/lazygit" "lazygit"
}

main "$@"
