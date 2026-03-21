#!/usr/bin/env bash
set -euo pipefail

# Pós-instalação básica para Pop!_OS 24.04 (COSMIC)
# - Pacotes essenciais de dev e desktop
# - Flatpak/Flathub
# - Codecs e fontes
# - Qualidade de vida

sudo true

echo "== Atualizando índices =="
sudo apt update -y

echo "== Pacotes essenciais =="
sudo apt install -y \
  build-essential curl wget git jq unzip zip \
  software-properties-common ca-certificates apt-transport-https gnupg \
  ntfs-3g exfat-fuse exfatprogs p7zip-full \
  htop btop neofetch \
  vim nano micro \
  gnome-disk-utility gparted baobab \
  alacritty kitty \
  flameshot vlc mpv ffmpeg \
  filezilla \
  fonts-firacode fonts-jetbrains-mono \
  fonts-noto fonts-noto-color-emoji \
  mesa-utils vulkan-tools \
  fwupd \
  timeshift zsh stow eza

# OBS: Steam e apps proprietários normalmente via Flatpak é mais estável
echo "== Flatpak / Flathub =="
if ! flatpak remotes | grep -qi flathub; then
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Exemplos úteis (descomente se quiser instalar já)
# flatpak install -y flathub com.brave.Browser
# flatpak install -y flathub com.valvesoftware.Steam
# flatpak install -y flathub org.mozilla.firefox

echo "== Codecs multimídia (extras) =="
# Em Ubuntu/Pop, ubuntu-restricted-extras normalmente resolve codecs comuns
sudo apt install -y ubuntu-restricted-extras || true

echo "== NVIDIA (opcional) =="
# Para GPUs NVIDIA, instale o driver recomendado (Pop!_OS fornece metapacotes).
# sudo apt install -y system76-driver-nvidia || true

echo "== Concluído pós-instalação =="
