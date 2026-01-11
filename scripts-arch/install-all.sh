#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cores para feedback visual
info() { printf "\e[34m[*]\e[0m %s\n" "$*"; }
ok() { printf "\e[32m[+]\e[0m %s\n" "$*"; }
warn() { printf "\e[33m[!]\e[0m %s\n" "$*"; }
fail() { printf "\e[31m[✗]\e[0m %s\n" "$*"; }

run_step() {
  local script="$1"
  local path="$SCRIPTS_DIR/$script"

  if [[ ! -x "$path" ]]; then
    warn "Script não encontrado ou não executável: $script"
    return
  fi

  # Detecta se o script requer root
  local requires_root=0
  if grep -q '^REQUIRES_ROOT=1' "$path"; then
    requires_root=1
  fi

  info "Executando: $script"

  if [[ $requires_root -eq 1 ]]; then
    if [[ $EUID -eq 0 ]]; then
      "$path"
    else
      sudo "$path"
    fi
  else
    "$path"
  fi

  if [[ $? -eq 0 ]]; then
    ok "$script concluído com sucesso."
  else
    fail "$script falhou, continuando..."
  fi

  echo
}

main() {
  # Nunca chame install-all.sh aqui!
  local steps=(
    autofs.sh
    configure-git.sh
    fix-services.sh
    install-alacritty.sh
    install-asdf.sh
    install-base-devel.sh
    install-cmake.sh
    install-curl.sh
    install-dotfiles.sh
    install-emacs.sh
    install-eza.sh
    install-flatpak-flathub.sh
    install-flatpak-pupgui2.sh
    install-flatpak-spotify.sh
    install-fonts.sh
    install-ghostty.sh
    install-git.sh
    install-go-tools.sh
    install-gvfs.sh
    install-hyprland-overrides.sh
    install-jq.sh
    # install-kitty.sh
    install-lazygit.sh
    install-lib32-libs.sh
    install-libva-utils.sh
    install-linux-toys.sh
    install-mesa-radeon.sh
    install-nodejs.sh
    install-npm-global.sh
    install-ntfs-3g.sh
    install-ohmybash-starship.sh
    install-postgresql.sh
    install-python-tools.sh
    install-python.sh
    install-ruby.sh
    install-rust.sh
    install-samba.sh
    install-steam.sh
    install-stow.sh
    install-system-update.sh
    # install-tmux.sh
    install-unzip.sh
    # install-vivaldi.sh
    install-vlc.sh
    # install-vscode.sh
    install-vulkan-stack.sh
    install-wine-stack.sh
    install-wl-clipboard.sh
    install-yay.sh
    install-yazi.sh
    install-zoxide.sh
    update.sh
  )

  for step in "${steps[@]}"; do
    run_step "$step"
  done

  ok "Todas as etapas concluídas!"
}

main "$@"
