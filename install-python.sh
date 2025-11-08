#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Python"

  if sudo pacman -S --noconfirm --needed python; then
    ok "Python instalado."
  else
    warn "Falha ao instalar Python."
  fi
}

main "$@"

