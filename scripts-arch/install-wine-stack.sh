#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Wine e componentes relacionados"

  if sudo pacman -S --noconfirm --needed \
      wine winetricks wine-mono wine_gecko; then
    ok "Wine stack instalada."
  else
    warn "Falha ao instalar Wine stack."
  fi
}

main "$@"

