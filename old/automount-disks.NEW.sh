#!/usr/bin/env bash
# automount-disks.sh — adiciona entradas ao /etc/fstab e monta os discos informados
# - Suporta Ubuntu/Debian, Fedora e Arch (para instalar ntfs-3g se precisar)
# - Idempotente: não duplica entradas já existentes
# - Monta imediatamente após configurar
set -euo pipefail

UUID_NTFS="7A608AB7608A79A1"   # /dev/sdb2  (LABEL="1TB", TYPE=ntfs)
UUID_EXT4="a47593ca-7de6-4ea6-8a7d-5501b0db5ba4"  # /dev/sda1 (LABEL="dev", TYPE=ext4)

MOUNT_NTFS="/mnt/1TB"
MOUNT_EXT4="/mnt/dev"

# Dono padrão para a partição NTFS (controle de permissões via mount options)
TARGET_USER="${SUDO_USER:-${USER}}"
TARGET_UID="$(id -u "${TARGET_USER}")"
TARGET_GID="$(id -g "${TARGET_USER}")"

log()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" 1>&2; }

need_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    err "Este script precisa ser executado como root (use sudo)."
    exit 1
  fi
}

detect_distro() {
  if command -v apt-get >/dev/null 2>&1; then
    DISTRO="debian"
  elif command -v dnf >/dev/null 2>&1; then
    DISTRO="fedora"
  elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
  else
    DISTRO="unknown"
  fi
}

ensure_ntfs3g() {
  if ! lsmod | grep -q "^ntfs3\>" && ! command -v mount.ntfs >/dev/null 2>&1 && ! command -v mount.ntfs-3g >/dev/null 2>&1; then
    # Tenta instalar ntfs-3g
    case "$DISTRO" in
      debian) apt-get update && apt-get -y install ntfs-3g ;;
      fedora) dnf -y install ntfs-3g ;;
      arch)   pacman -Syu --noconfirm && pacman -S --noconfirm ntfs-3g ;;
      *)      warn "Não consegui detectar distro p/ instalar ntfs-3g; prosseguindo assim mesmo." ;;
    esac
  fi
}

backup_fstab() {
  cp -a /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d-%H%M%S)"
}

ensure_dir() {
  local d="$1"
  mkdir -p "$d"
}

fstab_has_uuid() {
  local uuid="$1"
  grep -Eqs "^[[:space:]]*UUID=${uuid}[[:space:]]" /etc/fstab
}

append_fstab_entry() {
  local line="$1"
  echo "$line" >> /etc/fstab
}

add_or_update_entries() {
  local ntfs_opts="uid=${TARGET_UID},gid=${TARGET_GID},umask=0022,windows_names,big_writes,auto,nofail,x-systemd.device-timeout=10"
  local ext4_opts="defaults,noatime,nofail,x-systemd.device-timeout=10"

  local ntfs_line="UUID=${UUID_NTFS} ${MOUNT_NTFS} ntfs-3g ${ntfs_opts} 0 0"
  local ext4_line="UUID=${UUID_EXT4} ${MOUNT_EXT4} ext4 ${ext4_opts} 0 2"

  # NTFS
  if fstab_has_uuid "${UUID_NTFS}"; then
    warn "Entrada NTFS (UUID=${UUID_NTFS}) já existe no /etc/fstab — não vou duplicar."
  else
    append_fstab_entry "${ntfs_line}"
    log "Adicionada entrada NTFS ao /etc/fstab: ${ntfs_line}"
  fi

  # EXT4
  if fstab_has_uuid "${UUID_EXT4}"; then
    warn "Entrada EXT4 (UUID=${UUID_EXT4}) já existe no /etc/fstab — não vou duplicar."
  else
    append_fstab_entry "${ext4_line}"
    log "Adicionada entrada EXT4 ao /etc/fstab: ${ext4_line}"
  fi
}

mount_all() {
  log "Montando pontos..."
  ensure_dir "${MOUNT_NTFS}"
  ensure_dir "${MOUNT_EXT4}"

  # Tenta montar individualmente para mensagens mais claras
  mount "${MOUNT_NTFS}" || { warn "Falha ao montar ${MOUNT_NTFS}, tentando mount -a..."; true; }
  mount "${MOUNT_EXT4}" || { warn "Falha ao montar ${MOUNT_EXT4}, tentando mount -a..."; true; }

  # Garante tudo
  mount -a

  log "Status atual:"
  lsblk -f | sed -n '1,200p'
  echo
  findmnt -no TARGET,UUID,SOURCE,FSTYPE,OPTIONS "${MOUNT_NTFS}" || true
  findmnt -no TARGET,UUID,SOURCE,FSTYPE,OPTIONS "${MOUNT_EXT4}" || true
}

main() {
  need_root
  detect_distro
  ensure_dir "${MOUNT_NTFS}"
  ensure_dir "${MOUNT_EXT4}"
  ensure_ntfs3g
  backup_fstab
  add_or_update_entries
  mount_all
  log "Concluído."
}

main "$@"
