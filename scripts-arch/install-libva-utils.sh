#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando libva-utils"

  if sudo pacman -S --noconfirm --needed libva-utils; then
    ok "libva-utils instalada."
  else
    warn "Falha ao instalar libva-utils."
  fi
}

main "$@"

