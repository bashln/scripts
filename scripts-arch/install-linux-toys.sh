#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  log "Instalando LinuxToys (script remoto)..."

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl não encontrado; não foi possível instalar LinuxToys."
    return
  fi

  # AVISO: script remoto - sempre confira se você confia na origem.
  if curl -fsSL https://linux.toys/install.sh | sh; then
    ok "LinuxToys instalado (ou atualizado)."
  else
    warn "Falha ao instalar LinuxToys."
  fi
}

main "$@"

