#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Converted: 2025-10-17
# Notes: automated conversion from apt/apt-get to dnf. 
#        Verify any external repositories (PPAs) manually on Fedora.

set -euo pipefail

# Este script prepara subvolumes Btrfs (Ubuntu-compatible). Requer execução como root.
if [[ $EUID -ne 0 ]]; then
  echo "Erro: execute como root (sudo)." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 /dev/<DISCO>   (ex: /dev/nvme0n1)" >&2
  exit 1
fi

DISK="$1"

echo "⚙️  Preparando tabela de partições em: $DISK"
partprobe "$DISK" || true

# Exemplo: cria layout padrão (EFI + raiz Btrfs). Ajuste conforme seu caso.
# ATENÇÃO: este é um exemplo e pode APAGAR dados existentes.
read -rp "Isso pode apagar dados. Digite 'SIM' para continuar: " OK
if [[ "$OK" != "SIM" ]]; then
  echo "Abortado."
  exit 1
fi

# Exemplo mínimo:
#  - partição 1: EFI (512MiB)
#  - partição 2: Btrfs (restante)
sgdisk -Z "$DISK"
sgdisk -n1:0:+512MiB -t1:ef00 -c1:"EFI System" "$DISK"
sgdisk -n2:0:0       -t2:8300 -c2:"Linux btrfs" "$DISK"
partprobe "$DISK"

EFI="${DISK}p1"
ROOT="${DISK}p2"

mkfs.vfat -F32 -n EFI "$EFI"
mkfs.btrfs -f -L ROOT "$ROOT"

mkdir -p /mnt
mount "$ROOT" /mnt

# Subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots

umount /mnt

# Montagens com subvolumes
mount -o subvol=@,compress=zstd,noatime "$ROOT" /mnt
mkdir -p /mnt/{home,boot/efi,var/log,var/cache,.snapshots}
mount -o subvol=@home,compress=zstd,noatime "$ROOT" /mnt/home
mount -o subvol=@log,compress=zstd,noatime  "$ROOT" /mnt/var/log
mount -o subvol=@cache,compress=zstd,noatime "$ROOT" /mnt/var/cache
mount -o subvol=@snapshots,compress=zstd,noatime "$ROOT" /mnt/.snapshots

mkdir -p /mnt/boot/efi
mount "$EFI" /mnt/boot/efi

echo "---"
echo "Subvolumes criados e montados."
echo "Agora prossiga com a instalação do Ubuntu dentro de /mnt."
