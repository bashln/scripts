#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando vivaldi"

  if sudo pacman -S --noconfirm --needed vivaldi; then
    ok "vivaldi instalado."
  else
    warn "Falha ao instalar vivaldi."
  fi
}

main "$@"

