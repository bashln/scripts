#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {

  log "Instalando VSCode via AUR..."

  if yay -S --noconfirm --needed \
      visual-studio-code-bin; then
    ok "VSCode Instalado"
  else
    warn "Falha ao instalar."
  fi
}

main "$@"

