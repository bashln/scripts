#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Configurando RPM Fusion (free + nonfree)..."
    ensure_rpmfusion

    # Instala appstream-data do RPM Fusion para integracao com GNOME Software
    info "Instalando metadados AppStream do RPM Fusion..."
    ensure_package "rpmfusion-free-appstream-data" || true
    ensure_package "rpmfusion-nonfree-appstream-data" || true

    ok "RPM Fusion configurado."
}

main "$@"
