#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Steam"

  if sudo pacman -S --noconfirm --needed steam; then
    ok "Steam instalado."
  else
    warn "Falha ao instalar Steam."
  fi
}

main "$@"

