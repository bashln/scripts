#!/bin/bash
# lib/utils.sh

# Definição de Arquivo de Log Global
LOG_FILE="${LOG_FILE:-/tmp/install-arch-$(date +%Y%m%d-%H%M%S).log}"

# Cores
BLUE='\e[34m'
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'

# TUI (Charm Gum)
GUM_AVAILABLE=0
if command -v gum >/dev/null 2>&1; then
    GUM_AVAILABLE=1
fi
export GUM_AVAILABLE

# Função de Log Interna (Escreve no arquivo e na tela)
_log() {
    local level="$1"
    local color="$2"
    local msg="$3"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Escrita no Arquivo (Sem cores, com timestamp)
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"

    # Escrita na Tela (Com cores ou TUI)
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        local gum_level="info"
        case "$level" in
            WARN) gum_level="warn" ;;
            FAIL) gum_level="error" ;;
            *) gum_level="info" ;;
        esac
        gum log --level "$gum_level" -- "[$level] $msg" >&2
    else
        printf "${color}[%s] %s${RESET}\n" "$level" "$msg" >&2
    fi
}

info() { _log "INFO" "$BLUE" "$*"; }
ok()   { _log "OK"   "$GREEN" "$*"; }
warn() { _log "WARN" "$YELLOW" "$*"; }
fail() { _log "FAIL" "$RED" "$*"; }
die() {
    fail "$*"
    exit 1
}

# --- Função de Verificação de Pacotes (Agnóstica/Arch) ---
# Verifica se está instalado antes de chamar o pacman (Economiza tempo/Performance)
ensure_package() {
    local pkg="$1"
    
    if pacman -Qi "$pkg" &>/dev/null; then
        info "Pacote '$pkg' já instalado. Pulando."
        return 0
    fi

    info "Instalando pacote: $pkg..."
    # Redireciona stdout para log, mostra apenas erros na tela
    if sudo pacman -S --noconfirm --needed "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote '$pkg' instalado."
    else
        fail "Erro ao instalar '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

ensure_aur_package() {
    local pkg="$1"
    
    if yay -Qi "$pkg" &>/dev/null; then
        info "Pacote AUR '$pkg' já instalado. Pulando."
        return 0
    fi

    info "Instalando pacote AUR: $pkg..."
    if yay -S --noconfirm --needed "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote AUR '$pkg' instalado."
    else
        fail "Erro ao instalar o pacote AUR '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

ensure_flatpak_package() {
    local pkg="$1"
    
    if flatpak info "$pkg" &>/dev/null; then
        info "Pacote Flatpak '$pkg' já instalado. Pulando."
        return 0
    fi

    info "Instalando pacote Flatpak: $pkg..."
    if flatpak install -y flathub "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote Flatpak '$pkg' instalado."
    else
        fail "Erro ao instalar o pacote Flatpak '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}
