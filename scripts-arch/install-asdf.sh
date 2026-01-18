#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando asdf-vm"

  if yay -S --noconfirm --needed asdf-vm; then
    ok "asdf-cm instalado."
  else
    warn "Falha ao instalar asdf-vm."
  fi
}

main "$@"

