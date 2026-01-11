#!/bin/bash
set -euo pipefail

# Manutenção completa do sistema (Arch/derivados)
# - Atualiza mirrors (se pacman-mirrors existir)
# - Ajusta keyring e remove alguns pacotes específicos
# - Atualiza pacotes oficiais (pacman)
# - Atualiza AUR (yay ou paru, se existirem)
# - Atualiza Flatpak (se existir)
# - Limpa órfãos e cache do pacman
# - Dá dicas sobre configs/resíduos

# --- helpers de log ---

log() {
  printf '[*] %s\n' "$*"
}

ok() {
  printf '[+] %s\n' "$*"
}

warn() {
  printf '[!] %s\n' "$*"
}

die() {
  printf '[X] %s\n' "$*" >&2
  exit 1
}

# --- checagens básicas ---

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Comando requerido não encontrado: $1"
  fi
}

require_cmd pacman

# Se rodar como root, não usa sudo
if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
  require_cmd sudo
fi

# --- funções de manutenção ---

update_mirrors_and_base() {
  clear || true
  sleep 1

  log "Iniciando etapa de mirrors e base..."

  if command -v pacman-mirrors >/dev/null 2>&1; then
    log "Atualizando mirrors (pacman-mirrors --fasttrack 20)..."
    $SUDO pacman-mirrors --fasttrack 20 || warn "Falha ao atualizar mirrors com pacman-mirrors."
  else
    warn "pacman-mirrors não encontrado. Pulando atualização de mirrors (ok em Arch puro)."
  fi

  log "Atualizando archlinux-keyring..."
  $SUDO pacman -S archlinux-keyring --noconfirm --needed || warn "Falha ao atualizar archlinux-keyring."

  # Remoção de pacotes específicos, se instalados
  if pacman -Qi gedit >/dev/null 2>&1; then
    log "Removendo gedit..."
    $SUDO pacman -Rns gedit --noconfirm || warn "Falha ao remover gedit."
  fi

  if pacman -Qi webkit2gtk-5.0 >/dev/null 2>&1; then
    log "Removendo webkit2gtk-5.0 (Rdd)..."
    $SUDO pacman -Rdd webkit2gtk-5.0 --noconfirm || warn "Falha ao remover webkit2gtk-5.0."
  fi

  ok "Etapa de mirrors/base finalizada."
  printf '\n'
}

update_pacman() {
  log "Atualizando pacotes oficiais (pacman -Syyu)..."
  if ! $SUDO pacman -Syyu --noconfirm; then
    die "Erro ao atualizar pacotes oficiais (pacman)."
  fi
  ok "Pacotes oficiais atualizados."
  printf '\n'
}

update_aur() {
  # Prioriza yay, depois paru
  if command -v yay >/dev/null 2>&1; then
    log "Atualizando pacotes do AUR com yay..."
    if ! yay -Syu --noconfirm; then
      die "Erro ao atualizar pacotes do AUR com yay."
    fi
    ok "AUR atualizado com yay."
  elif command -v paru >/dev/null 2>&1; then
    log "Atualizando pacotes do AUR com paru..."
    if ! paru -Syu --noconfirm; then
      die "Erro ao atualizar pacotes do AUR com paru."
    fi
    ok "AUR atualizado com paru."
  else
    warn "Nenhum helper AUR encontrado (yay/paru). Pulando atualização do AUR."
  fi
  printf '\n'
}

update_flatpak() {
  if command -v flatpak >/dev/null 2>&1; then
    log "Atualizando pacotes Flatpak..."
    if ! flatpak update -y; then
      die "Erro ao atualizar pacotes Flatpak."
    fi
    ok "Flatpaks atualizados."
  else
    warn "Flatpak não encontrado. Pulando atualização de Flatpak."
  fi
  printf '\n'
}

clean_orphans() {
  log "Verificando pacotes órfãos..."
  # Captura órfãos em variável; pode não haver nenhum
  local orphans
  orphans="$(pacman -Qtdq 2>/dev/null || true)"

  if [[ -z "${orphans:-}" ]]; then
    ok "Nenhum pacote órfão encontrado."
    return
  fi

  log "Removendo pacotes órfãos..."
  $SUDO pacman -Rns --noconfirm $orphans || warn "Falha ao remover alguns pacotes órfãos."
  ok "Limpeza de órfãos concluída."
  printf '\n'
}

clean_cache() {
  log "Limpando cache do pacman (pacman -Scc)..."
  # --noconfirm evita os prompts interactivos
  $SUDO pacman -Scc --noconfirm || warn "Falha ao limpar cache do pacman."
  ok "Cache do pacman limpo."
  printf '\n'
}

clean_configs_tips() {
  log "Dicas de limpeza de configs/resíduos:"
  printf '  - Verifique arquivos *.pacnew e *.pacsave em /etc\n'
  printf '  - Revise configs antigas em ~/.config e /etc para apps desinstalados\n'
  printf '  - Logs antigos podem acumular em /var/log\n'
  printf '  - Exemplos úteis:\n'
  printf '      find ~ -iname "*<nome_app>*"\n'
  printf '      sudo find /etc -iname "*<nome_app>*"\n'
  printf '      sudo journalctl --vacuum-size=50M\n'
  printf '      sudo journalctl --vacuum-time=7days\n'
  printf '\n'
}

print_header() {
  clear || true
  echo "====================================================="
  echo " Manutenção do sistema - $(date)"
  echo " Usuário: $USER"
  echo " Hostname: $(hostname)"
  echo " Kernel: $(uname -r)"
  echo "====================================================="
  echo
}

main() {
  print_header

  update_mirrors_and_base
  update_pacman
  update_aur
  update_flatpak

  clean_orphans
  clean_cache
  clean_configs_tips

  ok "Manutenção completa finalizada com sucesso. 🚀"
}

main "$@"
