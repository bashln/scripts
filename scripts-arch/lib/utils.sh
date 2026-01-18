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

# Função de Log Interna (Escreve no arquivo e na tela)
_log() {
    local level="$1"
    local color="$2"
    local msg="$3"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Escrita no Arquivo (Sem cores, com timestamp)
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"

    # Escrita na Tela (Com cores)
    printf "${color}[%s] %s${RESET}\n" "$level" "$msg" >&2
}

info() { _log "INFO" "$BLUE" "$*"; }
ok()   { _log "OK"   "$GREEN" "$*"; }
warn() { _log "WARN" "$YELLOW" "$*"; }
fail() { _log "FAIL" "$RED" "$*"; }

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
