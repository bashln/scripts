#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "Flatpak não encontrado; instale-o antes de instalar apps Flatpak."
    return 1
  fi

  log "Instalando Spotify (com.spotify.Client) via Flathub..."

  if flatpak install -y flathub com.spotify.Client; then
    ok "Spotify instalado."
  else
    warn "Falha ao instalar Spotify."
  fi
}

main "$@"

