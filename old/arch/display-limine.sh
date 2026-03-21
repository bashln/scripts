#!/bin/bash

# --- Configurações ---
# No CachyOS/Arch, geralmente fica em /boot/limine.conf ou /boot/efi/limine.conf
# Ajuste o caminho conforme o seu sistema
LIMINE_FILE="/boot/limine.conf"

MONITOR_NAME="DP-1"
RESOLUTION="1440x900"
REFRESH_RATE="75"
NEW_PARAM="video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE"

# --- Verificações ---
if [ ! -f "$LIMINE_FILE" ]; then
  echo "Erro: Arquivo $LIMINE_FILE não encontrado."
  echo "Verifique se está em /boot/efi/limine.conf ou /efi/limine.conf"
  exit 1
fi

echo "Configurando para: $NEW_PARAM"

# --- Backup ---
sudo cp "$LIMINE_FILE" "${LIMINE_FILE}.bak"
echo "Backup criado em ${LIMINE_FILE}.bak"

# --- Lógica de Substituição (A Mágica) ---

# O Limine usa 'kernel_cmdline:' ou apenas 'cmdline:'. Vamos cobrir ambos.
# A lógica é:
# 1. Se a linha tem 'cmdline' E já tem 'video=', substitui o valor do video.
# 2. Se a linha tem 'cmdline' mas NÃO tem 'video=', adiciona ao final da linha.

# 1. Substituir valor existente de video=...
sudo sed -i -E "/(kernel_)?cmdline:/s/video=[^ ]+/$NEW_PARAM/" "$LIMINE_FILE"

# 2. Adicionar se não existir (verifica linhas com cmdline que NÃO tenham video=)
# O comando abaixo procura linhas com 'cmdline:' que NÃO contêm 'video=' e anexa o parâmetro no fim.
sudo sed -i -E "/(kernel_)?cmdline:/ { /video=/! s/$/ $NEW_PARAM/ }" "$LIMINE_FILE"

echo -e "\nArquivo Limine atualizado com sucesso."

# --- Finalização ---
# Nota: Não existe 'limine-mkconfig'. O arquivo editado já é o que vale.

read -p "Deseja reiniciar agora? (s/n): " RESTART
if [[ "$RESTART" == "s" ]]; then
  sudo reboot
else
  echo "Reinicie manualmente para aplicar as alterações."
fi
