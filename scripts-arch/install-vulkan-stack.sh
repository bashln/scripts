#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando Vulkan stack (ICD loaders, vkd3d, 32-bit libs)"

  if sudo pacman -S --noconfirm --needed \
      vulkan-icd-loader lib32-vulkan-icd-loader \
      vkd3d lib32-vkd3d; then
    ok "Vulkan stack instalada."
  else
    warn "Falha ao instalar Vulkan stack."
  fi
}

main "$@"

