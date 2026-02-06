#!/bin/bash
# ==============================================================================
# FLATPAK MANAGER - Gerenciador de aplicacoes Flatpak
# Facilita instalacao, remocao e manutencao de apps Flatpak.
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
  list              Lista todos os apps Flatpak instalados
  install <app_id>  Instala um app do Flathub
  remove  <app_id>  Remove um app Flatpak
  update            Atualiza todos os apps Flatpak
  search  <termo>   Busca apps no Flathub
  info    <app_id>  Mostra informacoes de um app
  cleanup           Remove runtimes e extensoes nao utilizados
  perms   <app_id>  Mostra permissoes de um app
  size              Mostra espaco usado por cada app

Exemplos:
  $(basename "$0") list
  $(basename "$0") install com.spotify.Client
  $(basename "$0") search spotify
  $(basename "$0") cleanup
  $(basename "$0") perms com.spotify.Client
EOF
}

check_flatpak() {
    if ! command -v flatpak >/dev/null 2>&1; then
        log_error "Flatpak nao esta instalado. Execute: sudo dnf install flatpak"
        exit 1
    fi
}

cmd_list() {
    log_info "Apps Flatpak instalados:"
    echo ""
    flatpak list --app --columns=application,name,version,size
}

cmd_install() {
    local app_id="$1"

    if flatpak info "$app_id" &>/dev/null; then
        log_ok "App '$app_id' ja instalado."
        return 0
    fi

    log_info "Instalando '$app_id' do Flathub..."
    if flatpak install -y flathub "$app_id"; then
        log_ok "App '$app_id' instalado."
    else
        log_error "Falha ao instalar '$app_id'."
        return 1
    fi
}

cmd_remove() {
    local app_id="$1"

    if ! flatpak info "$app_id" &>/dev/null; then
        log_warn "App '$app_id' nao esta instalado."
        return 0
    fi

    log_info "Removendo '$app_id'..."
    if flatpak uninstall -y "$app_id"; then
        log_ok "App '$app_id' removido."
    else
        log_error "Falha ao remover '$app_id'."
        return 1
    fi
}

cmd_update() {
    log_info "Atualizando todos os apps Flatpak..."
    if flatpak update -y; then
        log_ok "Todos os apps atualizados."
    else
        log_warn "Alguns apps podem nao ter atualizado."
    fi
}

cmd_search() {
    local term="$1"
    log_info "Buscando '$term' no Flathub..."
    echo ""
    flatpak search "$term"
}

cmd_info() {
    local app_id="$1"
    flatpak info "$app_id" 2>/dev/null || log_error "App '$app_id' nao encontrado."
}

cmd_cleanup() {
    log_info "Removendo runtimes e extensoes nao utilizados..."
    if flatpak uninstall --unused -y; then
        log_ok "Limpeza concluida."
    else
        log_warn "Nada para limpar."
    fi
}

cmd_perms() {
    local app_id="$1"
    log_info "Permissoes de '$app_id':"
    echo ""
    if command -v flatpak-spawn >/dev/null 2>&1; then
        flatpak info --show-permissions "$app_id" 2>/dev/null || log_error "Nao foi possivel obter permissoes."
    else
        flatpak info --show-permissions "$app_id" 2>/dev/null || log_error "Nao foi possivel obter permissoes."
    fi
}

cmd_size() {
    log_info "Espaco utilizado por apps Flatpak:"
    echo ""
    flatpak list --app --columns=application,name,size
    echo ""
    log_info "Total de runtimes:"
    flatpak list --runtime --columns=application,version,size | head -20
}

# --- Main ---
main() {
    check_flatpak

    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    local cmd="$1"
    shift

    case "$cmd" in
        list)    cmd_list ;;
        install)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") install <app_id>"; exit 1; }
            cmd_install "$1"
            ;;
        remove)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") remove <app_id>"; exit 1; }
            cmd_remove "$1"
            ;;
        update)  cmd_update ;;
        search)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") search <termo>"; exit 1; }
            cmd_search "$1"
            ;;
        info)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") info <app_id>"; exit 1; }
            cmd_info "$1"
            ;;
        cleanup) cmd_cleanup ;;
        perms)
            [[ $# -lt 1 ]] && { log_error "Uso: $(basename "$0") perms <app_id>"; exit 1; }
            cmd_perms "$1"
            ;;
        size)    cmd_size ;;
        -h|--help|help) usage ;;
        *)
            log_error "Comando desconhecido: $cmd"
            usage
            exit 1
            ;;
    esac
}

main "$@"
