#!/usr/bin/env bash

# Script para configurar resolução e taxa de atualização do monitor via argumentos de kernel no Fedora Silverblue

DRM_PATH="/sys/class/drm"

# Verificação de root
#if [[ $EUID -ne 0 ]]; then
#    echo "Este script precisa ser executado como root. Use sudo."
#    exit 1
#fi

# Acessar a pasta DRM
cd "$DRM_PATH" || {
    echo "Erro: Pasta $DRM_PATH não encontrada."
    exit 1
}

echo "Monitores disponíveis:"
ls

read -rp "Digite o nome do monitor conectado (ex: card0-DP-1): " MONITOR

# Extrair nome lógico do conector (ex: DP-1, HDMI-A-1, eDP-1)
MONITOR_NAME=$(echo "$MONITOR" | grep -oP '(DP|HDMI|eDP|DVI)[-\w]*-\d+')

if [[ -z "$MONITOR_NAME" ]]; then
    echo "Erro: Nome de monitor inválido ou não reconhecido. Verifique a entrada."
    exit 1
fi

# Verificar status do monitor
if [[ -f "$MONITOR/status" ]]; then
    STATUS=$(<"$MONITOR/status")
    echo "Status do monitor $MONITOR: $STATUS"
else
    echo "Erro: Monitor $MONITOR não encontrado ou status inacessível."
    exit 1
fi

# Entrada de resolução e taxa
read -rp "Digite a resolução desejada (ex: 1440x900): " RESOLUTION
read -rp "Digite a frequência desejada (ex: 75): " REFRESH_RATE

# Montar argumento do kernel
KERNEL_ARG="video=$MONITOR_NAME:$RESOLUTION@$REFRESH_RATE"

echo "Adicionando argumento ao kernel: $KERNEL_ARG"

# Adicionar argumento (sem duplicar se já existir)
if rpm-ostree kargs --append="$KERNEL_ARG"; then
    echo -e "\n✅ Argumento adicionado com sucesso."
    echo "🔎 Verifique com: rpm-ostree kargs"
else
    echo "❌ Erro ao adicionar o argumento. Verifique a saída para mais detalhes."
    exit 1
fi

# Reinício opcional
read -rp "Deseja reiniciar agora para aplicar as alterações? (s/n): " RESTART
if [[ "$RESTART" == "s" ]]; then
    echo "Reiniciando..."
    systemctl reboot
else
    echo "Reinicialização adiada. Reinicie manualmente para aplicar as mudanças."
fi
