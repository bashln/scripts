#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando asdf-vm"
    ensure_aur_package "asdf-vm"
}

main "$@"
