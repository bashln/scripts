#!/bin/bash

# Definindo cores para melhorar a estética
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
nc='\033[0m' # Sem cor

# Função para exibir mensagens com cor
print_message() {
    echo -e "${1}${2}${nc}"
}

# Função para atualizar o sistema
update_system() {
    print_message "${blue}" "#-------------------- Iniciando atualização do sistema --------------------#\n"
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
}

# Função para instalar o driver Nvidia
#install_nvidia_driver() {
#    print_message "${blue}" "\n#-------------------- Instalando Nvidia 470xx #--------------------#\n"
#    sudo apt install -y libnvidia-common-470
#    sudo apt install -y software-properties-gtk software-properties-common
#    sudo apt-get update -y
#    sudo apt-get upgrade -y
#    sudo apt install -y software-properties-common
#    sudo add-apt-repository ppa:graphics-drivers/ppa
#    sudo apt-get update -y
#    sudo apt-get upgrade -y
#    sudo apt-get install -y nvidia-driver-470
#}

# Função para instalar pacotes essenciais
install_essential_packages() {
    print_message "${blue}" "\n#-------------------- Instalando pacotes essenciais --------------------#\n"
    sudo system76-power graphics hybrid
    sudo apt install -y libav
    sudo apt-get install -y ubuntu-restricted-extras
    sudo apt install -y gnome-tweaks
    sudo apt install -y code
    # sudo apt install -y chrome-gnome-shell gnome-extensions-app
    sudo apt install -y variety
    sudo apt install -y alacritty
    sudo apt install -y snapd
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
    sudo apt-get install -y nodejs
}

# Função para instalar pacotes Flatpak
install_flatpak_packages() {
    print_message "${blue}" "\n#-------------------- Instalando pacotes Flatpak --------------------#\n"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.mattjakeman.ExtensionManager -y
    flatpak install flathub com.spotify.Client -y
    flatpak install flathub com.discordapp.Discord -y
    flatpak install flathub com.microsoft.Edge -y
}

# Função para instalar Steam e Lutris
install_steam_and_lutris() {
    print_message "${blue}" "\n#-------------------- Instalando Steam e Lutris --------------------#\n"
    sudo apt install steam -y
    sudo add-apt-repository -y ppa:lutris-team/lutris
    sudo apt update -y
    sudo apt install -y lutris
}

# Função para instalar o Grub e atualizar OS's
install_grub_and_update_os() {
    print_message "${blue}" "\n#-------------------- Instalando Grub e atualizando OS's --------------------#\n"
    sudo apt install -y os-prober
    sudo update-grub
}

# Início do script
update_system
#install_nvidia_driver
install_essential_packages
install_flatpak_packages
install_steam_and_lutris
install_grub_and_update_os

# Mensagem de finalização
print_message "${blue}" "\n#-------------------- Processo Finalizado! --------------------#\n"

