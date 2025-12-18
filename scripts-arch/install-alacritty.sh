#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando alacritty"

  if sudo pacman -S --noconfirm --needed alacritty; then
    ok "alacritty instalado."
  else
    warn "Falha ao instalar alacritty."
  fi
}

main "$@"

