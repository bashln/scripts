#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Converted: 2025-10-17
# Notes: automated conversion from apt/apt-get to dnf. 
#        Verify any external repositories (PPAs) manually on Fedora.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

clear; sleep 2

echo "#-------------------- Atualizando Sistema (Ubuntu) -------------------->"
echo ""

echo "🔄 dnf -y makecache"
sudo dnf -y makecache -y || true

echo "🔄 dnf -y upgrade --refresh" || true
sudo dnf -y upgrade --refresh -y || true

echo "🔄 dnf -y autoremove --purge" || true
sudo dnf -y autoremove --purge -y || true

echo "🔄 dnf clean all"
sudo dnf clean all -y || true

echo "🔄 dnf clean all"
sudo dnf clean all -y || true

# Atualiza Flatpak
if command -v flatpak >/dev/null 2>&1; then
  echo "🔄 flatpak update"
  flatpak update -y || true
else
  echo "⚠️  Flatpak não encontrado; pulando."
fi

# Atualiza Snaps
if command -v snap >/dev/null 2>&1; then
  echo "🔄 snap refresh"
  sudo snap refresh || true
else
  echo "⚠️  Snapd não encontrado; pulando."
fi

# Firmware (quando disponível)
if command -v fwupdmgr >/dev/null 2>&1; then
  echo "🔄 fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update"
  sudo fwupdmgr refresh || true
  sudo fwupdmgr get-updates || true
  sudo fwupdmgr update -y || true
fi

echo ""
echo "✅ Atualização concluída com sucesso!"
