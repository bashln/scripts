#!/bin/bash

# Arquivo com a lista de pacotes
BACKUP_FILE="pacotes_instalados_ontem_e_hoje.txt"

# Verifica se o arquivo existe
if [ ! -f $BACKUP_FILE ]; then
  echo "Arquivo de backup não encontrado!"
  exit 1
fi

# Instala os pacotes no Fedora
while read pacote; do
  sudo dnf install -y --skip-unavailable $pacote
done <$BACKUP_FILE

echo "Pacotes reinstalados no Fedora."
