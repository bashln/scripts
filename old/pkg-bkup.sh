#!/bin/bash

# Defina o arquivo de backup
BACKUP_FILE="pacotes_instalados_ontem_e_hoje.txt"

# Pega a data de ontem e de hoje no formato adequado
DATA_ONTEM=$(date --date="yesterday" '+%Y-%m-%d')
DATA_HOJE=$(date '+%Y-%m-%d')

# Cria uma lista de pacotes instalados desde ontem
dpkg-query -W --showformat='${Package}\n' | while read pacote; do
  DATA_INSTALACAO=$(stat --format='%y' /var/lib/dpkg/info/${pacote}.list | cut -d ' ' -f 1)

  if [ "$DATA_INSTALACAO" = "$DATA_ONTEM" ] || [ "$DATA_INSTALACAO" = "$DATA_HOJE" ]; then
    echo $pacote >>$BACKUP_FILE
  fi
done

echo "Backup dos pacotes instalados ontem e hoje concluído. Arquivo: $BACKUP_FILE"
