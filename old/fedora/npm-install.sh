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
  if ! sudo dnf -y install -y "$pkg"; then
    echo "⚠️  Falhou: $pkg (seguindo em frente)"
    return 1
  fi
}

echo "🔧 Preparando ferramentas para desenvolvimento (Ubuntu)."

# Node.js + npm (repo padrão). Se quiser Node 22+, use NodeSource fora deste script.
apt_install nodejs
apt_install npm

# Python, Rust, Go, Deno
apt_install python3
apt_install python3-pip
apt_install rustc
apt_install cargo
apt_install golang
apt_install deno || true # Deno pode não existir no repositório padrão

# PHP e Composer
apt_install php
apt_install composer || apt_install php-cli || true

# LSPs
apt_install python3-pylsp
apt_install python3-black || true
apt_install gopls || apt_install golang-gopls || true
apt_install rust-analyzer || true

echo "✅ Instalação (npm-install.sh) concluída."
