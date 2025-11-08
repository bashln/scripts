#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando lazygit"

  if sudo pacman -S --noconfirm --needed lazygit; then
    ok "lazygit instalado."
  else
    warn "Falha ao instalar lazygit."
  fi
}

main "$@"

