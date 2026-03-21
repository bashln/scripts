#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Converted: 2025-10-17
# Notes: automated conversion from apt/apt-get to dnf. 
#        Verify any external repositories (PPAs) manually on Fedora.


set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Atualiza índices antes de instalar
sudo dnf -y makecache -y || true

apt_install() {
  local pkg="$1"
  echo "📦 Instalando: $pkg"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "✅ Já instalado: $pkg"
    return 0
  fi
  if ! sudo dnf -y install -y "$pkg"; then || true
    echo "⚠️  Falhou: $pkg (seguindo em frente)"
    return 1
  fi
}

echo -e "\n#-------------------- INICIANDO PÓS-INSTALAÇÃO (Ubuntu) --------------------#\n"

# Pacotes essenciais (cada um tenta e segue em frente)
for pkg in \
  curl unzip git jq ntfs-3g \
  fonts-firacode fonts-jetbrains-mono fonts-ubuntu \
  alacritty vlc steam \
  feh kitty variety gvfs dosbox samba \
  wine winetricks stow lazygit luarocks fzf nodejs npm zsh zoxide eza \
  python3 python3-venv python3-pip python3-dev build-essential pkg-config \
  vulkan-tools mesa-vulkan-drivers libvulkan1 vkd3d ripgrep; do
  apt_install "$pkg" || true
done

curl -fsS https://dl.brave.com/install.sh | sh

# Snap (opcional)
if command -v snap >/dev/null 2>&1; then
  echo "▶ Atualizando snaps..."
  sudo snap refresh || true
fi

# Flatpak (opcional)
if command -v flatpak >/dev/null 2>&1; then
  echo "▶ Atualizando flatpaks..."
  flatpak update -y || true
fi

# Micro-correções comuns
sudo fc-cache -fv || true

echo -e "\n✅ Pós-instalação concluída com sucesso!\n"
