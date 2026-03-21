#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

clear
sleep 2

OS="$(lsb_release -ds 2>/dev/null || echo Ubuntu)"
DESKTOP="$(gnome-shell --version 2>/dev/null | awk '{print $3}' || echo '-')"

echo "====================================================="
echo "Atualização do ${OS} - GNOME ${DESKTOP}"
echo "Início: $(date)"
echo "Usuário: $USER"
echo "Hostname: $(hostname)"
echo "====================================================="
echo ""

echo "====================================================="
echo "Iniciando atualização do sistema"
echo "====================================================="

sudo apt-get update -y || true
sudo apt-get dist-upgrade -y || true
sudo apt-get autoremove --purge -y || true
sudo apt-get autoclean -y || true
sudo apt-get clean -y || true

# Flatpak
if command -v flatpak >/dev/null 2>&1; then
  echo "====================================================="
  echo "Atualizando pacotes Flatpak"
  echo "====================================================="
  flatpak update -y || true
else
  echo "====================================================="
  echo "⚠️ Flatpak não encontrado. Pulei a atualização de Flatpak."
  echo "====================================================="
fi

# Snap
if command -v snap >/dev/null 2>&1; then
  echo "====================================================="
  echo "Atualizando pacotes Snap"
  echo "====================================================="
  sudo snap refresh || true
fi

echo "====================================================="
echo "✅ Atualização concluída com sucesso!"
echo "====================================================="
