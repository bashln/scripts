#!/bin/bash
set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# FIX 1: Aspas corrigidas
export LOG_FILE="$BASE_DIR/install.log"

# FIX 2: Aspas corrigidas
source "$BASE_DIR/lib/utils.sh"

SUCCESS_STEPS=()
FAILED_STEPS=()

info "Iniciando instalação. Log completo em: $LOG_FILE"

# Mantém o sudo vivo em background para quando precisarmos
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

run_step() {
  local script="$1"
  local path="$BASE_DIR/assets/$script"

  if [[ ! -x "$path" ]]; then
    warn "Script ignorado (não executável): $script"
    return
  fi

  # --- INTEGRAÇÃO DA INTELIGÊNCIA ---
  # Detecta se o script pede root explicitamente
  local requires_root=0
  if grep -q "^REQUIRES_ROOT=1" "$path"; then
    requires_root=1
  fi

  info ">>> Executando módulo: $script"

  local exit_code=0

  if [[ $requires_root -eq 1 ]]; then
    # Se requer root, usamos sudo E passamos a variável LOG_FILE adiante
    # (Sem isso, o script filho não consegue escrever no log)
    if sudo LOG_FILE="$LOG_FILE" "$path"; then
      exit_code=0
    else
      exit_code=1
    fi
  else
    # Se não requer root (ex: dotfiles, stow), roda como seu usuário normal
    if "$path"; then
      exit_code=0
    else
      exit_code=1
    fi
  fi

  if [[ $exit_code -eq 0 ]]; then
    ok "Módulo $script finalizado com sucesso."
    SUCCESS_STEPS+=("$script")
  else
    fail "Módulo $script FALHOU."
    FAILED_STEPS+=("$script")
  fi
}

STEPS=(
    "autofs.sh"
    "configure-git.sh"
    "fix-services.sh"
    "install-stow.sh"
    "install-alacritty.sh"
    "install-asdf.sh"
    "install-base-devel.sh"
    "install-cmake.sh"
    "install-curl.sh"
    "install-dotfiles.sh"
    "install-emacs.sh"
    "install-eza.sh"
    "install-flatpak-flathub.sh"
    "install-flatpak-pupgui2.sh"
    "install-flatpak-spotify.sh"
    "install-fonts.sh"
    "install-ghostty.sh"
    "install-git.sh"
    "install-go-tools.sh"
    "install-gvfs.sh"
    "install-hyprland-overrides.sh"
    "install-jq.sh"
    "install-kitty.sh"
    "install-lazygit.sh"
    "install-lib32-libs.sh"
    "install-libva-utils.sh"
    "install-linux-toys.sh"
    "install-lsps.sh"
    "install-mesa-radeon.sh"
    "install-nodejs.sh"
    "install-npm-global.sh"
    "install-ntfs-3g.sh"
    "install-ohmybash-starship.sh"
    "install-dank-material-shell.sh"
    "install-postgresql.sh"
    "install-python-tools.sh"
    "install-python.sh"
    "install-ruby.sh"
    "install-rust.sh"
    "install-samba.sh"
    "install-steam.sh"
    "install-tmux.sh"
    "install-unzip.sh"
    "install-vivaldi.sh"
    "install-vlc.sh"
    "install-vscode.sh"
    "install-vulkan-stack.sh"
    "install-wine-stack.sh"
    "install-wl-clipboard.sh"
    "install-yay.sh"
    "install-yazi.sh"
    "install-zoxide.sh"
    "install-zsh-env.sh"
    "set-shell.sh"
)

for step in "${STEPS[@]}"; do
  run_step "$step"
done

# --- RELATÓRIO ---
echo ""
echo "=========================================="
echo "          RESUMO DA OPERAÇÃO              "
echo "=========================================="
echo "Log file: $LOG_FILE"
echo ""

if [ ${#SUCCESS_STEPS[@]} -gt 0 ]; then
  printf "${GREEN}Sucessos (${#SUCCESS_STEPS[@]}):${RESET}\n"
  printf "  - %s\n" "${SUCCESS_STEPS[@]}"
fi

echo ""

if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  printf "${RED}FALHAS (${#FAILED_STEPS[@]}):${RESET}\n"
  printf "  - %s\n" "${FAILED_STEPS[@]}"
  echo ""
  warn "Verifique o arquivo $LOG_FILE."
  exit 1
else
  ok "Instalação completa sem erros!"
  exit 0
fi