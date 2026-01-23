#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando PostgreSQL..."
    ensure_aur_package "postgresql"

    # Check if data directory already exists and is initialized
    if [ ! -d "/var/lib/postgres/data" ] || [ -z "$(ls -A /var/lib/postgres/data 2>/dev/null)" ]; then
        info "Inicializando banco de dados PostgreSQL..."
        sudo -u postgres initdb -D /var/lib/postgres/data --locale=C.UTF-8 --encoding=UTF8 --data-checksums
    else
        info "Diretório de dados do PostgreSQL já inicializado, pulando..."
    fi

    # Start and enable PostgreSQL service
    info "Iniciando serviço PostgreSQL..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql

    # Wait for PostgreSQL to be ready
    sleep 2

    # Create a database user matching the current user if it doesn't exist
    info "Configurando usuário PostgreSQL..."
    if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_user WHERE usename='$USER'" | grep -q 1; then
        sudo -u postgres createuser --interactive -d "$USER"
        ok "Usuário PostgreSQL criado: $USER"
    else
        ok "Usuário PostgreSQL $USER já existe"
    fi

    # Create a default database for the user if it doesn't exist
    if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$USER"; then
        createdb "$USER"
        ok "Banco de dados padrão criado: $USER"
    else
        ok "Banco de dados $USER já existe"
    fi

    ok "Instalação e configuração do PostgreSQL concluídas!"
    info "Você pode se conectar ao PostgreSQL usando: psql"
}

main "$@"