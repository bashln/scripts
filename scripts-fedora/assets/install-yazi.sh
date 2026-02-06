#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando yazi"
    # Yazi esta disponivel via COPR
    ensure_copr_package "atim/yazi" "yazi"
}

main "$@"
