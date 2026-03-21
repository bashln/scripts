#!/usr/bin/env bash
# Fedora cleaner: autoremove, cache and logs cleanup
# Usage: sudo ./fedora-clean.sh
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
info "==== Limpeza de pacotes, cache e logs ===="

info "DNF autoremove..."
dnf autoremove -y >>"$LOG" 2>&1 || true

info "DNF clean all..."
dnf clean all >>"$LOG" 2>&1 || true

info "Journal: manter apenas últimos 14 dias..."
journalctl --vacuum-time=14d >>"$LOG" 2>&1 || true

ok "Limpeza concluída."
