#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    info "Instalando PostgreSQL..."

    if rpm -q postgresql postgresql-server postgresql-contrib &>/dev/null; then
        ok "PostgreSQL ja instalado. Pulando instalacao."
        return 0
    fi

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
        if ! sudo postgresql-setup --initdb >> "$LOG_FILE" 2>&1; then
            fail "Falha ao inicializar o PostgreSQL. Verifique o log: $LOG_FILE"
            return 1
        fi
    else
        info "Diretorio de dados do PostgreSQL ja inicializado, pulando..."
    fi

    # Inicia e habilita o servico
    info "Iniciando servico PostgreSQL..."
    if ! sudo systemctl start postgresql >> "$LOG_FILE" 2>&1; then
        fail "Falha ao iniciar o PostgreSQL. Verifique o log: $LOG_FILE"
        return 1
    fi
    if ! sudo systemctl enable postgresql >> "$LOG_FILE" 2>&1; then
        fail "Falha ao habilitar o PostgreSQL. Verifique o log: $LOG_FILE"
        return 1
    fi

    # Aguarda PostgreSQL ficar pronto
    sleep 2

    # Cria usuario PostgreSQL correspondente ao usuario atual
    info "Configurando usuario PostgreSQL..."
    if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_user WHERE usename='$USER'" | grep -q 1; then
        if ! sudo -u postgres createuser --interactive -d "$USER" >> "$LOG_FILE" 2>&1; then
            fail "Falha ao criar usuario PostgreSQL. Verifique o log: $LOG_FILE"
            return 1
        fi
        ok "Usuario PostgreSQL criado: $USER"
    else
        ok "Usuario PostgreSQL $USER ja existe"
    fi

    # Cria banco de dados padrao
    if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$USER"; then
        if ! createdb "$USER" >> "$LOG_FILE" 2>&1; then
            fail "Falha ao criar banco de dados. Verifique o log: $LOG_FILE"
            return 1
        fi
        ok "Banco de dados padrao criado: $USER"
    else
        ok "Banco de dados $USER ja existe"
    fi

    ok "Instalacao e configuracao do PostgreSQL concluidas!"
    info "Voce pode se conectar ao PostgreSQL usando: psql"
}

main "$@"
