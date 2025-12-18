#!/usr/bin/env bash
set -euo pipefail

# =========================
# Pop!_OS 24.04 (COSMIC) - Atualização completa do sistema
# - apt full-upgrade
# - fwupd firmware
# - flatpak update
# - limpeza segura
# =========================

clear
sleep 1

TS="$(date '+%Y-%m-%d %H:%M:%S')"
OS="$(. /etc/os-release && echo "${PRETTY_NAME:-Pop!_OS}")"
KERNEL="$(uname -r)"
HOST="$(hostname)"

echo "====================================================="
echo "Atualização do sistema - $OS"
echo "Kernel: $KERNEL"
echo "Host:   $HOST"
echo "Início: $TS"
echo "====================================================="
echo

sudo true  # força sudo a pedir senha no início

echo ">> Atualizando índices do APT..."
sudo apt update -y

echo
echo ">> Corrigindo pacotes quebrados (se houver)..."
sudo apt -f install -y || true
sudo dpkg --configure -a || true

echo
echo ">> Atualizando pacotes (full-upgrade)..."
sudo apt full-upgrade -y

echo
if command -v fwupdmgr >/dev/null 2>&1; then
  echo ">> Atualizando firmware (fwupd)..."
  sudo fwupdmgr refresh --force || true
  sudo fwupdmgr get-updates || true
  sudo fwupdmgr update -y || true
else
  echo ">> fwupdmgr não encontrado; pulando atualização de firmware."
fi

echo
if command -v flatpak >/dev/null 2>&1; then
  echo ">> Atualizando Flatpaks..."
  flatpak update -y || {
    echo "!! Falha ao atualizar Flatpaks, seguindo em frente."
  }
else
  echo ">> Flatpak não encontrado; pulando Flatpaks."
fi

echo
echo ">> Removendo dependências não utilizadas..."
sudo apt autoremove --purge -y || true

echo
echo ">> Limpando cache do APT..."
sudo apt autoclean -y || true

echo
echo ">> Limpando cache de miniaturas (se existir)..."
if [ -d "$HOME/.cache/thumbnails" ]; then
  rm -rf "$HOME/.cache/thumbnails/"*
fi

echo
if command -v journalctl >/dev/null 2>&1; then
  echo ">> Compactando logs do journal (mantendo últimos 14 dias)..."
  sudo journalctl --vacuum-time=14d || true
fi

echo
echo "====================================================="
echo "✅ Atualização concluída em: $(date '+%Y-%m-%d %H:%M:%S')"
echo "====================================================="
