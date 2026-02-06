#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando PostgreSQL..."

    packages=(
        "postgresql"
        "postgresql-server"
        "postgresql-contrib"
    )

    for pkg in "${packages[@]}"; do
        ensure_package "$pkg"
    done

    # No Fedora, usa-se postgresql-setup para inicializar
    if [ ! -d "/var/lib/pgsql/data" ] || [ -z "$(ls -A /var/lib/pgsql/data 2>/dev/null)" ]; then
        info "Inicializando banco de dados PostgreSQL..."
        sudo postgresql-setup --initdb
    else
        info "Diretorio de dados do PostgreSQL ja inicializado, pulando..."
    fi

    # Inicia e habilita o servico
    info "Iniciando servico PostgreSQL..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql

    # Aguarda PostgreSQL ficar pronto
    sleep 2

    # Cria usuario PostgreSQL correspondente ao usuario atual
    info "Configurando usuario PostgreSQL..."
    if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_user WHERE usename='$USER'" | grep -q 1; then
        sudo -u postgres createuser --interactive -d "$USER"
        ok "Usuario PostgreSQL criado: $USER"
    else
        ok "Usuario PostgreSQL $USER ja existe"
    fi

    # Cria banco de dados padrao
    if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$USER"; then
        createdb "$USER"
        ok "Banco de dados padrao criado: $USER"
    else
        ok "Banco de dados $USER ja existe"
    fi

    ok "Instalacao e configuracao do PostgreSQL concluidas!"
    info "Voce pode se conectar ao PostgreSQL usando: psql"
}

main "$@"
