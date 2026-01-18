#!/bin/bash

# Define o diretório da biblioteca
LIB_LINE='SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\nsource "$SCRIPTS_DIR/lib/utils.sh"'

echo "Iniciando migração em massa..."

# Loop por todos os scripts .sh (exceto o install-all, utils e o próprio migrate)
for file in *.sh; do
    if [[ "$file" == "install-all.sh" ]] || [[ "$file" == "migrate.sh" ]] || [[ "$file" == "utils.sh" ]]; then
        continue
    fi
    
    echo "Processando: $file"

    # 1. Substituir install_pkg por ensure_package
    # O 's' é substitute, 'g' é global (todas as ocorrências)
    sed -i 's/install_pkg/ensure_package/g' "$file"

    # 2. Injetar o source da library log após o 'set -euo pipefail'
    # Se o script já tiver o source, isso pode duplicar, mas é fácil limpar depois
    if ! grep -q "lib/utils.sh" "$file"; then
        sed -i "/set -euo pipefail/a \\$LIB_LINE" "$file"
    fi

    # 3. Remover chamadas diretas ao pacman que não sejam necessárias
    # (Isso é mais arriscado, então vamos focar apenas em padronizar a função principal)
done

echo "Migração sintática concluída!"
echo "Agora precisamos limpar o código antigo (funções info, ok, warn...)."
