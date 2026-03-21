#!/usr/bin/env bash
# Fedora Btrfs snapshot setup (Snapper) + safety rails
# Usage: sudo ./fedora-setup-btrfs.sh
set -euo pipefail

LOG="/var/log/fedora-postinstall.log"
TS="$(date '+%Y-%m-%d %H:%M:%S')"
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; BLUE="\e[34m"; RESET="\e[0m"

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERRO] Este script precisa ser executado como root.${RESET}"
    exit 1
  fi
}

log() { echo -e "[$(date '+%F %T')] $*" | tee -a "$LOG"; }
info() { log "${BLUE}$*${RESET}"; }
ok()   { log "${GREEN}$*${RESET}"; }
warn() { log "${YELLOW}$*${RESET}"; }
err()  { log "${RED}$*${RESET}"; }

need_root

info "==== Fedora Btrfs Snapshot Setup (Snapper) ===="
info "Salvando logs em: $LOG"

# 0) pré-checagens
if ! command -v btrfs >/dev/null 2>&1; then
  warn "btrfs util não encontrado — instalando btrfs-progs..."
  dnf install -y btrfs-progs >>"$LOG" 2>&1 || true
fi

ROOT_FS_TYPE="$(findmnt -n -o FSTYPE / || true)"
if [[ "${ROOT_FS_TYPE:-unknown}" != "btrfs" ]]; then
  warn "Sistema de arquivos raiz não é Btrfs (${ROOT_FS_TYPE}). Snapper é opcional."
fi

# 1) instalar snapper e utilitários úteis
info "Instalando snapper e ferramentas relacionadas..."
dnf install -y snapper snapper-plugins rsync cronie cronie-anacron >>"$LOG" 2>&1 || {
  err "Falha ao instalar pacotes do snapper."; exit 1;
}

# 2) criar configuração do snapper se for Btrfs
if [[ "$ROOT_FS_TYPE" == "btrfs" ]]; then
  if [[ ! -e /etc/snapper/configs/root ]]; then
    info "Criando configuração do snapper para / (root)."
    snapper -c root create-config / >>"$LOG" 2>&1 || true
  else
    info "Configuração do snapper para root já existe."
  fi

  # Ajustes de timeline (1h) e retenções sensatas
  SNAPPERCONF="/etc/snapper/configs/root"
  if [[ -f "$SNAPPERCONF" ]]; then
    info "Ajustando política de retenção..."
    sed -i 's/^TIMELINE_CREATE=.*$/TIMELINE_CREATE="yes"/' "$SNAPPERCONF"
    sed -i 's/^TIMELINE_MIN_AGE=.*$/TIMELINE_MIN_AGE="1800"/' "$SNAPPERCONF"
    sed -i 's/^TIMELINE_LIMIT_HOURLY=.*$/TIMELINE_LIMIT_HOURLY="8"/' "$SNAPPERCONF"
    sed -i 's/^TIMELINE_LIMIT_DAILY=.*$/TIMELINE_LIMIT_DAILY="7"/' "$SNAPPERCONF"
    sed -i 's/^TIMELINE_LIMIT_WEEKLY=.*$/TIMELINE_LIMIT_WEEKLY="4"/' "$SNAPPERCONF"
    sed -i 's/^TIMELINE_LIMIT_MONTHLY=.*$/TIMELINE_LIMIT_MONTHLY="3"/' "$SNAPPERCONF"
    sed -i 's/^TIMELINE_LIMIT_YEARLY=.*$/TIMELINE_LIMIT_YEARLY="0"/' "$SNAPPERCONF"
  fi

  # habilitar timers do snapper
  info "Habilitando timers do snapper (timeline e cleanup)..."
  systemctl enable --now snapper-timeline.timer >>"$LOG" 2>&1 || true
  systemctl enable --now snapper-cleanup.timer >>"$LOG" 2>&1 || true

  # criar um snapshot inicial
  info "Criando snapshot inicial de baseline..."
  snapper -c root create -t single -d "Baseline pós-setup @ $(date '+%F %T')" >>"$LOG" 2>&1 || true

  ok "Snapper configurado com sucesso em Btrfs."
else
  warn "Pular configuração do snapper: raiz não é Btrfs."
fi

ok "Concluído."
