#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

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

