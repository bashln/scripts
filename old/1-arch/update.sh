#!/bin/bash

# Limpa a tela e aguarda 2 segundos para melhor visualização
clear
sleep 2

echo "====================================================="
echo "Atualização do Fedora $(rpm -E %fedora) - GNOME $(gnome-shell --version | awk '{print $3}')"
echo "Início: $(date)"
echo "Usuário: $USER"
echo "Hostname: $(hostname)"
echo "====================================================="
echo ""

echo "====================================================="
echo "Iniciando atualização do sistema"
echo "====================================================="
echo ""

# Atualiza os repositórios e o sistema
echo "====================================================="
echo "🔄 Atualizando pacotes oficiais..."
echo "====================================================="
if ! sudo pacman -Syyu --noconfirm; then
  echo "====================================================="
  echo "❌ Erro ao atualizar pacotes oficiais."
  echo "====================================================="
  exit 1
fi

# Atualiza pacotes do AUR usando Paru (se instalado)
if command -v paru &>/dev/null; then
  echo "====================================================="
  echo "🔄 Atualizando pacotes do AUR..."
  echo "====================================================="
  if ! paru -Syu --noconfirm; then
    echo "====================================================="
    echo "❌ Erro ao atualizar pacotes do AUR."
    echo "====================================================="
    exit 1
  fi
else
  echo "====================================================="
  echo "⚠️ Paru não encontrado. Pulei a atualização do AUR."
  echo "====================================================="
fi

# Atualiza os pacotes Flatpak
if command -v flatpak &>/dev/null; then
  echo "====================================================="
  echo "🔄 Atualizando pacotes Flatpak..."
  echo "====================================================="
  if ! flatpak update -y; then
    echo "====================================================="
    echo "❌ Erro ao atualizar pacotes Flatpak."
    echo "====================================================="
    exit 1
  fi
else
  echo "====================================================="
  echo "⚠️ Flatpak não encontrado. Pulei a atualização de Flatpak."
  echo "====================================================="
fi

echo "====================================================="
echo "✅ Atualização concluída com sucesso!"
echo "====================================================="
