#!/bin/bash
# ==============================================================================
# SYSADMIN UPDATE SCRIPT - UNIVERSAL ARCH WAY
# Foco: Estabilidade, Rollback seguro e Detecção automática de Distro.
# ==============================================================================

set -euo pipefail

# --- Configurações ---
KEEP_CACHE_VERSIONS=3 # Mantém as 3 últimas versões de cada pacote (Rollback seguro)
LOG_FILE="/var/log/sys_update.log"

# --- Helpers de Log (Estilo SysAdmin) ---
log() {
  local msg="[$(date +'%H:%M:%S')] [*] $1"
  echo "$msg"
  # Opcional: descomente para salvar em arquivo (requer permissão de escrita)
  # echo "$msg" >> "$LOG_FILE"
}

ok() {
  echo -e "\033[32m[+] $1\033[0m"
}

warn() {
  echo -e "\033[33m[!] ALERTA: $1\033[0m"
}

die() {
  echo -e "\033[31m[X] ERRO CRÍTICO: $1\033[0m" >&2
  exit 1
}

# --- Verificação de Privilégios ---
if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
  if ! command -v sudo >/dev/null 2>&1; then
    die "Este script requer root ou sudo."
  fi
fi

# --- Funções Core ---

check_internet() {
  log "Verificando conectividade..."
  if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    die "Sem conexão com a internet. Abortando."
  fi
}

update_mirrors() {
  log "Detectando ferramenta de mirrors..."

  # Lógica agnóstica para CachyOS, Manjaro e Arch Puro
  if command -v cachyos-rate-mirrors >/dev/null 2>&1; then
    log "Ambiente CachyOS detectado."
    $SUDO cachyos-rate-mirrors || warn "Falha ao classificar mirrors CachyOS."

  elif command -v pacman-mirrors >/dev/null 2>&1; then
    log "Ambiente Manjaro detectado."
    $SUDO pacman-mirrors --fasttrack 10 || warn "Falha ao classificar mirrors Manjaro."

  elif command -v reflector >/dev/null 2>&1; then
    log "Ambiente Arch/Endeavour (Reflector) detectado."
    $SUDO reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || warn "Falha no Reflector."

  else
    warn "Nenhuma ferramenta de otimização de mirrors encontrada (reflector/pacman-mirrors). Pulando."
  fi
}

update_keyrings() {
  log "Atualizando chaveiros de criptografia (Keyrings)..."
  # Atualiza qualquer pacote que termine em -keyring para cobrir arch, cachyos, chaotic, etc.
  # Usamos --needed para não reinstalar se já estiver atualizado.
  $SUDO pacman -Sy --noconfirm --needed archlinux-keyring *-keyring 2>/dev/null || warn "Falha ao atualizar keyrings (pode ser normal se não houver updates)."
}

system_update() {
  log "Iniciando atualização do sistema (Pacman)..."
  # -Syu: Sync, Refresh, SysUpgrade. Não use -Syyu a menos que os mirrors tenham mudado drasticamente.
  if ! $SUDO pacman -Syu --noconfirm; then
    die "Falha crítica na atualização do pacman."
  fi
  ok "Pacotes oficiais atualizados."
}

aur_update() {
  log "Verificando helpers AUR..."
  # Detecta o usuário real se estiver rodando com sudo para não quebrar makepkg
  local REAL_USER="${SUDO_USER:-$USER}"

  if command -v paru >/dev/null 2>&1; then
    log "Usando Paru..."
    # Paru e Yay não devem ser rodados como root
    sudo -u "$REAL_USER" paru -Syu --noconfirm || warn "Falha no Paru."
  elif command -v yay >/dev/null 2>&1; then
    log "Usando Yay..."
    sudo -u "$REAL_USER" yay -Syu --noconfirm || warn "Falha no Yay."
  else
    warn "Nenhum helper AUR instalado."
  fi
}

cleanup_smart() {
  log "Iniciando limpeza inteligente..."

  # 1. Órfãos
  if [[ -n $(pacman -Qtdq) ]]; then
    log "Removendo pacotes órfãos..."
    $SUDO pacman -Rns --noconfirm $(pacman -Qtdq) || warn "Falha ao remover órfãos."
  else
    ok "Zero pacotes órfãos."
  fi

  # 2. Cache (A MELHORIA CRÍTICA)
  if command -v paccache >/dev/null 2>&1; then
    log "Limpando cache mantendo as últimas $KEEP_CACHE_VERSIONS versões (paccache)..."
    $SUDO paccache -r -k $KEEP_CACHE_VERSIONS
    $SUDO paccache -ruk0 # Remove cache de pacotes desinstalados
  else
    warn "'pacman-contrib' não instalado. Usando método fallback seguro (pacman -Sc)."
    # -Sc mantém os pacotes instalados, remove apenas os não instalados e dbs antigos.
    # NUNCA use -Scc em scripts automáticos.
    echo "y" | $SUDO pacman -Sc
  fi

  # 3. Journal (Logs do Systemd)
  log "Vacuuming logs do systemd (>50M)..."
  $SUDO journalctl --vacuum-size=50M >/dev/null 2>&1
}

check_pacnew() {
  log "Verificando arquivos .pacnew (Configurações pendentes)..."
  # Procura arquivos .pacnew em /etc
  local pacnews
  pacnews=$(find /etc -name "*.pacnew" 2>/dev/null)

  if [[ -n "$pacnews" ]]; then
    warn "ATENÇÃO: Arquivos .pacnew detectados. Você deve mesclar configurações manualmente:"
    echo "$pacnews"
  else
    ok "Nenhum arquivo .pacnew encontrado. Configurações limpas."
  fi
}

# --- Main Execution ---

main() {
  clear
  echo "====================================================="
  echo "   UNIVERSAL LINUX MAINTENANCE - $(hostname)"
  echo "====================================================="

  check_internet
  update_mirrors
  update_keyrings
  system_update
  aur_update

  if command -v flatpak >/dev/null 2>&1; then
    log "Atualizando Flatpaks..."
    flatpak update -y
  fi

  cleanup_smart
  check_pacnew

  echo "====================================================="
  ok "Manutenção concluída. Reinicie se houve atualização de Kernel."
  echo "====================================================="
}

main "$@"
