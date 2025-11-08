#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando yazi"

  if sudo pacman -S --noconfirm --needed yazi; then
    ok "yazi instalado."
  else
    warn "Falha ao instalar yazi."
  fi
}

main "$@"

