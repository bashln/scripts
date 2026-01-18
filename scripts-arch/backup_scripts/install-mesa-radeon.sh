#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Mesa e drivers Vulkan para Radeon"

  if sudo pacman -S --noconfirm --needed \
      mesa lib32-mesa \
      vulkan-radeon lib32-vulkan-radeon; then
    ok "Mesa + Radeon stack instaladas."
  else
    warn "Falha ao instalar Mesa/Radeon stack."
  fi
}

main "$@"

