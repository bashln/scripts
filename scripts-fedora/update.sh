#!/bin/bash
# ==============================================================================
# SYSADMIN UPDATE SCRIPT - FEDORA
# Foco: Estabilidade e manutencao simples do sistema.
# Equivalente ao update.sh do Arch (sem mirrors/keyrings).
# ==============================================================================

set -euo pipefail

# --- Configuracoes ---
LOG_FILE="/var/log/sys_update.log"

# --- Helpers de Log (Estilo SysAdmin) ---
log() {
    local msg="[$(date +'%H:%M:%S')] [*] $1"
    echo "$msg"
}

ok() {
    echo -e "\033[32m[+] $1\033[0m"
}

warn() {
    echo -e "\033[33m[!] ALERTA: $1\033[0m"
}

die() {
    echo -e "\033[31m[X] ERRO CRITICO: $1\033[0m" >&2
    exit 1
}

# --- Verificacao de Privilegios ---
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
    if ! command -v sudo >/dev/null 2>&1; then
        die "Este script requer root ou sudo."
    fi
fi

# --- Funcoes Core ---

check_internet() {
    log "Verificando conectividade..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        die "Sem conexao com a internet. Abortando."
    fi
}

system_update() {
    log "Iniciando atualizacao do sistema (DNF)..."
    if ! $SUDO dnf upgrade -y --refresh; then
        die "Falha critica na atualizacao do DNF."
    fi
    ok "Pacotes oficiais atualizados."
}

flatpak_update() {
    if command -v flatpak >/dev/null 2>&1; then
        log "Atualizando Flatpaks..."
        flatpak update -y || warn "Falha ao atualizar Flatpaks."
    fi
}

firmware_update() {
    if command -v fwupdmgr >/dev/null 2>&1; then
        log "Verificando atualizacoes de firmware..."
        $SUDO fwupdmgr get-updates 2>/dev/null || true
        $SUDO fwupdmgr update -y 2>/dev/null || warn "Nenhuma atualizacao de firmware disponivel."
    fi
}

cleanup_smart() {
    log "Iniciando limpeza inteligente..."

    # 1. Pacotes orfaos (autoremove)
    log "Removendo pacotes orfaos..."
    $SUDO dnf autoremove -y || warn "Falha ao remover orfaos."

    # 2. Cache do DNF
    log "Limpando cache do DNF..."
    $SUDO dnf clean packages || warn "Falha ao limpar cache."

    # 3. Journal (Logs do Systemd)
    log "Vacuuming logs do systemd (>50M)..."
    $SUDO journalctl --vacuum-size=50M >/dev/null 2>&1
}

check_needs_reboot() {
    log "Verificando se e necessario reiniciar..."
    if command -v needs-restarting >/dev/null 2>&1; then
        if needs-restarting -r >/dev/null 2>&1; then
            ok "Nenhum reinicio necessario."
        else
            warn "ATENCAO: Reinicio recomendado (kernel ou bibliotecas atualizados)."
        fi
    fi
}

# --- Main Execution ---

main() {
    clear
    echo "====================================================="
    echo "   FEDORA MAINTENANCE - $(hostname)"
    echo "====================================================="

    check_internet
    system_update
    flatpak_update
    cleanup_smart
    check_needs_reboot

    echo "====================================================="
    ok "Manutencao concluida."
    echo "====================================================="
}

main "$@"
