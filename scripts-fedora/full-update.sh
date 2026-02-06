#!/bin/bash
# ==============================================================================
# SYSADMIN FULL UPDATE SCRIPT - FEDORA
# Foco: Estabilidade, Atualizacao completa com firmware e limpeza.
# Equivalente ao full-update.sh do Arch (com mirrors/keyrings).
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

refresh_metadata() {
    log "Atualizando metadados dos repositorios..."
    if ! $SUDO dnf makecache --refresh; then
        warn "Falha ao atualizar metadados. Continuando com cache existente."
    fi
    ok "Metadados atualizados."
}

check_rpmfusion() {
    log "Verificando repositorios RPM Fusion..."
    if rpm -q rpmfusion-free-release &>/dev/null && rpm -q rpmfusion-nonfree-release &>/dev/null; then
        ok "RPM Fusion (free + nonfree) habilitado."
        # Atualiza os pacotes do RPM Fusion tambem
        $SUDO dnf update -y rpmfusion-free-release rpmfusion-nonfree-release 2>/dev/null || true
    else
        warn "RPM Fusion nao esta habilitado. Alguns pacotes podem nao atualizar."
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
        $SUDO fwupdmgr refresh --force 2>/dev/null || true
        $SUDO fwupdmgr get-updates 2>/dev/null || true
        $SUDO fwupdmgr update -y 2>/dev/null || warn "Nenhuma atualizacao de firmware disponivel."
    fi
}

cleanup_smart() {
    log "Iniciando limpeza inteligente..."

    # 1. Pacotes orfaos (autoremove)
    log "Removendo pacotes orfaos..."
    $SUDO dnf autoremove -y || warn "Falha ao remover orfaos."

    # 2. Cache do DNF (mantemos metadados, limpamos pacotes baixados)
    log "Limpando cache de pacotes..."
    $SUDO dnf clean packages || warn "Falha ao limpar cache."

    # 3. Journal (Logs do Systemd)
    log "Vacuuming logs do systemd (>50M)..."
    $SUDO journalctl --vacuum-size=50M >/dev/null 2>&1

    # 4. Thumbnails antigos
    log "Limpando cache de thumbnails..."
    rm -rf "$HOME/.cache/thumbnails/*" 2>/dev/null || true
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

check_rpmconf() {
    log "Verificando arquivos de configuracao pendentes (.rpmnew/.rpmsave)..."
    if command -v rpmconf >/dev/null 2>&1; then
        local pending
        pending=$(rpmconf -a --test 2>/dev/null || true)
        if [[ -n "$pending" ]]; then
            warn "ATENCAO: Arquivos de configuracao pendentes detectados:"
            echo "$pending"
            warn "Execute 'sudo rpmconf -a' para resolver."
        else
            ok "Nenhum arquivo de configuracao pendente."
        fi
    else
        # Fallback: busca manual por .rpmnew e .rpmsave
        local rpmnews
        rpmnews=$(find /etc -name "*.rpmnew" -o -name "*.rpmsave" 2>/dev/null || true)
        if [[ -n "$rpmnews" ]]; then
            warn "ATENCAO: Arquivos .rpmnew/.rpmsave detectados:"
            echo "$rpmnews"
        else
            ok "Nenhum arquivo .rpmnew/.rpmsave encontrado."
        fi
    fi
}

# --- Main Execution ---

main() {
    clear
    echo "====================================================="
    echo "   FEDORA FULL MAINTENANCE - $(hostname)"
    echo "====================================================="

    check_internet
    refresh_metadata
    check_rpmfusion
    system_update
    flatpak_update
    firmware_update
    cleanup_smart
    check_rpmconf
    check_needs_reboot

    echo "====================================================="
    ok "Manutencao completa concluida. Reinicie se houve atualizacao de Kernel."
    echo "====================================================="
}

main "$@"
