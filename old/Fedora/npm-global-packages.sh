#!/usr/bin/env bash
# ============================================================================
# Script: npm-global-packages.sh
# Descrição: Instala (ou atualiza) pacotes npm globais comuns para dev/LSP.
# Uso: ./npm-global-packages.sh   (sem sudo; ajuste prefix se preciso)
# ============================================================================
set -euo pipefail

LOG="${LOG_FILE:-$HOME/npm-global.log}"
: > "$LOG"
BLUE="\e[34m"; GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
log()  { printf "%s %b%s%b\n" "$(date '+%F %T')" "$BLUE" "$*" "$RESET" | tee -a "$LOG"; }
ok()   { printf "%s %b%s%b\n" "$(date '+%F %T')" "$GREEN" "$*" "$RESET" | tee -a "$LOG"; }
warn() { printf "%s %b%s%b\n" "$(date '+%F %T')" "$YELLOW" "$*" "$RESET" | tee -a "$LOG"; }
err()  { printf "%s %b%s%b\n" "$(date '+%F %T')" "$RED" "$*" "$RESET" | tee -a "$LOG"; }

# Dica: para evitar sudo no npm -g, configure um prefix de usuário:
#   npm config set prefix "$HOME/.npm-global"
#   echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc  # ou zshrc
#   source ~/.bashrc

if ! command -v npm >/dev/null 2>&1; then
  err "npm não encontrado. Instale Node.js/npm primeiro."
  exit 1
fi

log "Instalando/atualizando pacotes npm globais..."

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
  pyright >>"$LOG" 2>&1
RC=$?
set -e

if [[ $RC -ne 0 ]]; then
  warn "Terminado com avisos/erros (verifique $LOG)."
else
  ok "Todos os pacotes npm globais instalados/atualizados."
fi
