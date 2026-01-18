#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando wl-clipboard"

  if sudo pacman -S --noconfirm --needed wl-clipboard; then
    ok "wl-clipboard instalado."
  else
    warn "Falha ao instalar wl-clipboard."
  fi
}

main "$@"

