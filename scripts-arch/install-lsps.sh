#!/bin/bash
set -euo pipefail

# Se o script utils.sh existir, use-o. Se não, as funções abaixo garantem que rode sozinho.
# SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source "$SCRIPTS_DIR/lib/utils.sh"

# =============================================================================
#  FUNÇÕES (Mantendo o seu padrão visual)
# =============================================================================

info() { printf "\e[34m[*]\e[0m %s\n" "$*"; }
ok() { printf "\e[32m[+]\e[0m %s\n" "$*"; }
warn() { printf "\e[33m[!]\e[0m %s\n" "$*"; }
fail() { printf "\e[31m[ ]\e[0m %s\n" "$*"; }

ensure_package() {
    local pkg="$1"
    # Verifica se o pacote já está instalado consultando o banco local do pacman
    if pacman -Qi "$pkg" &>/dev/null; then
        ok "Pacote '$pkg' já está instalado."
    else
        info "Instalando '$pkg'..."
        # --needed: redundância de segurança do pacman (não reinstala se já tiver)
        # --noconfirm: não pede confirmação (essencial para scripts)
        if sudo pacman -S --noconfirm --needed "$pkg"; then
            ok "'$pkg' instalado com sucesso."
        else
            fail "Falha ao instalar '$pkg'."
            exit 1 # Sai do script se falhar algo crítico
        fi
    fi
}

# =============================================================================
#  MAIN
# =============================================================================

main() {
    info "Iniciando instalação das ferramentas de formatação..."

    # Lista de pacotes para o Doom Emacs (Format + Lint)
    # Usamos um array para facilitar a manutenção
    local packages=(
        "ruff"       # Python formatter/linter (Rust)
        "prettier"   # JS/TS/CSS/HTML formatter
        "shfmt"      # Shell script formatter
        "shellcheck" # Shell script linter (ESSENCIAL, veja nota abaixo)
        "ripgrep"    # Busca rápida (Doom core)
        "fd"         # Find rápido (Doom core)
    )

    # Loop através do array instalando um por um
    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    # Explicando o erro anterior:
    # Antes você tinha apenas 'ruff'. O bash tentava rodar o comando 'ruff'.
    # Agora chamamos a função: ensure_package "ruff"

    echo ""
    ok "Script concluído! O Doom Emacs agora tem superpoderes de formatação."
}

main "$@"
