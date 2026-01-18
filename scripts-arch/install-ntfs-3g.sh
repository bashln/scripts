#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando ntfs-3g"

  if sudo pacman -S --noconfirm --needed ntfs-3g; then
    ok "ntfs-3g instalado."
  else
    warn "Falha ao instalar ntfs-3g."
  fi
}

main "$@"

