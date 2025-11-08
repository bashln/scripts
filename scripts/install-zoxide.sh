#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando zoxide"

  if sudo pacman -S --noconfirm --needed zoxide; then
    ok "zoxide instalado."
  else
    warn "Falha ao instalar zoxide."
  fi
}

main "$@"

