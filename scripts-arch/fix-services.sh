#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }
die()  { printf '[X] %s\n' "$*" >&2; exit 1; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Comando requerido não encontrado: $1"
  fi
}

require_cmd systemctl

if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
  require_cmd sudo
fi

main() {
  if systemctl list-unit-files | grep -q '^systemd-binfmt'; then
    log "Reiniciando systemd-binfmt..."
    if $SUDO systemctl restart systemd-binfmt; then
      ok "systemd-binfmt reiniciado."
    else
      warn "Falha ao reiniciar systemd-binfmt."
    fi
  else
    warn "systemd-binfmt não encontrado entre as units."
  fi
}

main "$@"

