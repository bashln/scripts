#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Config
# ----------------------------
MONITOR_NAME="DP-1"
RESOLUTION="1440x900"
REFRESH_RATE="75"

VIDEO_PARAM="video=${MONITOR_NAME}:${RESOLUTION}@${REFRESH_RATE}"

# Onde o Limine costuma ficar (varia por distro/instalação)
LIMINE_DEFAULT="/etc/default/limine"
LIMINE_CONFS=(
  "/boot/limine.conf"
  "/boot/limine/limine.conf"
  "/boot/EFI/limine/limine.conf"
  "/boot/EFI/Limine/limine.conf"
  "/boot/EFI/BOOT/limine.conf"
)

backup_file() {
  local f="$1"
  sudo cp -a "$f" "${f}.bak.$(date +%Y%m%d-%H%M%S)"
}

replace_or_append_video_in_string() {
  # recebe uma string (cmdline), substitui video=... se existir; senão adiciona no fim
  local s="$1"
  if [[ "$s" =~ (^|[[:space:]])video= ]]; then
    # troca somente o token video=... (até o próximo espaço)
    echo "$s" | sed -E "s/(^|[[:space:]])video=[^[:space:]]+/\1${VIDEO_PARAM}/"
  else
    echo "${s} ${VIDEO_PARAM}"
  fi
}

run_limine_update_if_any() {
  if command -v limine-update >/dev/null 2>&1; then
    sudo limine-update
  elif command -v limine-mkinitcpio >/dev/null 2>&1; then
    sudo limine-mkinitcpio
  else
    echo "Aviso: não achei 'limine-update' nem 'limine-mkinitcpio'."
    echo "Se sua distro usa outra ferramenta pra regenerar entradas Limine, rode ela manualmente."
  fi
}

echo "Aplicando: ${VIDEO_PARAM}"

# ----------------------------
# 1) Caminho recomendado (persistente em distros que geram limine.conf)
# ----------------------------
if [[ -f "$LIMINE_DEFAULT" ]]; then
  echo "Usando $LIMINE_DEFAULT (modo persistente)."
  backup_file "$LIMINE_DEFAULT"

  # Garante que existe KERNEL_CMDLINE[default]="..."
  if ! grep -qE '^\s*KERNEL_CMDLINE\[default\]=' "$LIMINE_DEFAULT"; then
    echo 'KERNEL_CMDLINE[default]=""' | sudo tee -a "$LIMINE_DEFAULT" >/dev/null
  fi

  # Lê o valor atual (simples e pragmático: assume aspas duplas numa linha)
  current="$(grep -E '^\s*KERNEL_CMDLINE\[default\]=' "$LIMINE_DEFAULT" | head -n1 | sed -E 's/^\s*KERNEL_CMDLINE\[default\]="(.*)".*$/\1/')"
  new="$(replace_or_append_video_in_string "$current")"

  sudo sed -i -E "s|^\s*KERNEL_CMDLINE\[default\]=\".*\"|KERNEL_CMDLINE[default]=\"${new//|/\\|}\"|" "$LIMINE_DEFAULT"

  run_limine_update_if_any
  echo "OK. Persistente via $LIMINE_DEFAULT."
  echo "Cmdline nova: $new"
  exit 0
fi

# ----------------------------
# 2) Fallback: editar limine.conf diretamente
# ----------------------------
limine_conf=""
for f in "${LIMINE_CONFS[@]}"; do
  if [[ -f "$f" ]]; then
    limine_conf="$f"
    break
  fi
done

if [[ -z "$limine_conf" ]]; then
  echo "Erro: não encontrei /etc/default/limine nem um limine.conf em /boot."
  echo "Procure onde está seu arquivo Limine e adicione na lista LIMINE_CONFS."
  exit 1
fi

echo "Usando $limine_conf (modo direto)."
backup_file "$limine_conf"

# Suporta dois formatos comuns:
# - Formato "novo":   cmdline: ...
# - Formato "antigo": CMDLINE=...
#
# Estratégia:
# - Se já existir video= em alguma linha cmdline/CMDLINE, substitui.
# - Senão, tenta adicionar na primeira cmdline/CMDLINE encontrada.
if grep -qE '(^\s*cmdline:\s*|^\s*CMDLINE=)' "$limine_conf"; then
  # Primeiro: substitui video=... onde existir
  if grep -qE '(^\s*cmdline:\s*.*\svideo=|^\s*CMDLINE=.*\svideo=)' "$limine_conf"; then
    sudo sed -i -E "s/(^(\s*cmdline:\s*.*)|(^\s*CMDLINE=.*))( |\t)video=[^[:space:]]+/\1 \t${VIDEO_PARAM}/" "$limine_conf" || true
    # acima é “safe-ish”; se não casar perfeitamente, faz uma troca mais simples:
    sudo sed -i -E "s/(^(\s*cmdline:\s*.*)|(^\s*CMDLINE=.*))video=[^[:space:]]+/\1${VIDEO_PARAM}/" "$limine_conf" || true
  else
    # Não tinha video=. Então adiciona no fim da primeira linha cmdline/CMDLINE
    sudo sed -i -E "0,/^\s*cmdline:\s*/{s|^\s*(cmdline:\s*)(.*)$|\1\2 ${VIDEO_PARAM}|}" "$limine_conf" || true
    sudo sed -i -E "0,/^\s*CMDLINE=/{s|^\s*(CMDLINE=)(.*)$|\1\2 ${VIDEO_PARAM}|}" "$limine_conf" || true
  fi
else
  echo "Erro: não achei linha 'cmdline:' nem 'CMDLINE=' em $limine_conf."
  echo "Abra o arquivo e veja como sua entry Linux está declarada."
  exit 1
fi

echo "OK. Atualizado em: $limine_conf"
echo "Dica: se sua distro regenerar o limine.conf em updates, prefira /etc/default/limine."
echo

# Reiniciar?
read -r -p "Deseja reiniciar agora? (s/n): " RESTART
if [[ "$RESTART" == "s" ]]; then
  sudo reboot
else
  echo "Reinicie manualmente para aplicar as alterações."
fi
