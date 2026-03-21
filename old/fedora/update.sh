#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Converted: 2025-10-17
# Notes: automated conversion from apt/apt-get to dnf.
#        Verify any external repositories (PPAs) manually on Fedora.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

clear
sleep 2

OS="$(hostname)"
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

sudo dnf -y makecache -y || true
sudo dnf -y upgrade --refresh -y || true
sudo dnf -y autoremove -y || true
sudo dnf clean all -y || true
sudo dnf clean all -y || true

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
