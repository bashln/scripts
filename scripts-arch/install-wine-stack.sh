#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Wine e componentes relacionados"

  if sudo pacman -S --noconfirm --needed \
      wine winetricks wine-mono wine_gecko; then
    ok "Wine stack instalada."
  else
    warn "Falha ao instalar Wine stack."
  fi
}

main "$@"

