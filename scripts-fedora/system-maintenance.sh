#!/bin/bash
# ==============================================================================
# SYSTEM MAINTENANCE - Rotina completa de manutencao do Fedora
# Combina DNF + Flatpak + Firmware + Limpeza em um unico script.
# ==============================================================================

set -euo pipefail

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DRY_RUN=false

# --- Parse de argumentos ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help)
            cat << EOF
Uso: $(basename "$0") [opcoes]

Opcoes:
  --dry-run    Mostra o que seria feito sem executar
  -h, --help   Mostra esta ajuda

Rotina completa:
  1. Atualiza metadados dos repositorios
  2. Atualiza pacotes DNF (sistema + RPM Fusion)
  3. Atualiza apps Flatpak
  4. Verifica atualizacoes de firmware
  5. Remove pacotes orfaos
  6. Limpa cache do DNF
  7. Limpa runtimes Flatpak nao utilizados
  8. Compacta logs do systemd
  9. Limpa cache de thumbnails
  10. Verifica arquivos .rpmnew/.rpmsave
  11. Verifica se reinicio e necessario
EOF
            exit 0
            ;;
        *) echo "Opcao desconhecida: $1"; exit 1 ;;
    esac
done

# --- Verificacao de Privilegios ---
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] $*"
    else
        "$@"
    fi
}

# --- Funcoes ---

check_internet() {
    log_info "Verificando conectividade..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_error "Sem conexao com a internet. Abortando."
        exit 1
    fi
    log_ok "Conectado."
}

update_dnf() {
    log_info "=== ATUALIZACAO DNF ==="

    log_info "Atualizando metadados..."
    run_cmd $SUDO dnf makecache --refresh

    log_info "Atualizando pacotes do sistema..."
    run_cmd $SUDO dnf upgrade -y --refresh

    log_ok "Pacotes DNF atualizados."
}

update_flatpak() {
    if ! command -v flatpak >/dev/null 2>&1; then
        log_warn "Flatpak nao instalado. Pulando."
        return
    fi

    log_info "=== ATUALIZACAO FLATPAK ==="
    run_cmd flatpak update -y
    log_ok "Flatpak atualizado."
}

update_firmware() {
    if ! command -v fwupdmgr >/dev/null 2>&1; then
        log_warn "fwupdmgr nao encontrado. Pulando firmware."
        return
    fi

    log_info "=== ATUALIZACAO DE FIRMWARE ==="
    run_cmd $SUDO fwupdmgr refresh --force 2>/dev/null || true
    run_cmd $SUDO fwupdmgr get-updates 2>/dev/null || true
    run_cmd $SUDO fwupdmgr update -y 2>/dev/null || log_warn "Nenhuma atualizacao de firmware disponivel."
}

cleanup_dnf() {
    log_info "=== LIMPEZA DNF ==="

    log_info "Removendo pacotes orfaos..."
    run_cmd $SUDO dnf autoremove -y

    log_info "Limpando cache de pacotes..."
    run_cmd $SUDO dnf clean packages

    log_ok "Cache DNF limpo."
}

cleanup_flatpak() {
    if ! command -v flatpak >/dev/null 2>&1; then
        return
    fi

    log_info "=== LIMPEZA FLATPAK ==="
    log_info "Removendo runtimes nao utilizados..."
    run_cmd flatpak uninstall --unused -y 2>/dev/null || log_warn "Nada para limpar."
    log_ok "Flatpak limpo."
}

cleanup_system() {
    log_info "=== LIMPEZA DO SISTEMA ==="

    # Journal
    log_info "Compactando logs do systemd (max 50M)..."
    run_cmd $SUDO journalctl --vacuum-size=50M >/dev/null 2>&1

    # Thumbnails
    log_info "Limpando cache de thumbnails..."
    if [ "$DRY_RUN" = false ]; then
        rm -rf "$HOME/.cache/thumbnails/"* 2>/dev/null || true
    else
        log_info "[DRY-RUN] rm -rf ~/.cache/thumbnails/*"
    fi

    # Cache de aplicacoes
    log_info "Limpando caches de aplicacoes..."
    if [ "$DRY_RUN" = false ]; then
        rm -rf "$HOME/.cache/mesa_shader_cache/"* 2>/dev/null || true
    else
        log_info "[DRY-RUN] rm -rf ~/.cache/mesa_shader_cache/*"
    fi

    log_ok "Limpeza do sistema concluida."
}

check_rpmconf() {
    log_info "=== VERIFICACAO DE CONFIGURACOES ==="

    local rpmnews
    rpmnews=$(find /etc -name "*.rpmnew" -o -name "*.rpmsave" 2>/dev/null || true)
    if [[ -n "$rpmnews" ]]; then
        log_warn "Arquivos de configuracao pendentes:"
        echo "$rpmnews"
        log_warn "Execute 'sudo rpmconf -a' para resolver."
    else
        log_ok "Nenhum arquivo .rpmnew/.rpmsave encontrado."
    fi
}

check_reboot() {
    log_info "=== VERIFICACAO DE REINICIO ==="

    if command -v needs-restarting >/dev/null 2>&1; then
        if needs-restarting -r >/dev/null 2>&1; then
            log_ok "Nenhum reinicio necessario."
        else
            log_warn "Reinicio recomendado (kernel ou bibliotecas atualizados)."
        fi
    fi
}

# --- Main ---
main() {
    clear
    echo "============================================================"
    echo "   FEDORA SYSTEM MAINTENANCE - $(hostname)"
    echo "   $(date '+%Y-%m-%d %H:%M:%S')"
    if [ "$DRY_RUN" = true ]; then
        echo "   >>> MODO DRY-RUN (nenhuma alteracao sera feita) <<<"
    fi
    echo "============================================================"
    echo ""

    check_internet
    echo ""
    update_dnf
    echo ""
    update_flatpak
    echo ""
    update_firmware
    echo ""
    cleanup_dnf
    echo ""
    cleanup_flatpak
    echo ""
    cleanup_system
    echo ""
    check_rpmconf
    echo ""
    check_reboot

    echo ""
    echo "============================================================"
    log_ok "Manutencao completa finalizada!"
    echo "============================================================"
}

main
