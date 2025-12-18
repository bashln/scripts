#!/bin/bash

# No Pop!_OS, usamos o kernelstub para gerenciar o systemd-boot
PARAM="video=DP-1:1440x900@75"

echo "Configurando resolução para $PARAM..."

# Verifica se o parâmetro já existe para não duplicar
if kernelstub -p | grep -q "$PARAM"; then
    echo "O parâmetro já está configurado."
else
    sudo kernelstub -a "$PARAM"
    echo "Parâmetro adicionado com sucesso!"
fi

# No systemd-boot não precisamos de 'grub-mkconfig'
# O kernelstub já cuida da atualização dos arquivos .conf em /boot/efi

read -p "Deseja reiniciar agora? (s/n): " RESTART
[[ "$RESTART" == "s" ]] && sudo reboot
