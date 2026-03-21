#!/usr/bin/env bash
# Fedora Post-Install for KDE: packages, dev tools, Flatpak, KDE extras
# Usage: sudo ./fedora-post-install.sh
set -euo pipefail

LOG="/var/log/fedora-postinstall.log"
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; BLUE="\e[34m"; RESET="\e[0m"
need_root() { if [[ $EUID -ne 0 ]]; then echo -e "${RED}[ERRO] Execute como root.${RESET}"; exit 1; fi; }
log()  { echo -e "[$(date '+%F %T')] $*" | tee -a "$LOG"; }
info() { log "${BLUE}$*${RESET}"; }
ok()   { log "${GREEN}$*${RESET}"; }
warn() { log "${YELLOW}$*${RESET}"; }
err()  { log "${RED}$*${RESET}"; }

need_root
info "==== Fedora Post-Install (KDE) ===="
info "Logs: $LOG"

# 0) base do KDE (se ainda não estiver completa)
info "Instalando ambiente KDE Plasma e utilitários essenciais..."
dnf -y group install @kde-desktop-environment >>"$LOG" 2>&1 || warn "Grupo KDE já pode estar instalado."

# 1) utilitários e dev tools
info "Instalando utilitários e ferramentas de desenvolvimento..."
dnf install -y \
  git curl wget unzip tar jq fzf ripgrep fd-find \
  htop btop ncdu neofetch fastfetch \
  gcc gcc-c++ make cmake ninja-build pkgconf \
  python3 python3-pip python3-virtualenv \
  nodejs npm \
  golang \
  rust cargo \
  php php-cli composer \
  shellcheck shfmt \
  neovim tmux zsh fish \
  flatpak fwupd \
  kooha \
  >>"$LOG" 2>&1 || err "Falha instalando pacotes principais."

# 1.1) Node.js stream (opcional: garantir stream moderna)
if dnf module list nodejs -y >>"$LOG" 2>&1; then
  info "Configurando stream do Node.js (22, se disponível)..."
  dnf -y module reset nodejs >>"$LOG" 2>&1 || true
  dnf -y module enable nodejs:22 >>"$LOG" 2>&1 || warn "Stream nodejs:22 pode não estar disponível nesta versão do Fedora."
  dnf -y install nodejs npm >>"$LOG" 2>&1 || true
fi

# 2) Flatpak + Flathub
info "Configurando Flatpak/Flathub..."
if ! command -v flatpak >/dev/null 2>&1; then
  dnf install -y flatpak >>"$LOG" 2>&1
fi
if ! flatpak remote-list | grep -q flathub; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >>"$LOG" 2>&1 || true
fi
flatpak update -y >>"$LOG" 2>&1 || true

# 3) Firmware updates
info "Verificando atualizações de firmware (fwupdmgr)..."
fwupdmgr refresh -y >>"$LOG" 2>&1 || true
fwupdmgr get-updates >>"$LOG" 2>&1 || true

# 4) KDE extra goodies (utilitários gráficos úteis)
info "Instalando utilitários KDE..."
dnf install -y \
  kde-partitionmanager kcolorchooser kdialog \
  konsole kate spectacle \
  plasma-discover plasma-discover-backend-flatpak \
  >>"$LOG" 2>&1 || true

# 5) linguagens/lsp básicos (Python/JS/TS/Go)
info "Instalando ferramentas LSP de linguagem via dnf/pip/npm (mínimo viável)..."
pip3 install --break-system-packages -U pip pynvim black ruff pylsp >>"$LOG" 2>&1 || true
npm -g install typescript typescript-language-server pyright eslint vscode-langservers-extracted >>"$LOG" 2>&1 || true
go install golang.org/x/tools/gopls@latest >>"$LOG" 2>&1 || true

# 6) shell padrão (opcional: zsh)
if command -v zsh >/dev/null 2>&1; then
  info "Definindo /bin/zsh como shell padrão para o usuário atual..."
  USERNAME_REAL="${SUDO_USER:-$USER}"
  chsh -s /bin/zsh "$USERNAME_REAL" >>"$LOG" 2>&1 || warn "Não foi possível definir zsh como shell padrão."
fi

ok "Pós-instalação concluída."
