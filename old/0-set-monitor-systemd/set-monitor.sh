#!/bin/bash

# Caminho do arquivo de entrada do systemd-boot
ENTRY_FILE=$(find /boot/loader/entries -type f -name "*.conf" | head -n 1)

# Parâmetros fixos
MONITOR_NAME="DP-1"
RESOLUTION="1440x900"
REFRESH_RATE="75"

if [[ ! -f "$ENTRY_FILE" ]]; then
  echo "Erro: arquivo de entrada do systemd-boot não encontrado."
  exit 1
fi

# Backup do arquivo original
cp "$ENTRY_FILE" "${ENTRY_FILE}.bak"

# Adiciona ou substitui a opção de vídeo
if grep -q "video=" "$ENTRY_FILE"; then
  sed -i "s/video=[^ ]*/video=${MONITOR_NAME}:${RESOLUTION}@${REFRESH_RATE}/" "$ENTRY_FILE"
else
  sed -i "s/^options\s*\(.*\)/options \1 video=${MONITOR_NAME}:${RESOLUTION}@${REFRESH_RATE}/" "$ENTRY_FILE"
fi

echo "Arquivo $ENTRY_FILE atualizado com a resolução desejada."
