
#!/bin/bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/lib/utils.sh"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  # Garante que Go existe
  if ! command -v go >/dev/null 2>&1; then
    warn "Go não encontrado; tentando instalar via pacman..."

    if sudo pacman -S --noconfirm --needed go ; then
      ok "Go instalado."
    else
      warn "Falha ao instalar Go. Abortando instalação."
      return 1
    fi
  fi

  log "Instalando/atualizando gopls via 'go install'..."

  GOBIN="${GOBIN:-$HOME/go/bin}"
  mkdir -p "$GOBIN"

  if GO111MODULE=on GOBIN="$GOBIN" go install golang.org/x/tools/gopls@latest; then
    ok "gopls instalado/atualizado em $GOBIN."
  else
    warn "Falha ao instalar gopls via go install."
  fi
}

main "$@"


