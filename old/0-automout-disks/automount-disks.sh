#!/usr/bin/env bash
set -euo pipefail

# Automount Disks - versão final corrigida
# Seleciona partições interativamente e adiciona ao /etc/fstab
# Cria backup e evita duplicatas.

DRY_RUN="${1:-}"
[[ "$DRY_RUN" == "--dry-run" ]] && echo "[DRY-RUN] Nenhuma alteração será aplicada."

# --- funções utilitárias
need() { command -v "$1" >/dev/null 2>&1 || {
  echo "Erro: comando '$1' não encontrado."
  exit 1
}; }
confirm() {
  read -r -p "$1 [s/N]: " ans
  [[ "${ans:-N}" =~ ^([sS]|[sS]im)$ ]]
}
ask() {
  local p="$1"
  local d="${2:-}"
  if [[ -n "$d" ]]; then
    read -r -p "$p [$d]: " REPLY
    REPLY="${REPLY:-$d}"
  else
    read -r -p "$p: " REPLY
  fi
}
as_root() {
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    echo "[DRY-RUN] $*"
  else
    if [[ $EUID -ne 0 ]]; then sudo bash -lc "$*"; else bash -lc "$*"; fi
  fi
}
timestamp() { date +"%Y%m%d-%H%M%S"; }

# opções por fs
fs_options() {
  case "$1" in
  ext4 | ext3 | ext2) echo "defaults,noatime" ;;
  xfs) echo "defaults,noatime" ;;
  btrfs) echo "defaults,compress=zstd:3,ssd,noatime" ;;
  ntfs | ntfs3) echo "defaults,uid=$(id -u),gid=$(id -g),umask=022" ;;
  vfat | fat | fat32) echo "defaults,uid=$(id -u),gid=$(id -g),umask=000,iocharset=utf8" ;;
  exfat) echo "defaults,uid=$(id -u),gid=$(id -g),umask=022" ;;
  *) echo "defaults" ;;
  esac
}

# --- checagens
for cmd in lsblk blkid grep sed awk cut tr; do need "$cmd"; done

# --- listar partições com UUID (ignora sem UUID e tipo swap)
mapfile -t LINES < <(
  lsblk -o NAME,FSTYPE,UUID,LABEL,SIZE,MOUNTPOINT -P |
    grep -v 'UUID=""' |
    grep -v 'FSTYPE="swap"'
)

if ((${#LINES[@]} == 0)); then
  echo "Nenhuma partição válida encontrada."
  exit 1
fi

echo "Partições detectadas:"
printf '  %s\n' "${LINES[@]}"
echo

# --- seleção
SELECTED=()
if command -v fzf >/dev/null 2>&1; then
  echo "Use <Tab> para marcar múltiplas; <Enter> para confirmar."
  SELECTED=($(printf '%s\n' "${LINES[@]}" |
    fzf --multi --with-nth=1,2,4,5 --delimiter=' ' --height=80% --border))
else
  echo "Digite os dispositivos (ex.: /dev/sdb2 /dev/sda1):"
  read -r NAMES
  for n in $NAMES; do
    line=$(printf '%s\n' "${LINES[@]}" | grep "NAME=\"$n\"") || true
    [[ -n "$line" ]] && SELECTED+=("$line") || echo "Aviso: '$n' não encontrado, ignorando."
  done
fi

if ((${#SELECTED[@]} == 0)); then
  echo "Nada selecionado. Saindo."
  exit 0
fi

# --- backup fstab
FSTAB="/etc/fstab"
BACKUP="/etc/fstab.backup-$(timestamp)"
if [[ "$DRY_RUN" != "--dry-run" ]]; then
  if [[ $EUID -ne 0 ]]; then
    sudo cp -a "$FSTAB" "$BACKUP"
  else
    cp -a "$FSTAB" "$BACKUP"
  fi
  echo "Backup criado: $BACKUP"
else
  echo "[DRY-RUN] Backup seria criado em: $BACKUP"
fi
echo

NEW_LINES=()

for entry in "${SELECTED[@]}"; do
  eval "$entry"

  # inicialização segura (mesmo se algum campo vier vazio)
  : "${NAME:=}"
  : "${FSTYPE:=unknown}"
  : "${UUID:=}"
  : "${LABEL:=}"
  : "${SIZE:=}"
  : "${MOUNTPOINT:=}"

  MP_SUG=$([[ -n "$LABEL" ]] && echo "/mnt/${LABEL// /_}" || echo "/mnt/$UUID")
  ask "Ponto de montagem para $NAME (FSTYPE=$FSTYPE, SIZE=$SIZE)" "$MP_SUG"
  MP="$REPLY"

  if [[ ! -d "$MP" ]]; then
    echo "Criando diretório $MP"
    as_root "mkdir -p $(printf %q "$MP")"
  fi

  DEF_OPTS=$(fs_options "$FSTYPE")
  ask "Opções de montagem para $NAME" "$DEF_OPTS"
  OPTS="$REPLY"

  if grep -q "UUID=$UUID" "$FSTAB"; then
    echo "• Já existe entrada para $UUID, pulando."
  else
    LINE="UUID=$UUID  $MP  $FSTYPE  $OPTS  0  0"
    NEW_LINES+=("$LINE")
    echo "• Adicionar: $LINE"
  fi
  echo
done

if ((${#NEW_LINES[@]} == 0)); then
  echo "Nenhuma nova entrada a adicionar."
  exit 0
fi

if ! confirm "Escrever no $FSTAB e montar agora?"; then
  echo "Cancelado. Backup em: $BACKUP"
  exit 0
fi

for l in "${NEW_LINES[@]}"; do
  as_root "printf '%s\n' '# automount-disks.sh $(timestamp)' '$l' >> '$FSTAB'"
done

echo
echo "Aplicando mudanças..."
if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "[DRY-RUN] systemctl daemon-reload; mount -a"
else
  as_root "systemctl daemon-reload || true"
  as_root "mount -a"
  echo "Montagens aplicadas."
fi

echo "Concluído."
