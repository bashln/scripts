
#!/bin/bash
set -euo pipefail

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

