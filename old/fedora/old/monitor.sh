#!/usr/bin/env bash

# Script para configurar a resolução e taxa de atualização do monitor no GRUB em Fedora Silverblue

# Definir variáveis
DRM_PATH="/sys/class/drm"

# ---
# Verificação de Root
# ---
if [[ $EUID -ne 0 ]]; then
   echo "Este script precisa ser executado como root. Use sudo."
   exit 1
fi

# ---
# Navegar para a pasta DRM
# ---
cd "$DRM_PATH" || {
  echo "Erro: Pasta $DRM_PATH nao encontrada."
  exit 1
}

echo "Monitores disponíveis:"
ls

echo "Digite o nome do monitor conectado (ex: card0-DP-1):"
read -r MONITOR # Usar -r para read é uma boa prática

# Extrair apenas a parte "DP-1" (usando uma regex mais robusta)
# Isso lida com padrões como DP-1, HDMI-A-1, eDP-1, DVI-D-1, etc.
MONITOR_NAME=$(echo "$MONITOR" | grep -oP '(DP|HDMI|eDP|DVI)[-\w]*-\d+')

if [[ -z "$MONITOR_NAME" ]]; then
  echo "Erro: Nao foi possivel extrair o nome do monitor do formato esperado. Verifique sua entrada."
  exit 1
fi

# ---
# Verificar o status do monitor
# ---
if [[ -f "$MONITOR/status" ]]; then
  STATUS=$(cat "$MONITOR/status")
  echo "Status do monitor $MONITOR: $STATUS"
else
  echo "Erro: Monitor $MONITOR nao encontrado ou status inacessivel."
  exit 1
fi

# ---
# Solicitar resolução e taxa de atualização
# ---
echo "Digite a resolução desejada (ex: 1440x900):"
read -r RESOLUTION
echo "Digite a frequencia desejada (ex: 75):"
read -r REFRESH_RATE

# ---
# Gerar argumento do kernel
# ---
KERNEL_ARG="video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE"

# ---
# Adicionar o argumento com rpm-ostree
# ---
echo "Verificando e adicionando argumento ao kernel: $KERNEL_ARG"

# É bom remover o argumento existente antes de adicionar para garantir que não haja duplicações se o formato mudar
# ou para atualizar uma configuração anterior.
# Para isso, você pode tentar --replace, ou --delete e --append em sequência.
# Com o --append, ele já evita duplicatas se o argumento exato for o mesmo.
# No entanto, se você quiser garantir que uma configuração antiga seja removida antes de uma nova com o mesmo prefixo,
# mas valores diferentes, seria mais complexo e talvez exigiria `--delete` o padrão antes de `--append`.
# Por simplicidade, e porque --append evita duplicatas exatas, vamos manter como está.
sudo rpm-ostree kargs --append="$KERNEL_ARG"

if [[ $? -eq 0 ]]; then
  echo "Argumentos do kernel atualizados com sucesso."
  echo "Para verificar, execute: rpm-ostree kargs"
else
  echo "Erro ao atualizar os argumentos do kernel com rpm-ostree. Verifique a saída acima para detalhes."
  exit 1
fi

# ---
# Solicitar confirmação para reiniciar
# ---
echo "Deseja reiniciar agora para aplicar as alterações? (s/n)"
read -r RESTART
if [[ "$RESTART" == "s" ]]; then
  echo "Reiniciando..."
  systemctl reboot
else
  echo "Reinicializacao cancelada. Por favor, reinicie manualmente para aplicar as alteracoes."
fi
