#!/bin/bash

# Este script prepara o Fedora com cache DNF automático atualizado e instalação rápida.
# Inclui otimizações para downloads paralelos e outras melhorias de performance.

# --- Variáveis ---
DNF_CONF="/etc/dnf/dnf.conf"
BACKUP_DIR="/var/backups/dnf_config" # Diretório para backups

# --- Funções ---

# Função para verificar se o script está sendo executado como root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root. Por favor, use 'sudo'."
    exit 1
  fi
}

# Função para fazer backup do arquivo
backup_file() {
  local file_path="$1"
  local backup_name=$(basename "$file_path")
  local timestamp=$(date +%Y%m%d_%H%M%S)

  mkdir -p "$BACKUP_DIR"
  if [ -f "$file_path" ]; then
    cp -p "$file_path" "$BACKUP_DIR/${backup_name}.backup.${timestamp}"
    echo "Backup de '$file_path' criado em '$BACKUP_DIR/${backup_name}.backup.${timestamp}'."
  else
    echo "Aviso: O arquivo '$file_path' não foi encontrado. Nenhum backup foi criado."
  fi
}

# Função para configurar o DNF
configure_dnf() {
  echo "Configurando otimizações DNF no '$DNF_CONF'..."

  # Faz backup do dnf.conf antes das modificações
  backup_file "$DNF_CONF"

  # Criamos um arquivo temporário com as novas configurações e movemos para o lugar
  # Isso é mais seguro do que editar o arquivo in-place para operações complexas
  awk -v parallel=10 '
        BEGIN {
            # Flags para saber se as linhas já foram processadas
            found_parallel=0;
            found_fastestmirror=0;
            found_metadata_expire=0;
        }
        # Verifica se estamos na seção [main] ou se é o início do arquivo para inserir
        /^\[main\]/ {
            print; # Imprime a linha [main]
            # Se já encontramos as opções, não adicionamos novamente
            if (!found_parallel) { print "max_parallel_downloads=" parallel; found_parallel=1; }
            if (!found_fastestmirror) { print "fastestmirror=True"; found_fastestmirror=1; }
            if (!found_metadata_expire) { print "metadata_expire=6h"; found_metadata_expire=1; }
            next;
        }
        # Se a linha já existe, a substituímos
        /^[ \t]*max_parallel_downloads *=/ { $0="max_parallel_downloads=" parallel; found_parallel=1; }
        /^[ \t]*fastestmirror *=/ { $0="fastestmirror=True"; found_fastestmirror=1; }
        /^[ \t]*metadata_expire *=/ { $0="metadata_expire=6h"; found_metadata_expire=1; }
        
        { print } # Imprime todas as outras linhas
    ' "$DNF_CONF" >"${DNF_CONF}.tmp" && mv "${DNF_CONF}.tmp" "$DNF_CONF"

  # Garante permissões corretas
  chmod 644 "$DNF_CONF"

  echo "Configurações DNF atualizadas:"
  echo "  - max_parallel_downloads=10"
  echo "  - fastestmirror=True"
  echo "  - metadata_expire=6h"
}

# --- Execução Principal ---

check_root

echo "--- Preparando o Fedora para DNF rápido ---"

echo "1. Atualizando todo o sistema (pode levar algum tempo)..."
dnf update -y || {
  echo "Erro ao atualizar o sistema. Verifique sua conexão e tente novamente."
  exit 1
}
echo "Sistema atualizado."

echo "2. Limpando o cache DNF existente para aplicar as novas configurações..."
dnf clean all || { echo "Aviso: Falha ao limpar o cache DNF."; }
echo "Cache DNF limpo."

echo "3. Iniciando a configuração das otimizações do DNF..."
configure_dnf

echo "4. Habilitando e iniciando o timer 'dnf-makecache.timer' para atualizar o cache automaticamente..."
systemctl enable --now dnf-makecache.timer || {
  echo "Erro: Falha ao habilitar/iniciar 'dnf-makecache.timer'."
  exit 1
}
echo "'dnf-makecache.timer' habilitado e iniciado."

echo "---"
echo "Verificando o status do timer 'dnf-makecache.timer' para confirmar..."
systemctl status dnf-makecache.timer --no-pager

echo "---"
echo "Próximos agendamentos para 'dnf-makecache' (pode levar alguns segundos para aparecer):"
systemctl list-timers --all dnf-makecache.timer

echo "---"
echo "Configuração concluída! Seu DNF está otimizado para velocidade."
echo "Agora você pode usar: 'sudo dnf -C install nome-do-pacote' para instalações rápidas,"
echo "aproveitando o cache de metadados que será atualizado em segundo plano."
echo "---"

exit 0
