#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando git"

  if sudo pacman -S --noconfirm --needed git; then
    ok "git instalado."
  else
    warn "Falha ao instalar git."
  fi
}

main "$@"

