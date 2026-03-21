#!/usr/bin/env bash
# ============================================================================
# Autor: leonamsh (adaptado para Fedora)
# Script: fedora-npm-install.sh
# Descrição: Instala Node.js/NPM (DNF com stream moderna se disponível),
#            ferramentas de desenvolvimento e LSPs; instala pacotes npm globais.
# Uso: sudo ./fedora-npm-install.sh
# ============================================================================
set -euo pipefail

LOG="${LOG_FILE:-$HOME/fedora-npm-install.log}"
: > "$LOG"
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; BLUE="\e[34m"; RESET="\e[0m"
log()  { printf "%s %b%s%b\n" "$(date '+%F %T')" "$BLUE" "$*" "$RESET" | tee -a "$LOG"; }
ok()   { printf "%s %b%s%b\n" "$(date '+%F %T')" "$GREEN" "$*" "$RESET" | tee -a "$LOG"; }
warn() { printf "%s %b%s%b\n" "$(date '+%F %T')" "$YELLOW" "$*" "$RESET" | tee -a "$LOG"; }
err()  { printf "%s %b%s%b\n" "$(date '+%F %T')" "$RED" "$*" "$RESET" | tee -a "$LOG"; }

need_root() { if [[ $EUID -ne 0 ]]; then err "[ERRO] Execute como root (sudo)."; exit 1; fi; }
need_root

log "==== Fedora npm/dev setup ===="
log "Log em: $LOG"

# 0) Base do sistema
log "Instalando utilitários base..."
dnf install -y git curl wget unzip tar jq ripgrep fd-find @development-tools >>"$LOG" 2>&1 || true

# 1) Node.js stream (tenta 22; se não houver, usa padrão)
if dnf -y module list nodejs >>"$LOG" 2>&1; then
  log "Configurando stream do Node.js..."
  dnf -y module reset nodejs >>"$LOG" 2>&1 || true
  if dnf -y module enable nodejs:22 >>"$LOG" 2>&1; then
    ok "nodejs:22 habilitado."
  else
    warn "nodejs:22 indisponível nesta versão. Usando pacote padrão do Fedora."
  fi
fi

log "Instalando Node.js e npm..."
dnf install -y nodejs npm >>"$LOG" 2>&1 || { err "Falha instalando Node.js/npm."; exit 1; }

# 2) Linguagens e ferramentas
log "Instalando linguagens/ferramentas de desenvolvimento..."
dnf install -y \
  python3 python3-pip python3-pylsp python3-black \
  rust rust-analyzer \
  golang \
  php php-cli composer \
  deno \
  neovim >>"$LOG" 2>&1 || true

# 'deno' pode não existir em alguns releases
if ! command -v deno >/dev/null 2>&1; then
  warn "Pacote 'deno' não disponível nos repositórios atuais. Você pode instalar via script upstream se necessário."
fi

# 3) GOPATH e gopls
log "Instalando gopls (Go LSP) via 'go install'..."
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
export PATH="$PATH:$GOBIN"
sudo -u "${SUDO_USER:-$USER}" bash -lc 'export GOPATH="${GOPATH:-$HOME/go}"; export GOBIN="${GOBIN:-$GOPATH/bin}"; export PATH="$PATH:$GOBIN"; go install golang.org/x/tools/gopls@latest' >>"$LOG" 2>&1 || warn "Falha ao instalar gopls (verifique Go)."

# 4) npm global
log "Instalando pacotes npm globais úteis (LSPs/formatters)..."
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
NPM_RC=$?
set -e
if [[ $NPM_RC -ne 0 ]]; then
  warn "Alguns pacotes npm podem ter falhado. Veja o log: $LOG"
else
  ok "Pacotes npm globais instalados."
fi

ok "Concluído. Reinicie o terminal para garantir PATH atualizado (Go/bin)."
