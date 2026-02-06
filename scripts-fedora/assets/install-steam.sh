#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Steam"
    # Steam requer RPM Fusion (nonfree)
    ensure_rpmfusion
    ensure_package "steam"
}

main "$@"
