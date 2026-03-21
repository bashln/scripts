#!/bin/bash

# Cores para melhorar a estética
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
nc='\033[0m' # Sem cor

# Função para exibir mensagens com cor
print_message() {
    echo -e "${1}${2}${nc}"
}

# Mensagem de atualização do sistema
print_message "${blue}" "#-------------------- Atualizando o sistema --------------------#\n"

# Atualização do sistema
sudo dpkg --configure -a
sudo apt-get install -f -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo dpkg --configure -a
sudo apt-get install -f -y
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y

# Atualização do Flatpak
print_message "${blue}" "\n#-------------------- Atualizando Flatpak --------------------#\n"
flatpak update

