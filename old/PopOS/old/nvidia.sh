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

# Mensagem de instalação do driver Nvidia
print_message "${blue}" "#-------------------- Instalando Nvidia 470xx --------------------#\n"

# Instalação do driver Nvidia
sudo apt install -y libnvidia-common-470
sudo apt install -y software-properties-gtk software-properties-common
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y nvidia-driver-470

# Aguardar 2 segundos antes de continuar
sleep 2s

