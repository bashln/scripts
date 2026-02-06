#!/bin/bash
# ==============================================================================
# COPR MANAGER - Gerenciador de repositorios COPR para Fedora
# Equivalente conceitual ao AUR helper do Arch Linux.
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

usage() {
    cat << EOF
Uso: $(basename "$0") <comando> [opcoes]

Comandos:
  list              Lista todos os repositorios COPR habilitados
  enable  <repo>    Habilita um repositorio COPR (owner/project)
  disable <repo>    Desabilita um repositorio COPR
  remove  <repo>    Remove um repositorio COPR
  search  <termo>   Busca pacotes em COPR
  install <repo> <pkg>  Habilita COPR e instala pacote
  info    <repo>    Mostra informacoes de um repositorio COPR

Exemplos:
  $(basename "$0") list
  $(basename "$0") enable atim/lazygit
  $(basename "$0") install atim/lazygit lazygit
  $(basename "$0") search yazi
  $(basename "$0") disable atim/lazygit
EOF
}

cmd_list() {
    log_info "Repositorios COPR habilitados:"
    echo ""
    dnf copr list 2>/dev/null || log_warn "Nenhum repositorio COPR habilitado."
}

cmd_enable() {
    local repo="$1"
    log_info "Habilitando COPR: $repo..."
    if sudo dnf copr enable -y "$repo"; then
        log_ok "COPR '$repo' habilitado."
    else
        log_error "Falha ao habilitar COPR '$repo'."
        return 1
    fi
}

cmd_disable() {
    local repo="$1"
    log_info "Desabilitando COPR: $repo..."
    if sudo dnf copr disable -y "$repo"; then
        log_ok "COPR '$repo' desabilitado."
    else
        log_error "Falha ao desabilitar COPR '$repo'."
        return 1
    fi
}

cmd_remove() {
    local repo="$1"
    log_info "Removendo COPR: $repo..."
    if sudo dnf copr remove -y "$repo"; then
        log_ok "COPR '$repo' removido."
    else
        log_error "Falha ao remover COPR '$repo'."
        return 1
    fi
}

cmd_search() {
    local term="$1"
    log_info "Buscando '$term' em COPR..."
    echo ""
    dnf copr search "$term" 2>/dev/null || log_warn "Nenhum resultado encontrado."
}

cmd_install() {
    local repo="$1"
    local pkg="$2"

    if rpm -q "$pkg" &>/dev/null; then
        log_ok "Pacote '$pkg' ja instalado."
        return 0
    fi

    log_info "Habilitando COPR '$repo' e instalando '$pkg'..."
    sudo dnf copr enable -y "$repo" 2>/dev/null || true
    if sudo dnf install -y "$pkg"; then
        log_ok "Pacote '$pkg' instalado via COPR '$repo'."
    else
        log_error "Falha ao instalar '$pkg'."
        return 1
    fi
}

cmd_info() {
    local repo="$1"
    log_info "Informacoes do COPR: $repo"
    echo ""
    dnf copr search "$repo" 2>/dev/null || log_warn "Repositorio nao encontrado."
}

# --- Main ---
main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    local cmd="$1"
    shift

    case "$cmd" in
        list)
            cmd_list
            ;;
        enable)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") enable <owner/project>"; exit 1; }
            cmd_enable "$1"
            ;;
        disable)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") disable <owner/project>"; exit 1; }
            cmd_disable "$1"
            ;;
        remove)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") remove <owner/project>"; exit 1; }
            cmd_remove "$1"
            ;;
        search)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") search <termo>"; exit 1; }
            cmd_search "$1"
            ;;
        install)
            [[ $# -lt 2 ]] && { log_error "Uso: $(basename "$0") install <owner/project> <pacote>"; exit 1; }
            cmd_install "$1" "$2"
            ;;
        info)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") info <owner/project>"; exit 1; }
            cmd_info "$1"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            log_error "Comando desconhecido: $cmd"
            usage
            exit 1
            ;;
    esac
}

main "$@"
