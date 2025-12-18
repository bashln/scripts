#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando ferramentas Python (pylsp, black)"

  if sudo pacman -S --noconfirm --needed python-pylsp python-black; then
    ok "Ferramentas Python instaladas."
  else
    warn "Falha ao instalar ferramentas Python."
  fi
}

main "$@"

