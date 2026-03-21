#!/usr/bin/env bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Atualiza índices antes de instalar
sudo apt-get update -y || true

apt_install() {
  local pkg="$1"
  echo "📦 Instalando: $pkg"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "✅ Já instalado: $pkg"
    return 0
  fi
  if ! sudo apt-get install -y "$pkg"; then
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
apt_install deno || true  # Deno pode não existir no repositório padrão

# PHP e Composer
apt_install php
apt_install composer || apt_install php-cli || true

# LSPs
apt_install python3-pylsp
apt_install python3-black || true
apt_install gopls || apt_install golang-gopls || true
apt_install rust-analyzer || true

echo "✅ Instalação (npm-install.sh) concluída."
