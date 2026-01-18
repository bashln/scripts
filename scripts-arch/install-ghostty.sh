#!/bin/bash

# Install ghostty terminal emulator

#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log() { printf '[*] %s\n' "$*"; }
ok() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando ghostty"

  if yay -S --noconfirm --needed ghostty; then
    ok "ghostty instalado."
  else
    warn "Falha ao instalar ghostty."
  fi
}

main "$@"
