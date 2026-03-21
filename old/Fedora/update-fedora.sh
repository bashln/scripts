#!/usr/bin/env bash
# Fedora updater: dnf, flatpak, fwupd, with logs and summary
# Usage: sudo ./fedora-update.sh
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
START=$(date +%s)
info "==== Atualização do sistema (DNF/Flatpak/Firmware) ===="

info "DNF: refresh + upgrade..."
dnf upgrade --refresh -y >>"$LOG" 2>&1 || err "Falha no dnf upgrade"

info "Flatpak: update..."
flatpak update -y >>"$LOG" 2>&1 || warn "Falha no flatpak update"

info "Firmware (fwupdmgr)..."
fwupdmgr refresh -y >>"$LOG" 2>&1 || true
fwupdmgr get-updates >>"$LOG" 2>&1 || true

END=$(date +%s)
ok "Atualização concluída em $((END-START))s."
