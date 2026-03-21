#!/usr/bin/env bash
set -euo pipefail

# ===== Autofs Arch v3 (EXT4 + EXT4) =====
# - Monta:  /mnt/dev  (LABEL=dev, ext4)
#           /mnt/1TB  (LABEL=1TB, ext4)
# - Idempotente, com backup/rollback do /etc/fstab
# - Automount via systemd (x-systemd.automount,nofail,x-gvfs-hide)
# ========================================

die() {
  echo "❌ $*" >&2
  exit 1
}
ok() { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
info() { echo "▶ $*"; }

[[ $EUID -eq 0 ]] || die "Execute como root (sudo)."

REAL_USER="${SUDO_USER:-$USER}"
REAL_UID="$(id -u "$REAL_USER")"
REAL_GID="$(id -g "$REAL_USER")"
HOME_DIR="$(getent passwd "$REAL_USER" | cut -d: -f6)"

# Labels e fallbacks
LABEL_DEV="${LABEL_DEV:-dev}"
LABEL_1TB="${LABEL_1TB:-1TB}"
DEV_DEV_CAND="${DEV_DEV_CAND:-/dev/sda1}"
DEV_1TB_CAND="${DEV_1TB_CAND:-/dev/sdb2}"

MP_DEV="/run/media/lm/dev"
MP_1TB="/run/media/lm/1TB"

# Helpers
dev_by_label() { blkid -t "LABEL=$1" -o device 2>/dev/null | head -n1 || true; }
uuid_of() { blkid -s UUID -o value "$1" 2>/dev/null || true; }
fstype_of() { lsblk -ndo FSTYPE "$1" 2>/dev/null || true; }

# Encontrar DEV (ext4)
DEV_DEV="$(dev_by_label "$LABEL_DEV")"
[[ -z "$DEV_DEV" ]] && DEV_DEV="$DEV_DEV_CAND"
[[ -b "$DEV_DEV" ]] || die "Partição 'dev' não encontrada (label ${LABEL_DEV} ou $DEV_DEV_CAND)."
[[ "$(fstype_of "$DEV_DEV")" == "ext4" ]] || die "Esperava ext4 em $DEV_DEV (LABEL=${LABEL_DEV})."
UUID_DEV="$(uuid_of "$DEV_DEV")"
[[ -n "$UUID_DEV" ]] || die "Sem UUID para $DEV_DEV."
ok "ext4: $DEV_DEV (UUID=$UUID_DEV) → $MP_DEV"

# Encontrar 1TB (ext4)
DEV_1TB="$(dev_by_label "$LABEL_1TB")"
[[ -z "$DEV_1TB" ]] && DEV_1TB="$DEV_1TB_CAND"
[[ -b "$DEV_1TB" ]] || die "Partição '1TB' não encontrada (label ${LABEL_1TB} ou $DEV_1TB_CAND)."
[[ "$(fstype_of "$DEV_1TB")" == "ext4" ]] || die "Esperava ext4 em $DEV_1TB (LABEL=${LABEL_1TB})."
UUID_1TB="$(uuid_of "$DEV_1TB")"
[[ -n "$UUID_1TB" ]] || die "Sem UUID para $DEV_1TB."
ok "ext4: $DEV_1TB (UUID=$UUID_1TB) → $MP_1TB"

# Preparar pontos
mkdir -p "$MP_DEV" "$MP_1TB"

# Encerrar automounts/monstagens anteriores (se houver)
systemctl stop mnt-dev.automount mnt-dev.mount 2>/dev/null || true
systemctl stop mnt-1TB.automount mnt-1TB.mount 2>/dev/null || true
umount -l "/run/media/$REAL_USER/$LABEL_1TB" 2>/dev/null || true
umount -l "/run/media/$REAL_USER/$LABEL_DEV" 2>/dev/null || true
umount -l "$MP_DEV" 2>/dev/null || true
umount -l "$MP_1TB" 2>/dev/null || true

# Opções fstab (iguais para os dois, ext4 nativo lida com permissões)
EXT4_OPTS="defaults,noatime,x-systemd.automount,nofail"

FSTAB_LINE_DEV="UUID=${UUID_DEV} ${MP_DEV} ext4 ${EXT4_OPTS} 0 2"
FSTAB_LINE_1TB="UUID=${UUID_1TB} ${MP_1TB} ext4 ${EXT4_OPTS} 0 2"

# Editar /etc/fstab com backup e limpeza de entradas antigas
FSTAB="/etc/fstab"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="/etc/fstab.bak-${TS}"
TMP="$(mktemp)"
cp -a "$FSTAB" "$BACKUP"
ok "Backup: $BACKUP"

awk -v uuid1="$UUID_DEV" -v uuid2="$UUID_1TB" -v mp1="$MP_DEV" -v mp2="$MP_1TB" '
BEGIN{IGNORECASE=1}
{
  if ($0 ~ uuid1 || $0 ~ uuid2 || $2 == mp1 || $2 == mp2) next;
  print $0
}
END{}' "$FSTAB" >"$TMP"

{
  echo ""
  echo "# >>> auto-added by autofs-arch-ext4 (${TS})"
  echo "$FSTAB_LINE_DEV"
  echo "$FSTAB_LINE_1TB"
  echo "# <<<"
} >>"$TMP"

# Validar e aplicar
if ! findmnt --verify -F "$TMP"; then
  mv -f "$BACKUP" "$FSTAB"
  rm -f "$TMP"
  die "findmnt --verify falhou; rollback aplicado."
fi
mv -f "$TMP" "$FSTAB"
systemctl daemon-reload

# Montar e disparar automount
mount -a || {
  cp -af "$BACKUP" "$FSTAB"
  systemctl daemon-reload
  die "mount -a falhou; rollback aplicado."
}
ls "$MP_DEV" >/dev/null 2>&1 || true
ls "$MP_1TB" >/dev/null 2>&1 || true

# Symlinks amigáveis
#ln -sfn "$MP_DEV" "$HOME_DIR/dev"
#ln -sfn "$MP_1TB" "$HOME_DIR/1TB"
#chown -h "$REAL_UID:$REAL_GID" "$HOME_DIR/dev" "$HOME_DIR/1TB"

ok "fstab atualizado (ext4/ext4). Automount pronto. Acesse ~/dev e ~/1TB."







