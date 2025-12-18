#!/bin/bash
set -euo pipefail

# Autoconfig EXT4 mounts for dev and 1TB
# - Monta:  /mnt/dev  (LABEL=dev, ext4)
#           /mnt/1TB  (LABEL=1TB, ext4)
# - Idempotente, com backup/rollback do /etc/fstab
# - Automount via systemd (x-systemd.automount,nofail)
# - Requer: blkid, lsblk, findmnt, systemctl, mount

# --- helpers de log ---

log() {
  printf '[*] %s\n' "$*"
}

ok() {
  printf '[+] %s\n' "$*"
}

warn() {
  printf '[!] %s\n' "$*"
}

die() {
  printf '[X] %s\n' "$*" >&2
  exit 1
}

# --- checagens iniciais ---

if [[ $EUID -ne 0 ]]; then
  die "Execute como root (sudo)."
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Comando requerido não encontrado: $1"
  fi
}

require_cmd blkid
require_cmd lsblk
require_cmd findmnt
require_cmd systemctl
require_cmd mount

REAL_USER="${SUDO_USER:-$USER}"
REAL_UID="$(id -u "$REAL_USER")"
REAL_GID="$(id -g "$REAL_USER")"
HOME_DIR="$(getent passwd "$REAL_USER" | cut -d: -f6)"

# Labels e fallbacks
LABEL_DEV="${LABEL_DEV:-dev}"
LABEL_1TB="${LABEL_1TB:-1TB}"
DEV_DEV_CAND="${DEV_DEV_CAND:-/dev/sda1}"
DEV_1TB_CAND="${DEV_1TB_CAND:-/dev/sdb2}"

# Pontos de montagem (novo padrão: /mnt/*)
MP_DEV="/mnt/dev"
MP_1TB="/mnt/1TB"

# --- helpers de disco ---

dev_by_label() {
  blkid -t "LABEL=$1" -o device 2>/dev/null | head -n1 || true
}

uuid_of() {
  blkid -s UUID -o value "$1" 2>/dev/null || true
}

fstype_of() {
  lsblk -ndo FSTYPE "$1" 2>/dev/null || true
}

# --- localizar partições ---

# DEV (ext4)
DEV_DEV="$(dev_by_label "$LABEL_DEV")"
[[ -z "$DEV_DEV" ]] && DEV_DEV="$DEV_DEV_CAND"

[[ -b "$DEV_DEV" ]] || die "Partição 'dev' não encontrada (LABEL=${LABEL_DEV} ou ${DEV_DEV_CAND})."
[[ "$(fstype_of "$DEV_DEV")" == "ext4" ]] || die "Esperado ext4 em $DEV_DEV (LABEL=${LABEL_DEV})."

UUID_DEV="$(uuid_of "$DEV_DEV")"
[[ -n "$UUID_DEV" ]] || die "Não foi possível obter UUID de $DEV_DEV."

ok "ext4: $DEV_DEV (UUID=$UUID_DEV) → $MP_DEV"

# 1TB (ext4)
DEV_1TB="$(dev_by_label "$LABEL_1TB")"
[[ -z "$DEV_1TB" ]] && DEV_1TB="$DEV_1TB_CAND"

[[ -b "$DEV_1TB" ]] || die "Partição '1TB' não encontrada (LABEL=${LABEL_1TB} ou ${DEV_1TB_CAND})."
[[ "$(fstype_of "$DEV_1TB")" == "ext4" ]] || die "Esperado ext4 em $DEV_1TB (LABEL=${LABEL_1TB})."

UUID_1TB="$(uuid_of "$DEV_1TB")"
[[ -n "$UUID_1TB" ]] || die "Não foi possível obter UUID de $DEV_1TB."

ok "ext4: $DEV_1TB (UUID=$UUID_1TB) → $MP_1TB"

# --- preparar pontos de montagem ---

mkdir -p "$MP_DEV" "$MP_1TB"

# Encerrar automounts/monstagens anteriores (se existirem)
systemctl stop mnt-dev.automount mnt-dev.mount 2>/dev/null || true
systemctl stop mnt-1TB.automount mnt-1TB.mount 2>/dev/null || true

umount -l "$MP_DEV" 2>/dev/null || true
umount -l "$MP_1TB" 2>/dev/null || true

# --- construir linhas do fstab ---

EXT4_OPTS="defaults,noatime,x-systemd.automount,nofail"

FSTAB_LINE_DEV="UUID=${UUID_DEV} ${MP_DEV} ext4 ${EXT4_OPTS} 0 2"
FSTAB_LINE_1TB="UUID=${UUID_1TB} ${MP_1TB} ext4 ${EXT4_OPTS} 0 2"

FSTAB="/etc/fstab"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="/etc/fstab.bak-${TS}"
TMP="$(mktemp)"

cp -a "$FSTAB" "$BACKUP"
ok "Backup criado: $BACKUP"

# Remover entradas antigas dessas unidades/pontos
awk -v uuid1="$UUID_DEV" -v uuid2="$UUID_1TB" -v mp1="$MP_DEV" -v mp2="$MP_1TB" '
BEGIN { IGNORECASE = 1 }
{
  if ($0 ~ uuid1 || $0 ~ uuid2 || $2 == mp1 || $2 == mp2) next;
  print $0
}
' "$FSTAB" >"$TMP"

{
  echo ""
  echo "# >>> auto-added by autofs-arch-ext4 (${TS})"
  echo "$FSTAB_LINE_DEV"
  echo "$FSTAB_LINE_1TB"
  echo "# <<<"
} >>"$TMP"

# --- validar e aplicar novo fstab ---

if ! findmnt --verify -F "$TMP"; then
  mv -f "$BACKUP" "$FSTAB"
  rm -f "$TMP"
  die "findmnt --verify falhou; rollback do fstab aplicado."
fi

mv -f "$TMP" "$FSTAB"
systemctl daemon-reload

# --- montar tudo e testar ---

if ! mount -a; then
  warn "mount -a falhou; restaurando backup de $FSTAB."
  cp -af "$BACKUP" "$FSTAB"
  systemctl daemon-reload
  die "Erro ao montar partições; rollback aplicado."
fi

# Forçar criação de unidades automount lendo diretórios
ls "$MP_DEV" >/dev/null 2>&1 || true
ls "$MP_1TB" >/dev/null 2>&1 || true

# --- symlinks amigáveis no $HOME ---

ln -sfn "$MP_DEV" "$HOME_DIR/dev"
ln -sfn "$MP_1TB" "$HOME_DIR/1TB"
chown -h "$REAL_UID:$REAL_GID" "$HOME_DIR/dev" "$HOME_DIR/1TB"

ok "fstab atualizado (ext4/ext4). Automount pronto."
ok "Acesse via: ~/dev e ~/1TB."
