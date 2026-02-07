#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Microsoft Edge (Flatpak)"
    ensure_flatpak_package "com.microsoft.Edge"
}

main "$@"
