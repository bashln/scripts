#!/bin/bash

# Define o caminho base correto para as entradas do systemd-boot
BOOT_ENTRIES_DIR="/efi/loader/entries"

# Tenta encontrar o arquivo de entrada do systemd-boot.
# É crucial que este diretório seja acessível.
ENTRY_FILE=$(find "$BOOT_ENTRIES_DIR" -type f -name "*.conf" | head -n 1)

# Parâmetros fixos
MONITOR_NAME="DP-1"
RESOLUTION="1440x900"
REFRESH_RATE="75"

# --- Verificações adicionais ---

# 1. Verificar se o diretório existe e é acessível
if [[ ! -d "$BOOT_ENTRIES_DIR" ]]; then
  echo "Erro: O diretório de entradas do systemd-boot '$BOOT_ENTRIES_DIR' não existe ou não é acessível."
  exit 1
fi

# 2. Verificar se o comando find encontrou um arquivo
if [[ -z "$ENTRY_FILE" ]]; then
  echo "Erro: Não foi encontrado nenhum arquivo de entrada .conf em '$BOOT_ENTRIES_DIR'."
  echo "Por favor, verifique se existem arquivos lá e se você tem permissões para lê-los."
  exit 1
fi

# 3. Confirmar se o arquivo encontrado realmente existe
if [[ ! -f "$ENTRY_FILE" ]]; then
  echo "Erro: O arquivo de entrada do systemd-boot encontrado ('$ENTRY_FILE') não existe ou não é um arquivo regular."
  exit 1
fi

# --- Lógica principal do script ---

echo "Arquivo de entrada encontrado: $ENTRY_FILE"

# Backup do arquivo original
# Adicione um timestamp para backups múltiplos
BACKUP_FILE="${ENTRY_FILE}.bak_$(date +%Y%m%d%H%M%S)"
cp "$ENTRY_FILE" "$BACKUP_FILE"
echo "Backup criado em: $BACKUP_FILE"

# Adiciona ou substitui a opção de vídeo
# Usa sed para garantir que a opção 'video=' esteja presente e correta
if grep -q "video=" "$ENTRY_FILE"; then
  # Se 'video=' já existe, substitui o valor
  sudo sed -i "s/video=[^ ]*/video=${MONITOR_NAME}:${RESOLUTION}@${REFRESH_RATE}/" "$ENTRY_FILE"
else
  # Se 'video=' não existe, adiciona-o à linha 'options'
  # Assegura que 'options' esteja no início da linha e adiciona o parâmetro
  sudo sed -i "/^options/ s/$/ video=${MONITOR_NAME}:${RESOLUTION}@${REFRESH_RATE}/" "$ENTRY_FILE"
fi

echo "Arquivo $ENTRY_FILE atualizado com a resolução desejada."
echo "Você precisará reiniciar o sistema para que as mudanças tenham efeito."
