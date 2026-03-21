#!/usr/bin/env bash
set -euo pipefail

# =============================================================
# install-individual.sh
# Instala pacotes um por um com `sudo apt install -y`.
# - Checa se o pacote existe no APT antes de tentar instalar.
# - Continua mesmo se um pacote falhar.
# - Mostra um resumo ao final.
# Uso:
#   ./install-individual.sh pkg1 pkg2 pkg3 ...
# ou edite a array PACKAGES abaixo.
# =============================================================

# --- Config ---
LOG_FILE="${LOG_FILE:-$HOME/install-individual.log}"

# --- Funções utilitárias ---
log() { printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE" ; }

pkg_candidate() {
  # Retorna o valor do campo "Candidate" do apt-cache policy (ou "(none)")
  apt-cache policy "$1" 2>/dev/null | awk -F': ' '/Candidate:/ {print $2; exit}'
}

install_pkg() {
  local pkg="$1"
  log "→ Verificando pacote: $pkg"
  local cand
  cand="$(pkg_candidate "$pkg" || true)"
  if [[ -z "${cand:-}" || "${cand}" == "(none)" ]]; then
    log "⚠️  Pacote não encontrado nos repositórios APT: $pkg"
    missing+=("$pkg")
    return 0
  fi

  log "↳ Encontrado. Candidate=${cand}. Instalando: $pkg"
  # Desativa 'exit on error' durante a instalação para não abortar o loop
  set +e
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
  local rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    ok+=("$pkg")
    log "✅ Sucesso: $pkg"
  else
    failed+=("$pkg")
    log "❌ Falhou: $pkg (rc=$rc)"
  fi
}

install_pkg_list() {
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    install_pkg "$pkg"
  done
}

# --- Main ---
# Lista de pacotes. Se argumentos forem passados, usa-os; senão usa a array abaixo.
PACKAGES=(
  # Exemplo: git curl wget build-essential
  build-essential curl wget git jq unzip zip \
  software-properties-common ca-certificates apt-transport-https gnupg \
  ntfs-3g exfat-fuse exfatprogs p7zip-full \
  htop btop neofetch fastfetch \
  vim nano micro \
  gnome-disk-utility gparted baobab \
  alacritty kitty \
  flameshot vlc mpv ffmpeg \
  filezilla \
  fonts-firacode fonts-jetbrains-mono \
  fonts-noto fonts-noto-color-emoji \
  mesa-utils vulkan-tools \
  fwupd fwupd-amd64-signed \
  timeshift
)

if [[ "$#" -gt 0 ]]; then
  PACKAGES=("$@")
fi

# Preparação
: > "$LOG_FILE"
log "====== Início da instalação individual ======"

log "Atualizando índices do APT..."
sudo apt-get update -y
sudo apt update -y

# Arrays de controle
ok=()
failed=()
missing=()

install_pkg_list "${PACKAGES[@]}"

# Resumo
echo
log "===== RESUMO ====="
printf "   ✅ Instalados: %s\n" "${#ok[@]}"
if ((${#ok[@]})); then printf '      - %s\n' "${ok[@]}"; fi

printf "   ⚠️  Inexistentes no APT: %s\n" "${#missing[@]}"
if ((${#missing[@]})); then printf '      - %s\n' "${missing[@]}"; fi

printf "   ❌ Falhas: %s\n" "${#failed[@]}"
if ((${#failed[@]})); then printf '      - %s\n' "${failed[@]}"; fi

log "====== Fim ======"
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







