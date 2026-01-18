
#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
die()  { printf '[X] %s\n' "$*" >&2; exit 1; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Comando requerido não encontrado: $1"
  fi
}

require_cmd pacman

if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
  require_cmd sudo
fi

main() {
  log "Instalando fontes (programação + nerd fonts)..."

  $SUDO pacman -S --noconfirm --needed \
    ttf-fira-code \
    ttf-jetbrains-mono \
    ttf-ubuntu-font-family \
    ttf-space-mono-nerd \
    ttf-iosevka-nerd \
    ttf-inconsolata-nerd \
    ttf-jetbrains-mono-nerd

  ok "Fontes instaladas."
}

main "$@"
