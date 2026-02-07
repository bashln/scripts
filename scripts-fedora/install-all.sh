#!/bin/bash
set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="$BASE_DIR/install.log"
FAIL_LOG="$BASE_DIR/install-failures.log"

source "$BASE_DIR/lib/utils.sh"

SUCCESS_STEPS=()
FAILED_STEPS=()

# Inicializa o log de falhas (limpa execucoes anteriores)
: > "$FAIL_LOG"

info "Iniciando instalacao Fedora. Log completo em: $LOG_FILE"

# Mantem o sudo vivo em background para quando precisarmos
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
        warn "Script ignorado (nao executavel): $script"
        return
    fi

    # Detecta se o script pede root explicitamente
    local requires_root=0
    if grep -q "^REQUIRES_ROOT=1" "$path"; then
        requires_root=1
    fi

    info ">>> Executando modulo: $script"

    local exit_code=0

    if [[ $requires_root -eq 1 ]]; then
        if sudo LOG_FILE="$LOG_FILE" "$path"; then
            exit_code=0
        else
            exit_code=1
        fi
    else
        if "$path"; then
            exit_code=0
        else
            exit_code=1
        fi
    fi

    if [[ $exit_code -eq 0 ]]; then
        ok "Modulo $script finalizado com sucesso."
        SUCCESS_STEPS+=("$script")
    else
        fail "Modulo $script FALHOU."
        FAILED_STEPS+=("$script")
    fi
}

STEPS=(
    # ----------------------------------------
    # 1. System Base & Core Utilities
    # ----------------------------------------
    "install-dev-tools.sh"
    "install-git.sh"
    "install-stow.sh"
    "install-curl.sh"
    "install-unzip.sh"
    "install-jq.sh"
    "install-eza.sh"
    "install-zoxide.sh"
    "install-linux-toys.sh"

    # ----------------------------------------
    # 2. RPM Fusion (necessario para Steam, codecs, etc)
    # ----------------------------------------
    "install-rpmfusion.sh"

    # ----------------------------------------
    # 3. Languages & Runtimes
    # ----------------------------------------
    "install-go-tools.sh"
    "install-python.sh"
    "install-python-tools.sh"
    "install-ruby.sh"
    "install-rust.sh"

    # ----------------------------------------
    # 4. Graphics, Multimedia & Drivers
    # ----------------------------------------
    "install-fonts.sh"
    "install-mesa-radeon.sh"
    "install-vulkan-stack.sh"
    "install-lib32-libs.sh"
    "install-libva-utils.sh"
    "install-gvfs.sh"

    # ----------------------------------------
    # 5. Terminal Emulators & Shells
    # ----------------------------------------
    "install-alacritty.sh"
    "install-kitty.sh"
    "install-ghostty.sh"
    "install-tmux.sh"
    "install-zsh-env.sh"
    "install-ohmybash-starship.sh"
    "set-shell.sh"

    # ----------------------------------------
    # 6. Networking & Storage
    # ----------------------------------------
    "install-ntfs-3g.sh"
    "install-samba.sh"
    "autofs.sh"
    "install-wl-clipboard.sh"
    "fix-services.sh"

    # ----------------------------------------
    # 7. Browsers
    # ----------------------------------------
    "install-vivaldi.sh"
    "install-brave.sh"

    # ----------------------------------------
    # 8. Development Tools
    # ----------------------------------------
    "install-asdf.sh"
    "install-cmake.sh"
    "install-nodejs.sh"
    "install-npm-global.sh"
    "install-lsps.sh"
    "install-vscode.sh"
    "install-lazygit.sh"
    "install-emacs.sh"
    "configure-git.sh"

    # ----------------------------------------
    # 9. Applications
    # ----------------------------------------
    "install-remmina.sh"
    "install-vlc.sh"
    "install-yazi-deps.sh"
    "install-yazi.sh"
    "install-steam.sh"
    "install-wine-stack.sh"
    "install-postgresql.sh"

    # ----------------------------------------
    # 10. Flatpak Applications
    # ----------------------------------------
    "install-flatpak-flathub.sh"
    "install-flatpak-pupgui2.sh"
    "install-flatpak-spotify.sh"

    # ----------------------------------------
    # 11. Desktop Environment Overrides (Hyprland specific)
    # ----------------------------------------
    "install-hyprland-overrides.sh"
    "install-hyprland-autostart.sh"
)

for step in "${STEPS[@]}"; do
    run_step "$step"
done

# --- LOG DE FALHAS ---
# Extrai apenas as linhas [FAIL] do log principal para o log de falhas
grep "\[FAIL\]" "$LOG_FILE" > "$FAIL_LOG" 2>/dev/null

# --- RELATORIO ---
echo ""
echo "=========================================="
echo "          RESUMO DA OPERACAO              "
echo "=========================================="
echo "Log completo: $LOG_FILE"
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
    warn "Log de falhas salvo em: $FAIL_LOG"
    warn "Log completo em: $LOG_FILE"
    exit 1
else
    # Remove o log de falhas vazio quando nao ha erros
    rm -f "$FAIL_LOG"
    ok "Instalacao completa sem erros!"
    exit 0
fi
