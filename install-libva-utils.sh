#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando libva-utils"

  if sudo pacman -S --noconfirm --needed libva-utils; then
    ok "libva-utils instalada."
  else
    warn "Falha ao instalar libva-utils."
  fi
}

main "$@"

