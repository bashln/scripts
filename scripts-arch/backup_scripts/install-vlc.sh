#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando vlc"

  if sudo pacman -S --noconfirm --needed vlc; then
    ok "vlc instalado."
  else
    warn "Falha ao instalar vlc."
  fi
}

main "$@"

