#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando unzip"

  if sudo pacman -S --noconfirm --needed unzip; then
    ok "unzip instalado."
  else
    warn "Falha ao instalar unzip."
  fi
}

main "$@"

