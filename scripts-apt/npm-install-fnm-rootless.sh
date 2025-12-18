#!/usr/bin/env bash
# =============================================================================
# Autor: leonamsh (Leonam Monteiro)
# Script: npm-install-fnm-rootless.sh
# Descrição: Setup full-stack ROOTLESS no Ubuntu/Pop!_OS
#            - APT apenas para sistema
#            - Node via fnm
#            - npm global em ~/.local
# =============================================================================

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

LOG_FILE="${LOG_FILE:-$HOME/npm-install-fnm-rootless.log}"
: > "$LOG_FILE"
log() { printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"; }

ok=(); missing=(); failed=()

_install_pkg() {
  local pkg="$1"
  log "→ Instalando: $pkg"
  set +e
  local out
  out="$(sudo -E apt-get -o Dpkg::Use-Pty=0 install -y "$pkg" 2>&1)"
  local rc=$?
  set -e
  printf "%s\n" "$out" >> "$LOG_FILE"

  if [[ $rc -eq 0 ]]; then
    ok+=("$pkg"); log "✅ Sucesso: $pkg"; return 0
  fi

  if grep -qiE "(unable to locate package|not found|Não foi possível localizar|inexistente)" <<< "$out"; then
    missing+=("$pkg"); log "⚠️  Inexistente no APT: $pkg"
  else
    failed+=("$pkg"); log "❌ Falhou: $pkg (rc=$rc)"
  fi
}

install_list() {
  for p in "$@"; do _install_pkg "$p"; done
}

summary() {
  echo
  log "===== RESUMO APT ====="
  printf "   ✅ Instalados: %s\n" "${#ok[@]}"; ((${#ok[@]})) && printf '      - %s\n' "${ok[@]}"
  printf "   ⚠️  Inexistentes: %s\n" "${#missing[@]}"; ((${#missing[@]})) && printf '      - %s\n' "${missing[@]}"
  printf "   ❌ Falhas: %s\n" "${#failed[@]}"; ((${#failed[@]})) && printf '      - %s\n' "${failed[@]}"
}

log "====== Início: fnm-first / rootless ======"

# -----------------------------------------------------------------------------
# APT – somente o essencial de sistema
# -----------------------------------------------------------------------------
install_list \
  curl ca-certificates unzip \
  git \
  python3 python3-pip python3-venv \
  rustc cargo \
  golang-go gopls \
  php composer

# -----------------------------------------------------------------------------
# fnm (Fast Node Manager)
# -----------------------------------------------------------------------------
if ! command -v fnm >/dev/null 2>&1; then
  log "[fnm] Instalando fnm (rootless)"
  curl -fsSL https://fnm.vercel.app/install | bash
else
  log "[fnm] fnm já instalado"
fi

# shellcheck disable=SC1090
export FNM_PATH="$HOME/.local/share/fnm"
export PATH="$FNM_PATH:$PATH"
eval "$(fnm env)"

# -----------------------------------------------------------------------------
# Node.js via fnm
# -----------------------------------------------------------------------------
NODE_VERSION="lts/*"

if ! fnm list | grep -q "lts"; then
  log "[Node] Instalando Node (LTS)"
  fnm install --lts
fi

fnm default "$NODE_VERSION"
fnm use "$NODE_VERSION"

log "[Node] $(node -v)"
log "[npm]  $(npm -v)"

# -----------------------------------------------------------------------------
# npm ROOTLESS (prefix em ~/.local)
# -----------------------------------------------------------------------------
log "[npm] Configurando prefix rootless (~/.local)"
npm config set prefix "$HOME/.local"

export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# npm global – LSPs e ferramentas
# -----------------------------------------------------------------------------
log "====== npm globais (rootless) ======"

npm install -g \
  typescript \
  typescript-language-server \
  eslint_d \
  prettier \
  @vue/language-server \
  @angular/language-service \
  vscode-json-languageserver \
  yaml-language-server \
  dockerfile-language-server-nodejs \
  pyright \
  bash-language-server \
  vscode-langservers-extracted \
  2>&1 | tee -a "$LOG_FILE"

# -----------------------------------------------------------------------------
# Diagnóstico final
# -----------------------------------------------------------------------------
log "====== Diagnóstico ======"
log "node: $(command -v node)"
log "npm:  $(command -v npm)"
log "tsc:  $(command -v tsc)"
log "pyright: $(command -v pyright)"
log "gopls: $(command -v gopls)"
log "rust-analyzer: $(command -v rust-analyzer)"

summary
log "====== Fim: fnm-first / rootless ======"

