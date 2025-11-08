#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando cmake"

  if sudo pacman -S --noconfirm --needed cmake; then
    ok "cmake instalado."
  else
    warn "Falha ao instalar cmake."
  fi
}

main "$@"

