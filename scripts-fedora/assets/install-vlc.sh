#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando VLC"
    # VLC requer RPM Fusion
    ensure_rpmfusion
    ensure_package "vlc"
}

main "$@"
