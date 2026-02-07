#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando ferramentas de desenvolvimento (equivalente ao base-devel)"
    ensure_package "base-devel"
    ensure_package "gcc"
    ensure_package "make"
    ensure_package "automake"
    ensure_package "autoconf"
    ensure_package "pkgconf"
}

main "$@"
