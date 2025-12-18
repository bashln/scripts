#!/usr/bin/env bash
set -euo pipefail

# Limpeza segura de pacotes/configs no Pop!_OS

echo "== Limpeza Pop!_OS =="

echo "-> Removendo dependências não usadas"
sudo apt autoremove --purge -y || true

echo "-> Limpando caches (apt)"
sudo apt autoclean -y || true

echo "-> Verificando pacotes mantidos (hold)"
apt-mark showhold || true

echo "-> Limpando miniaturas de imagens"
rm -rf "$HOME/.cache/thumbnails/"* || true

echo "-> Limpando caches comuns"
rm -rf "$HOME/.cache/"{mesa_shader_cache,vlc,chromium,mozilla,Code}* 2>/dev/null || true

echo "-> (Opcional) Limpando kernels antigos (cuidado)"
# sudo apt purge linux-image-X linux-headers-X

echo "Concluído."
