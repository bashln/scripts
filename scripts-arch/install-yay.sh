#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Verificando AUR helper (yay)..."

  if ! command -v yay >/dev/null 2>&1; then
    warn "yay não encontrado. Instalação automática pode exigir intervenção manual."
    echo "Sugestão:"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay && makepkg -si --noconfirm"
    echo "  cd .. && rm -rf yay"
    return
  else
    ok "yay encontrado."
  fi

}

main "$@"

