#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando stow"

  if sudo pacman -S --noconfirm --needed stow; then
    ok "stow instalado."
  else
    warn "Falha ao instalar stow."
  fi
}

main "$@"

