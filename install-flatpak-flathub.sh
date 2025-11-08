#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "Flatpak não encontrado; instale-o antes de configurar o Flathub."
    return 1
  fi

  log "Configurando Flathub como repositório Flatpak..."

  if sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
    ok "Flathub configurado."
  else
    warn "Falha ao configurar o Flathub."
  fi
}

main "$@"

