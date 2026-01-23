#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando vivaldi"
    ensure_package "vivaldi"
}

main "$@"
