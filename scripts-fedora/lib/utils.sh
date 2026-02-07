#!/bin/bash
# lib/utils.sh - Biblioteca de utilidades para scripts Fedora
# Equivalente ao utils.sh do Arch, adaptado para DNF/COPR/Flatpak

# Definicao de Arquivo de Log Global
LOG_FILE="${LOG_FILE:-/tmp/install-fedora-$(date +%Y%m%d-%H%M%S).log}"

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

# Funcao de Log Interna (Escreve no arquivo e na tela)
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

# --- Funcao de Verificacao de Pacotes (Fedora/DNF) ---
# Verifica se esta instalado antes de chamar o dnf (Economiza tempo/Performance)
ensure_package() {
    local pkg="$1"

    if rpm -q "$pkg" &>/dev/null; then
        info "Pacote '$pkg' ja instalado. Pulando."
        return 0
    fi

    info "Instalando pacote: $pkg..."
    if sudo dnf install -y "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote '$pkg' instalado."
    else
        fail "Erro ao instalar '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

# Instala um grupo de pacotes DNF (ex: @development-tools)
ensure_group() {
    local grp="$1"

    if dnf group list --installed --ids 2>/dev/null | grep -qi "$grp"; then
        info "Grupo '$grp' ja instalado. Pulando."
        return 0
    fi

    info "Instalando grupo: $grp..."
    if sudo dnf group install -y "$grp" >> "$LOG_FILE" 2>&1; then
        ok "Grupo '$grp' instalado."
    else
        fail "Erro ao instalar grupo '$grp'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

# Habilita um repositorio COPR e instala o pacote
# Uso: ensure_copr_package "owner/repo" "pacote"
ensure_copr_package() {
    local repo="$1"
    local pkg="$2"

    if rpm -q "$pkg" &>/dev/null; then
        info "Pacote COPR '$pkg' ja instalado. Pulando."
        return 0
    fi

    info "Habilitando COPR: $repo..."
    if ! sudo dnf copr enable -y "$repo" >> "$LOG_FILE" 2>&1; then
        warn "Falha ao habilitar COPR '$repo' (pode ja estar habilitado)."
    fi

    info "Instalando pacote COPR: $pkg..."
    if sudo dnf install -y "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote COPR '$pkg' instalado."
    else
        fail "Erro ao instalar o pacote COPR '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

ensure_flatpak_package() {
    local pkg="$1"

    if flatpak info "$pkg" &>/dev/null; then
        info "Pacote Flatpak '$pkg' ja instalado. Pulando."
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

# Habilita RPM Fusion (free + nonfree) se ainda nao estiver habilitado
ensure_rpmfusion() {
    if rpm -q rpmfusion-free-release &>/dev/null && rpm -q rpmfusion-nonfree-release &>/dev/null; then
        info "RPM Fusion ja habilitado. Pulando."
        return 0
    fi

    info "Habilitando RPM Fusion (free + nonfree)..."
    local fedora_version
    fedora_version=$(rpm -E %fedora)

    if sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm" \
        >> "$LOG_FILE" 2>&1; then
        ok "RPM Fusion habilitado."
    else
        fail "Erro ao habilitar RPM Fusion. Verifique o log: $LOG_FILE"
        return 1
    fi
}

# Instala pacotes via cargo (binarios Rust) se ainda nao estiverem disponiveis
# Uso: ensure_cargo_package "eza" ["binario"]
ensure_cargo_package() {
    local pkg="$1"
    local bin="${2:-$1}"

    if command -v "$bin" &>/dev/null; then
        info "Binario '$bin' ja instalado. Pulando."
        return 0
    fi

    if ! command -v cargo &>/dev/null; then
        warn "cargo nao encontrado. Instale o Rust primeiro (install-rust.sh)."
        return 1
    fi

    info "Instalando '$pkg' via cargo..."
    if cargo install --locked "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote '$pkg' instalado via cargo."
    else
        fail "Erro ao instalar '$pkg' via cargo. Verifique o log: $LOG_FILE"
        return 1
    fi
}

# Instala pacotes globais do npm
# Uso: ensure_npm_global "prettier" ["binario"]
ensure_npm_global() {
    local pkg="$1"
    local bin="${2:-$1}"

    if command -v "$bin" &>/dev/null; then
        info "Binario '$bin' ja instalado. Pulando."
        return 0
    fi

    if ! command -v npm &>/dev/null; then
        warn "npm nao encontrado. Instale o Node.js primeiro (install-nodejs.sh)."
        return 1
    fi

    info "Instalando '$pkg' via npm global..."
    if npm install -g "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote '$pkg' instalado via npm."
    else
        fail "Erro ao instalar '$pkg' via npm. Verifique o log: $LOG_FILE"
        return 1
    fi
}
