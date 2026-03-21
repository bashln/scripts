#!/bin/bash

# --- Configuração Inicial ---
# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Erro: Este script deve ser executado como root." >&2
  exit 1
fi

# Verifica se o argumento do disco foi fornecido
if [ -z "$1" ]; then
  echo "Uso: $0 <disco>" >&2
  echo "Exemplo: $0 /dev/nvme0n1" >&2
  exit 1
fi

# Define a variável para o disco
NVME_DISK="$1"

# Verifica se o disco existe
if [ ! -b "$NVME_DISK" ]; then
  echo "Erro: O disco $NVME_DISK não existe ou não é um dispositivo de bloco." >&2
  exit 1
fi

# --- Aviso de Segurança e Confirmação ---
echo "---"
echo "AVISO: TODOS OS DADOS EM ${NVME_DISK} SERÃO APAGADOS!"
echo "---"
read -p "Deseja continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[sS]$ ]]; then
    echo "Operação cancelada."
    exit 1
fi
echo "Iniciando a configuração do disco..."

# --- 1. Particionamento (GPT) ---
echo "1. Criando tabela de partições GPT e apagando dados anteriores..."
# Apaga todas as partições existentes no disco
if ! sgdisk --zap-all "$NVME_DISK"; then
  echo "Erro ao apagar partições existentes." >&2
  exit 1
fi

# Cria a partição EFI (1 GiB)
if ! sgdisk -n 1:0:+1G -t 1:ef00 "$NVME_DISK"; then
  echo "Erro ao criar partição EFI." >&2
  exit 1
fi

# Cria a partição Btrfs (com o restante do disco)
if ! sgdisk -n 2:0:0 -t 2:8300 "$NVME_DISK"; then
  echo "Erro ao criar partição Btrfs." >&2
  exit 1
fi

# --- 2. Formatação das Partições ---
echo "2. Formatando as partições..."
# Partição EFI (FAT32)
if ! mkfs.vfat -F32 "${NVME_DISK}p1"; then
  echo "Erro ao formatar partição EFI." >&2
  exit 1
fi

# Partição Btrfs (com compressão zstd)
if ! mkfs.btrfs -f -O big_metadata "${NVME_DISK}p2"; then
  echo "Erro ao formatar partição Btrfs." >&2
  exit 1
fi

# --- 3. Criação de Subvolumes Btrfs ---
echo "3. Criando subvolumes Btrfs..."
# Monta a partição Btrfs temporariamente
if ! mount "${NVME_DISK}p2" /mnt; then
  echo "Erro ao montar partição Btrfs." >&2
  exit 1
fi

# Criação dos subvolumes
for subvol in @root @home @log @spool @cache @tmp @gdm @libvirt @opt; do
  if ! btrfs subvolume create "/mnt/$subvol"; then
    echo "Erro ao criar subvolume $subvol." >&2
    exit 1
  fi
done

# Desmonta a partição para remontagem com as opções corretas
if ! umount /mnt; then
  echo "Erro ao desmontar partição Btrfs." >&2
  exit 1
fi

# --- 4. Montagem dos Subvolumes ---
echo "4. Montando os subvolumes..."
# Monta o subvolume principal (@root)
if ! mount -o subvol=@root,compress=zstd "${NVME_DISK}p2" /mnt; then
  echo "Erro ao montar subvolume @root." >&2
  exit 1
fi

# Cria os diretórios para os subvolumes e os monta
declare -A subvol_mounts=(
  ["@home"]="/mnt/home"
  ["@opt"]="/mnt/opt"
  ["@log"]="/mnt/var/log"
  ["@spool"]="/mnt/var/spool"
  ["@cache"]="/mnt/var/cache"
  ["@tmp"]="/mnt/var/tmp"
  ["@gdm"]="/mnt/var/lib/gdm"
  ["@libvirt"]="/mnt/var/lib/libvirt"
)

for subvol in "${!subvol_mounts[@]}"; do
  mkdir -p "${subvol_mounts[$subvol]}"
  if ! mount -o subvol="$subvol",compress=zstd "${NVME_DISK}p2" "${subvol_mounts[$subvol]}"; then
    echo "Erro ao montar subvolume $subvol." >&2
    exit 1
  fi
done

# Monta a partição EFI
mkdir -p /mnt/boot/efi
if ! mount "${NVME_DISK}p1" /mnt/boot/efi; then
  echo "Erro ao montar partição EFI." >&2
  exit 1
fi

echo "---"
echo "Configuração de partições e subvolumes Btrfs concluída com sucesso."
echo "Agora você pode prosseguir com a instalação do sistema no diretório /mnt."
echo "---"
