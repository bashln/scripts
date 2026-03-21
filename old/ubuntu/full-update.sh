#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

clear; sleep 2

echo "#-------------------- Atualizando Sistema (Ubuntu) -------------------->"
echo ""

echo "🔄 apt-get update"
sudo apt-get update -y || true

echo "🔄 apt-get dist-upgrade"
sudo apt-get dist-upgrade -y || true

echo "🔄 apt-get autoremove --purge"
sudo apt-get autoremove --purge -y || true

echo "🔄 apt-get autoclean"
sudo apt-get autoclean -y || true

echo "🔄 apt-get clean"
sudo apt-get clean -y || true

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
