#!/bin/bash

# Variáveis fixas
MONITOR_NAME="DisplayPort-0"
RESOLUTION="1440x900"
REFRESH_RATE="75"

# Caminho para o arquivo de configuração do kernel
# Normalmente há apenas um, mas se houver múltiplos, você precisará identificar o correto.
# Para Pop!_OS, o caminho é geralmente algo como /boot/efi/loader/entries/Pop_OS-*.conf
KERNEL_CONFIG_FILE=$(find /boot/efi/loader/entries/ -name "Pop_OS-*.conf" | head -n 1)

if [ -z "$KERNEL_CONFIG_FILE" ]; then
  echo "Erro: Arquivo de configuração do kernel do Pop!_OS não encontrado."
  echo "Por favor, verifique o caminho manualmente em /boot/efi/loader/entries/"
  exit 1
fi

echo "Usando arquivo de configuração do kernel: $KERNEL_CONFIG_FILE"

# Backup do arquivo de configuração do kernel
sudo cp "$KERNEL_CONFIG_FILE" "${KERNEL_CONFIG_FILE}.bak"

# Adiciona ou substitui a opção video=
# A linha que contém as opções do kernel é tipicamente 'options'
if grep -q "video=" "$KERNEL_CONFIG_FILE"; then
  sudo sed -i "s/video=[^ ]*/video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE/" "$KERNEL_CONFIG_FILE"
else
  sudo sed -i "s/options \(.*\)/options \1 video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE/" "$KERNEL_CONFIG_FILE"
fi

echo -e "\nArquivo de configuração do kernel atualizado com sucesso."

# systemd-boot não precisa de um comando 'update-grub' ou similar.
# As alterações no arquivo de configuração do kernel são lidas diretamente no boot.

# Reiniciar?
read -p "Deseja reiniciar agora? (s/n): " RESTART
if [[ "$RESTART" == "s" ]]; then
  sudo reboot
else
  echo "Reinicie manualmente para aplicar as alterações."
fi
