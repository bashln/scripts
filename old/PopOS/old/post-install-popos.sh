#!/bin/bash
echo -e "\n#-------------------- INICIANDO CONFIGURAÇÃO INICIAL --------------------#\n"
sleep 1

echo -e "\n[+] Acelerando APT (análogo ao DNF)... Não é tão comum ou necessário no APT quanto no DNF.\n"
# APT não tem opções diretas como 'fastestmirror' ou 'max_parallel_downloads' como DNF.
# Aceleração geralmente envolve o uso de espelhos locais ou a escolha de um espelho mais rápido no sources.list.

echo -e "\n[+] Atualizando sistema pela primeira vez...\n"
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y # Equivale a 'dnf distro-sync' em termos de resolução de dependências

echo -e "\n[+] Instalando pacotes essenciais...\n"
sudo apt install -y \
  curl unzip git jq build-essential \
  ntfs-3g gedit emacs \
  fonts-firacode fonts-jetbrains-mono fonts-ubuntu \
  alacritty vlc steam lutris goverlay \
  pcmanfm thunar feh wlogout numlockx \
  gvfs dosbox samba xfce4-power-manager lxappearance flameshot

echo -e "\n[+] Instalando bibliotecas para Wine/Gaming...\n"
sudo dpkg --add-architecture i386 # Habilita arquitetura de 32 bits para Wine
sudo apt update
sudo apt install -y \
  wine wine-stable winetricks wine-mono wine-gecko \
  vulkan-loader vulkan-tools \
  libgl1-mesa-glx:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
  libgif7:i386 libgnutls30:i386 libv4l-0:i386 libpulse0:i386 \
  libasound2:i386 libxcomposite1:i386 libxinerama1:i386 \
  opencl-headers libgstreamer-plugins-base1.0-0:i386 libsdl2-2.0-0:i386 \
  mesa-dri-drivers \
  zsh-fzf zsh-autosuggestions \
  zsh-completion zsh-syntax-highlighting \
  fzf neovim nodejs python3 picom rofi dmenu

echo -e "\n[+] Instalando suporte Flatpak e aplicativos...\n"
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
  net.davidotek.pupgui2 \
  com.spotify.Client \
  com.mattjakeman.ExtensionManager

echo -e "\n[+] Instalando Visual Studio Code...\n"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# Optional: qtile-extras (uncomment and adjust if you need it and know the installation method)
# echo -e "\n[+] Installing qtile-extras (if available via APT or pip)...\n"
# sudo apt install -y python3-pip # If you plan to install via pip
# pip install qtile-extras # Consider virtual environments for Python packages

echo -e "\n✅ Configuração inicial concluída com sucesso!\n"
