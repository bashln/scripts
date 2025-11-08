#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Rust e rust-analyzer"

  if sudo pacman -S --noconfirm --needed rust rust-analyzer; then
    ok "Rust instalado."
  else
    warn "Falha ao instalar Rust."
  fi
}

main "$@"

