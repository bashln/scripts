
#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando nodejs e npm"

  if sudo pacman -S --noconfirm --needed nodejs npm; then
    ok "Node.js e npm instalados."
  else
    warn "Falha ao instalar Node.js e npm."
  fi
}

main "$@"

