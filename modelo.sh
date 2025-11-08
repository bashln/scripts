
#!/bin/bash
set -euo pipefail

# =============================================================================
# Modelo padrão de script de instalação/configuração
# - Usa logs consistentes (info, ok, warn, fail)
# - É idempotente: pode ser executado várias vezes sem causar erros
# - Cada script deve executar uma única função clara (ex: instalar pacote X)
# =============================================================================

# --- Funções de log -----------------------------------------------------------
info()  { printf "\e[34m[*]\e[0m %s\n" "$*"; }
ok()    { printf "\e[32m[+]\e[0m %s\n" "$*"; }
warn()  { printf "\e[33m[!]\e[0m %s\n" "$*"; }
fail()  { printf "\e[31m[✗]\e[0m %s\n" "$*"; }

# --- Funções auxiliares ------------------------------------------------------
# Exemplo: verifica se um pacote já está instalado antes de instalar
install_pkg() {
  local pkg="$1"
  if pacman -Qi "$pkg" &>/dev/null; then
    ok "Pacote '$pkg' já está instalado."
  else
    info "Instalando '$pkg'..."
    if sudo pacman -S --noconfirm --needed "$pkg"; then
      ok "'$pkg' instalado com sucesso."
    else
      fail "Falha ao instalar '$pkg'."
    fi
  fi
}

# --- Função principal --------------------------------------------------------
main() {
  info "Iniciando script $(basename "$0")"

  # Exemplo de uso:
  # install_pkg curl
  # install_pkg git
  # curl -fsSL https://example.com/script.sh | bash

  ok "Script $(basename "$0") concluído com sucesso!"
}

# --- Execução ----------------------------------------------------------------
main "$@"


