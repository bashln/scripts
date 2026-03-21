#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Updated: 2025-10-17
# Purpose: Comprehensive Fedora post-install script with CLI/dev tools, RPM Fusion, codecs, and fonts.
# Notes: Includes robust error handling (continues on failure) and replaces apt/snap logic from Ubuntu.

set -euo pipefail

echo -e "\n#-------------------- INICIANDO PÓS-INSTALAÇÃO (Fedora) --------------------#\n"

# Atualiza índices e instala dnf-plugins-core
sudo dnf -y install dnf-plugins-core || true
sudo dnf -y makecache || true

# Repositórios RPM Fusion
sudo dnf -y install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || true

# Atualiza grupos principais e instala codecs multimídia
sudo dnf -y groupupdate core || true
sudo dnf -y install ffmpeg intel-media-driver gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly gstreamer1-plugin-libav || true

# Repositório Brave
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo || true
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || true
sudo dnf -y makecache || true
sudo dnf -y install brave-browser || true

# Função de instalação resiliente
dnf_install() {
  local pkg="$1"
  echo "📦 Instalando: $pkg"
  if rpm -q "$pkg" >/dev/null 2>&1; then
    echo "✅ Já instalado: $pkg"
    return 0
  fi
  if ! sudo dnf -y install "$pkg"; then
    echo "⚠️  Falhou: $pkg (seguindo em frente)"
    return 1
  fi
}

# Pacotes essenciais CLI e Dev
for pkg in \
  ripgrep fd-find fzf bat eza duf dust btop htop tldr jq yq rsync \
  zip unzip p7zip p7zip-plugins git git-delta tree cloc age \
  direnv just gh \
  gcc gcc-c++ make cmake ninja-build pkgconf-pkg-config neovim \
  gdb valgrind strace ltrace perf \
  python3 python3-pip python3-virtualenv python3-devel pipx \
  golang delve \
  java-17-openjdk java-17-openjdk-devel maven gradle \
  sqlite sqlite-devel postgresql postgresql-server postgresql-contrib \
  podman podman-compose buildah skopeo toolbox \
  fira-code-fonts jetbrains-mono-fonts google-roboto-fonts \
  flatpak install flathub it.mijorus.gearlever
kflatpak install flathub it.mijorus.gearlever
itty vlc steam feh variety gvfs wezterm dosbox samba wine winetricks stow lazygit luarocks nodejs npm zsh zoxide vulkan-tools mesa-vulkan-drivers vkd3d; do
  dnf_install "$pkg" || true
done

sudo dnf copr enable dejan/lazygit
sudo dnf install -y lazygit

# Flatpak (opcional)
if command -v flatpak >/dev/null 2>&1; then
  echo "▶ Atualizando Flatpaks e adicionando Flathub..."
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
  flatpak update -y || true
  flatpak install -y spotify
  flatpak install -y com.mattjakeman.ExtensionManager
  flatpak install -y flathub it.mijorus.gearlever
fi

# NVM para Node (opcional)
if ! command -v nvm >/dev/null 2>&1; then
  echo "▶ Instalando NVM (Node Version Manager)..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash || true
fi

# Banco de dados PostgreSQL (opcional: inicialização)
if command -v postgresql-setup >/dev/null 2>&1; then
  echo "▶ Inicializando banco de dados PostgreSQL (caso ainda não esteja configurado)..."
  sudo postgresql-setup --initdb --unit postgresql || true
  sudo systemctl enable --now postgresql || true
fi

curl -fsSL https://linux.toys/install.sh | sh

# Atualiza caches e limpa
sudo fc-cache -fv || true
sudo dnf clean all || true

echo -e "\n✅ Pós-instalação Fedora concluída com sucesso!\n"
