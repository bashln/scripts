#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando curl"

  if sudo pacman -S --noconfirm --needed curl; then
    ok "curl instalado."
  else
    warn "Falha ao instalar curl."
  fi
}

main "$@"

