#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

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

