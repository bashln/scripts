
#!/usr/bin/env bash
# =============================================================================
# Autor: leonamsh (Leonam Monteiro)
# Script: fedora-gaming-setup.sh
# Descrição: Pós-instalação gamer para Fedora Workstation focado em Steam + AMD
#            (inclui iGPU do Ryzen 5700). Sem NVIDIA e sem MangoHud.
# Uso:     bash fedora-gaming-setup.sh
# =============================================================================
set -euo pipefail

echo "[1/7] Atualizando o sistema…"
sudo dnf -y upgrade --refresh

echo "[2/7] Habilitando RPM Fusion (free e nonfree)…"
sudo dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

echo "[3/7] Instalando pacotes essenciais (Steam, ProtonUp-Qt, GameMode, Gamescope)…"
sudo dnf -y install \
  steam \
  protonup-qt \
  gamemode \
  gamescope

echo "[4/7] Vulkan e 32-bit para Proton (AMD/RADV)…"
sudo dnf -y install \
  mesa-dri-drivers \
  mesa-dri-drivers.i686 \
  mesa-vulkan-drivers \
  mesa-vulkan-drivers.i686 \
  vulkan-loader \
  vulkan-loader.i686 \
  vulkan-tools

echo "[5/7] Aceleração de vídeo por hardware (AMD) — útil para streaming/players"
sudo dnf -y install \
  libva libva-utils \
  libvdpau-va-gl \
  mesa-va-drivers \
  mesa-vdpau-drivers \
  ffmpeg-libs

echo "[6/7] Ativando GameMode (user service)…"
# O gamemoded sobe sob demanda, mas ativar o user service evita problemas.
systemctl --user daemon-reload || true
systemctl --user enable --now gamemoded || true

echo "[7/7] Verificando power-profiles (performance)…"
if command -v powerprofilesctl >/dev/null 2>&1; then
  echo " -> Power Profiles disponível. Para jogar, rode:  powerprofilesctl set performance"
else
  echo " -> Instalando power-profiles-daemon…"
  sudo dnf -y install power-profiles-daemon
  echo " -> Depois do reboot, use: powerprofilesctl set performance"
fi

cat <<'TIP'

================================================================================
DICAS RÁPIDAS (AMD/Ryzen + Steam)
--------------------------------------------------------------------------------
1) Proton-GE:
   - Abra o "ProtonUp-Qt" e instale a versão mais recente do Proton-GE.
   - No Steam > Configurações > Compatibilidade: habilite Proton Experimental
     ou selecione Proton-GE no jogo.

2) GameMode no Steam (por jogo):
   - Em "Opções de Inicialização" do jogo, use:
       gamemoderun %command%
   - Para usar o Gamescope (scaler/FSR, útil em iGPU):
       gamemoderun gamescope -f -- %command%

3) AMD iGPU (Ryzen 5700):
   - Os drivers corretos já são os do Mesa/RADV (instalados acima).
   - O compilador ACO já é padrão → melhores tempos de shader.
   - Para ver Vulkan ativo:  vulkaninfo | less

4) Biblioteca da Steam fora do NVMe (opcional):
   - Crie/montar um SSD em /mnt/games e adicione como Biblioteca no Steam:
     Steam > Configurações > Downloads > Diretórios de Biblioteca.

5) Perfil de energia:
   - Antes de jogar, opcionalmente:
       powerprofilesctl set performance
     (para voltar:  powerprofilesctl set balanced)

Pronto! Fedora + AMD preparado para jogos sem tralha extra.
================================================================================
TIP

echo "✔ Concluído."
