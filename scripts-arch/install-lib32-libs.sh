#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando bibliotecas 32-bit auxiliares"

  if sudo pacman -S --noconfirm --needed \
      lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse \
      lib32-alsa-lib lib32-libxcomposite lib32-libxinerama \
      lib32-opencl-icd-loader lib32-gst-plugins-base-libs lib32-sdl2; then
    ok "Bibliotecas 32-bit instaladas."
  else
    warn "Falha ao instalar libs 32-bit."
  fi
}

main "$@"

