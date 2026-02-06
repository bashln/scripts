#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando ghostty"
    # Ghostty esta disponivel via COPR no Fedora
    ensure_copr_package "pgdev/ghostty" "ghostty"
}

main "$@"
