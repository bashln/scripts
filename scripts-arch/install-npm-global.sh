#!/bin/bash
set -euo pipefail

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

main() {
  if ! command -v npm >/dev/null 2>&1; then
    warn "npm não encontrado; pulando instalação de pacotes globais npm."
    return
  fi

  log "Instalando/atualizando pacotes globais npm para LSP/Dev..."
  log "Dica: configure um prefix de usuário para evitar sudo, por exemplo:"
  log "  npm config set prefix \"\$HOME/.npm-global\""
  log "  export PATH=\"\$HOME/.npm-global/bin:\$PATH\""

  set +e
  npm -g install \
    typescript typescript-language-server \
    eslint_d \
    prettier \
    @vue/language-server \
    @angular/language-service \
    vscode-langservers-extracted \
    yaml-language-server \
    dockerfile-language-server-nodejs \
    pyright
  rc=$?
  set -e

  if [[ $rc -ne 0 ]]; then
    warn "npm global terminou com avisos/erros. Veja a saída acima."
  else
    ok "Pacotes npm globais instalados/atualizados."
  fi
}

main "$@"

