#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando base-devel"

  if sudo pacman -S --noconfirm --needed base-devel; then
    ok "base-devel instalado."
  else
    warn "Falha ao instalar base-devel."
  fi
}

main "$@"

