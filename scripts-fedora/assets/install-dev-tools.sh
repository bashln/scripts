#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando ferramentas de desenvolvimento (equivalente ao base-devel)"
    ensure_group "development-tools"
    ensure_package "gcc-c++"
    ensure_package "make"
    ensure_package "automake"
    ensure_package "autoconf"
    ensure_package "pkgconf-pkg-config"
}

main "$@"
