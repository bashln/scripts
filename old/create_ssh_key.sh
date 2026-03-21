#!/bin/bash

echo -e "\n#-------------------- CRIANDO CHAVE SSH --------------------#\n"

# Define o diretório .ssh
SSH_DIR="$HOME/.ssh"
# Define o nome padrão do arquivo da chave (id_rsa ou id_ed25519)
KEY_FILE="${SSH_DIR}/id_ed25519" # Você pode mudar para id_ed25519 se preferir um algoritmo mais moderno

# Verifica se o diretório .ssh existe
if [ -d "$SSH_DIR" ]; then
    echo -e "[+] Diretório .ssh encontrado: $SSH_DIR"

    # Verifica se já existe um arquivo de chave privada
    if [ -f "$KEY_FILE" ]; then
        echo -e "[!] Chave SSH existente encontrada: $KEY_FILE"
        BACKUP_DIR="${SSH_DIR}/backup_$(date +%Y%m%d%H%M%S)"
        
        echo -e "[+] Movendo chave existente para diretório de backup: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv "${KEY_FILE}"* "$BACKUP_DIR/"
        echo -e "[+] Backup concluído."
    else
        echo -e "[+] Nenhuma chave SSH existente encontrada em $SSH_DIR. Prosseguindo com a criação."
    fi
else
    echo -e "[+] Diretório .ssh não encontrado. Criando: $SSH_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

echo -e "\n[+] Gerando nova chave SSH (pressione Enter para usar o local padrão e sem senha, ou defina um caminho/senha):"
ssh-keygen -t rsa -b 4096 -f "$KEY_FILE" -N "" # -N "" para sem senha; -t ed25519 para tipo de chave

echo -e "\n[+] Chave SSH pública criada:"
cat "${KEY_FILE}.pub"

echo -e "\n✅ Chave SSH criada com sucesso! Não se esqueça de adicionar a chave pública aos serviços que você usa (GitHub, GitLab, etc.)."
