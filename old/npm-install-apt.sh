#!/usr/bin/env bash
# =============================================================================
# Autor: leonamsh (Leonam Monteiro)
# Script: npm-install-apt.sh
# Descrição: Instala ferramentas para desenvolvimento full-stack no Ubuntu/Pop!_OS
#            usando APT (um por um) e npm global.
# =============================================================================
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

LOG_FILE="${LOG_FILE:-$HOME/npm-install-apt.log}"
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

  if grep -qiE "(unable to locate package|package .* not found|no packages found|Não foi possível localizar o pacote|pacote .* não|inexistente)" <<< "$out"; then
    missing+=("$pkg"); log "⚠️  Inexistente no APT: $pkg"
  else
    failed+=("$pkg"); log "❌ Falhou: $pkg (rc=$rc)"
  fi
}

install_list() {
  local pkgs=("$@")
  for p in "${pkgs[@]}"; do _install_pkg "$p"; done
}

summary() {
  echo; log "===== RESUMO APT ====="
  printf "   ✅ Instalados: %s\n" "${#ok[@]}"; ((${#ok[@]})) && printf '      - %s\n' "${ok[@]}"
  printf "   ⚠️  Inexistentes: %s\n" "${#missing[@]}"; ((${#missing[@]})) && printf '      - %s\n' "${missing[@]}"
  printf "   ❌ Falhas: %s\n" "${#failed[@]}"; ((${#failed[@]})) && printf '      - %s\n' "${failed[@]}"
}

log "====== Início: npm-install-apt ======"

# Ajustes do APT
sudo tee /etc/apt/apt.conf.d/99custom-noninteractive >/dev/null <<'EOF'
APT::Get::Assume-Yes "true";
APT::Color "0";
Dpkg::Use-Pty "0";
Acquire::Retries "3";
EOF

# Universe/Multiverse (muitos pacotes moram aqui)
set +e
sudo add-apt-repository -y universe    >/dev/null 2>&1
sudo add-apt-repository -y multiverse  >/dev/null 2>&1
set -e

log "[APT] update && upgrade"
sudo apt-get update -y
sudo apt-get upgrade -y

# -----------------------------------------------------------------------------
# Node.js + npm (repositório oficial Ubuntu) — instala um por um
# -----------------------------------------------------------------------------
install_list nodejs npm

# -----------------------------------------------------------------------------
# Ferramentas de linguagem e runtimes (APT) — um por um
# -----------------------------------------------------------------------------
install_list \
  python3 python3-pip \
  rustc cargo rust-analyzer \
  golang-go \
  deno \
  php composer \
  python3-pylsp python3-black \
  gopls

# -----------------------------------------------------------------------------
# NPM global — Language Servers e ferramentas (equivalentes ao script Arch)
# -----------------------------------------------------------------------------
log "====== NPM globais: LSPs e ferramentas ======"
# Dica: se preferir rootless, exporte npm prefix para $HOME/.local antes e use sem sudo.
# Aqui mantemos compatível com seu script original (sudo -g).
set +e
sudo npm install -g \
  typescript typescript-language-server \
  eslint_d \
  prettier \
  @vue/language-server \
  @angular/language-service \
  vscode-json-languageserver \
  yaml-language-server \
  dockerfile-language-server-nodejs \
  pyright 2>&1 | tee -a "$LOG_FILE"
set -e

summary
log "====== Fim: npm-install-apt ======"
