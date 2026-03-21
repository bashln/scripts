#!/bin/bash

# Variáveis fixas
GRUB_FILE="/etc/default/grub"
MONITOR_NAME="DP-1"
RESOLUTION="1440x900"
REFRESH_RATE="75"

# Backup do arquivo GRUB
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"

# Adiciona ou substitui a opção video=
if grep -q "video=" "$GRUB_FILE"; then
  sudo sed -i "s/video=[^ ]*/video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE/" "$GRUB_FILE"
else
  sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE\"/" "$GRUB_FILE"
fi
echo -e "video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE"
echo -e "\nArquivo GRUB atualizado com sucesso."

# Regerar a configuração do GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Reiniciar?
read -p "Deseja reiniciar agora? (s/n): " RESTART
if [[ "$RESTART" == "s" ]]; then
  sudo reboot
else
  echo "Reinicie manualmente para aplicar as alterações."
fi
