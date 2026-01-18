#!/bin/bash
set -u # Não use 'set -e' aqui, pois queremos controlar as falhas manualmente

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="$BASE_DIR/install.log"

# Carrega a biblioteca
source "$BASE_DIR/lib/utils.sh"

# Arrays para relatório final
SUCCESS_STEPS=()
FAILED_STEPS=()

info "Iniciando instalação. Log completo em: $LOG_FILE"

# Mantém o sudo vivo em background
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

run_step() {
    local script="$1"
    local path="$BASE_DIR/$script"

    if [[ ! -x "$path" ]]; then
        warn "Script ignorado (não encontrado/não executável): $script"
        return
    fi

    info ">>> Executando módulo: $script"
    
    # Executa o script. Se precisar de root, o próprio script deve chamar sudo ou
    # podemos elevar aqui. Para simplificar, assumimos que o script gerencia seu sudo
    # ou herda se executarmos tudo como root (cuidado com makepkg).
    
    if "$path"; then
        ok "Módulo $script finalizado com sucesso."
        SUCCESS_STEPS+=("$script")
    else
        fail "Módulo $script FALHOU."
        FAILED_STEPS+=("$script")
    fi
}

# Lista de scripts (Exemplo reduzido)
STEPS=(
    "autofs.sh"
    "install-curl.sh"
    # ... adicione seus scripts aqui
)

# Loop Principal
for step in "${STEPS[@]}"; do
    run_step "$step"
done

# --- RELATÓRIO PÓS-AÇÃO (After Action Report) ---
echo ""
echo "=========================================="
echo "          RESUMO DA OPERAÇÃO              "
echo "=========================================="
echo "Log file: $LOG_FILE"
echo ""

if [ ${#SUCCESS_STEPS[@]} -gt 0 ]; then
    printf "${GREEN}Sucessos (${#SUCCESS_STEPS[@]}):${RESET}\n"
    printf "  - %s\n" "${SUCCESS_STEPS[@]}"
fi

echo ""

if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    printf "${RED}FALHAS (${#FAILED_STEPS[@]}):${RESET}\n"
    printf "  - %s\n" "${FAILED_STEPS[@]}"
    echo ""
    warn "Verifique o arquivo $LOG_FILE e procure por 'FAIL' ou erros do pacman."
    exit 1
else
    ok "Instalação completa sem erros!"
    exit 0
fi