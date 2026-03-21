clear&&
sleep 2s
echo "#--------------------Iniciando atualização do sistema--------------------#"
echo ""

#sincroniza os repositórios do Manjaro Linux.
sudo pacman -Syy --noconfirm

#sincroniza os repositórios/procura por atualização
sudo pacman -Syu --noconfirm

#sincronização total/procura por atualização.
sudo pacman -Syyu --noconfirm

sleep 2s
echo "#--------------------Instalando pacotes essenciais--------------------#"
echo ""

sudo pacman -S --needed base-devel --noconfirm
sudo pacman -S alacritty --noconfirm
sudo pacman -S variety --noconfirm
sudo pacman -S lutris --noconfirm
sudo pacman -S wine --noconfirm
sudo pacman -S ttf-fira-code --noconfirm
sudo pacman -S vlc --noconfirm
sudo pacman -S steam

sleep 2s
echo "#--------------------Instalando pacotes AUR--------------------#"
echo ""

pamac install yay
yay -S paru --noconfirm
paru -S visual-studio-code-bin --noconfirm
paru -S microsoft-edge-stable-bin  --noconfirm
sudo pacman -Syu wine winetricks wine-mono wine_gecko vulkan-icd-loader lib32-vulkan-icd-loader vkd3d lib32-vkd3d gvfs --noconfirm
yay -S protonup-qt --noconfirm  

sleep 2s
echo "#--------------------Instalando drivers Nvidia 470xx--------------------#"
echo ""

#install nvidia drivers
paru -S linux515-headers
paru -S nvidia-470xx-dkms --needed --noconfirm

sleep 2s
echo "#--------------------Instalando pacotes flatpak--------------------#"
echo ""

#Flatpaks
sudo pacman -S flatpak --noconfirm
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.mattjakeman.ExtensionManager -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub com.discordapp.Discord -y
sleep 2s
echo "#--------------------Configurações para git commit--------------------#"
echo ""

#git config
git config --global user.email lpdmonteiro@gmail.com
git config --global user.name Leonam Monteiro

sleep 2s
echo "#--------------------Atualizando Sistema--------------------#"
echo ""

systemctl restart systemd-binfmt
#sincroniza os repositórios do Manjaro Linux.
sudo pacman -Syy --noconfirm

#sincroniza os repositórios/procura por atualização
sudo pacman -Syu --noconfirm

#sincronização total/procura por atualização.
sudo pacman -Syyu --noconfirm
