#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando yazi"
    ensure_package "yazi"
}

main "$@"
