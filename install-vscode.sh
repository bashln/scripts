#!/bin/bash
set -euo pipefail

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

