#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando Charm Gum (TUI toolkit)"
    ensure_package "gum"
}

main "$@"
