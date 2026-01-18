#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando samba"

  if sudo pacman -S --noconfirm --needed samba; then
    ok "samba instalado."
  else
    warn "Falha ao instalar samba."
  fi
}

main "$@"

