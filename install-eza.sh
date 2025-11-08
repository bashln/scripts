#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando eza"

  if sudo pacman -S --noconfirm --needed eza; then
    ok "eza instalado."
  else
    warn "Falha ao instalar eza."
  fi
}

main "$@"

