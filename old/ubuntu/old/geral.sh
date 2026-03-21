sleep 2s
echo "#--------------------Iniciando atualização do sistema--------------------#"
echo ""
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
sleep 2s
echo "#--------------------Instalando Nvidia 470xx--------------------#"
echo ""
sudo apt install -y libnvidia-common-470
sudo apt install -y software-properties-gtk software-properties-common
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y nvidia-driver-470
sleep 2s
echo "#--------------------Instalando pacotes essenciais--------------------#"
echo ""
sudo system76-power graphics hybrid
sudo apt install -y libav
c-extra libdvd-pkg; sudo dpkg-reconfigure libdvd-pkg
sudo apt-get install -y ubuntu-restricted-extras
sudo apt install -y gnome-tweaks
# sudo apt install -y chrome-gnome-shell gnome-extensions-app
sudo apt install -y variety
sudo apt install -y alacritty
sudo apt install -y snapd
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
sleep 2s
echo "#--------------------Instalando pacotes flatpak--------------------#"
echo ""
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.mattjakeman.ExtensionManager -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub com.discordapp.Discord -y
flatpak install flathub com.microsoft.Edge -y
sleep 2s
echo "#--------------------Instalando steam e lutris--------------------#"
echo ""
sudo apt install steam -y
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt update -y
sudo apt install -y lutris
sleep 2s
echo "#--------------------Instalando grub e atualizando OS's--------------------#"
echo ""
sudo apt install -y os-prober
sudo update-grub
sleep 2s
echo "#--------------------Iniciando atualização do sistema--------------------#"
echo ""
git config --global user.email "lpdmonteiro@gmail.com"
git config --global user.name "Leonam Monteiro"
sudo dpkg --configure -a
sudo apt-get install -f -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo dpkg --configure -a
sudo apt-get install -f -y
flatpak update
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y
sleep 2s
echo "#--------------------Processo Finalizado!--------------------#"
echo ""
