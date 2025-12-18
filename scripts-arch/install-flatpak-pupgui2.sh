#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "Flatpak não encontrado; instale-o antes de instalar apps Flatpak."
    return 1
  fi

  log "Instalando PupGUI2 (net.davidotek.pupgui2) via Flathub..."

  if flatpak install -y flathub net.davidotek.pupgui2; then
    ok "PupGUI2 instalado."
  else
    warn "Falha ao instalar PupGUI2."
  fi
}

main "$@"

