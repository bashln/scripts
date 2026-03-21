#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Converted: 2025-10-17
# Notes: automated conversion from apt/apt-get to dnf. 
#        Verify any external repositories (PPAs) manually on Fedora.

set -euo pipefail

# ===== Automount EXT4 + EXT4 (Ubuntu-compatible) =====
# - Monta:  /mnt/dev  (LABEL=dev, ext4)
#           /mnt/1TB  (LABEL=1TB, ext4)
# - Idempotente, com backup/rollback do /etc/fstab
# - Automount via systemd (x-systemd.automount,nofail,x-gvfs-hide)
# ========================================

die(){ echo "❌ $*" >&2; exit 1; }
ok(){ echo "✅ $*"; }
warn(){ echo "⚠️  $*"; }
info(){ echo "▶ $*"; }

[[ $EUID -eq 0 ]] || die "Execute como root (sudo)."

REAL_USER="${SUDO_USER:-$USER}"
REAL_UID="$(id -u "$REAL_USER")"
REAL_GID="$(id -g "$REAL_USER")"
HOME_DIR="$(eval echo "~$REAL_USER")"

LABEL_DEV="dev"
LABEL_1TB="1TB"

MP_DEV="/mnt/dev"
MP_1TB="/mnt/1TB"

dev_by_label(){ blkid -o export | awk -v L="$1" '
  $0 ~ "^LABEL="L"$" {found=1}
  found && /^DEVNAME=/ {print $0; exit}
  /^$/ {found=0}
' | cut -d= -f2; }

fstype_of(){ blkid -o value -s TYPE "$1" 2>/dev/null || true; }
uuid_of(){ blkid -o value -s UUID "$1" 2>/dev/null || true; }

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.autofs.$(date +%Y%m%d-%H%M%S)"
cp -af "$FSTAB" "$BACKUP"
ok "Backup criado em: $BACKUP"

# Encontrar DEV (ext4)
DEV_DEV="$(dev_by_label "$LABEL_DEV")"
[[ -b "$DEV_DEV" ]] || die "Partição 'dev' (LABEL=${LABEL_DEV}) não encontrada."
[[ "$(fstype_of "$DEV_DEV")" == "ext4" ]] || die "Esperava ext4 em $DEV_DEV."
UUID_DEV="$(uuid_of "$DEV_DEV")"
[[ -n "$UUID_DEV" ]] || die "Sem UUID para $DEV_DEV."
ok "ext4: $DEV_DEV (UUID=$UUID_DEV) → $MP_DEV"

# Encontrar 1TB (ext4)
DEV_1TB="$(dev_by_label "$LABEL_1TB")"
[[ -b "$DEV_1TB" ]] || die "Partição '1TB' (LABEL=${LABEL_1TB}) não encontrada."
[[ "$(fstype_of "$DEV_1TB")" == "ext4" ]] || die "Esperava ext4 em $DEV_1TB."
UUID_1TB="$(uuid_of "$DEV_1TB")"
[[ -n "$UUID_1TB" ]] || die "Sem UUID para $DEV_1TB."
ok "ext4: $DEV_1TB (UUID=$UUID_1TB) → $MP_1TB"

mkdir -p "$MP_DEV" "$MP_1TB"

# Remover entradas antigas duplicadas
tmp="$(mktemp)"
awk 'BEGIN{IGNORECASE=1}
     !($0 ~ /UUID=.*\s+\/mnt\/dev\s+/ || $0 ~ /UUID=.*\s+\/mnt\/1TB\s+/){print}' "$FSTAB" > "$tmp"
cat "$tmp" > "$FSTAB"
rm -f "$tmp"

# Adicionar linhas novas (Ubuntu usa systemd por padrão)
add_line(){
  local UUID="$1" MP="$2"
  local OPTS="noatime,compress-force=zstd:1,space_cache=v2"
  # Para ext4 mantenha opts básicos + automount
  OPTS="noatime,x-systemd.automount,nofail,x-gvfs-hide"
  echo "UUID=${UUID}  ${MP}  ext4  ${OPTS}  0  2" >> "$FSTAB"
}

add_line "$UUID_DEV" "$MP_DEV"
add_line "$UUID_1TB" "$MP_1TB"

systemctl daemon-reload
# Garantir diretórios vazios (não falha se já montados)
mount -a || {
  cp -af "$BACKUP" "$FSTAB"
  systemctl daemon-reload
  die "mount -a falhou; rollback aplicado."
}

# Symlinks amigáveis para o usuário real
ln -sfn "$MP_DEV" "$HOME_DIR/dev"
ln -sfn "$MP_1TB" "$HOME_DIR/1TB"
chown -h "$REAL_UID:$REAL_GID" "$HOME_DIR/dev" "$HOME_DIR/1TB"

ok "fstab atualizado (ext4/ext4). Automount pronto. Acesse ~/dev e ~/1TB."
