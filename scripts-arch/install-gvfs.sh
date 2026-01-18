#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando gvfs"

  if sudo pacman -S --noconfirm --needed gvfs; then
    ok "gvfs instalado."
  else
    warn "Falha ao instalar gvfs."
  fi
}

main "$@"

