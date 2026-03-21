clear &&
sleep 2s
echo "#--------------------Atualizando Pacman Mirrors-------------------->"
echo ""
sudo pacman-mirrors --fasttrack 20
sudo pacman -S archlinux-keyring --noconfirm
sudo pacman -Rns gedit --noconfirm
sudo pacman -Rdd webkit2gtk-5.0 --noconfirm
sudo pacman -Syu glibc-locales --overwrite /usr/lib/locale/\*/\* --noconfirm
sleep 2s
echo "#--------------------Iniciando atualização do sistema--------------------#"
echo ""
#sincronização total/procura por atualização.
sudo pacman -Syyu --noconfirm
#sincroniza os repositórios/procura por atualização
sudo pacman -Syu --noconfirm
sleep 2s
echo "#--------------------Instalando drivers Nvidia 470xx--------------------#"
echo ""
sudo pacman -S linux61-headers --needed --noconfirm
sudo pacman -S nvidia-470xx-dkms --needed --noconfirm
sudo pacman -S nvidia-470xx-settings --needed --noconfirm
sleep 2s
echo "#--------------------Instalando pacotes essenciais--------------------#"
echo ""
sudo pacman -S gedit --noconfirm --needed
sudo pacman -S base-devel --noconfirm --needed
sudo pacman -S lutris --noconfirm --needed
sudo pacman -S wine winetricks wine-mono wine_gecko vulkan-icd-loader lib32-vulkan-icd-loader vkd3d lib32-vkd3d gvfs --noconfirm --needed
sudo pacman -S lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse lib32-alsa-lib lib32-libxcomposite lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs lib32-sdl2 samba dosbox --noconfirm --needed
sudo pacman -S ttf-fira-code --noconfirm --needed
sudo pacman -S vlc --noconfirm --needed
sudo pacman -S steam --noconfirm --needed
sudo pacman -S gedit --noconfirm --needed
sleep 2s
echo "#--------------------Instalando pacotes AUR--------------------#"
echo ""
pamac install yay
yay -S visual-studio-code-bin --noconfirm --needed
sleep 2s
echo "#--------------------Instalando pacotes flatpak--------------------#"
echo ""
#Flatpaks
sudo pacman -S flatpak --noconfirm --needed
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --system install flathub com.mattjakeman.ExtensionManager -y
flatpak --system install flathub net.davidotek.pupgui2 -y
flatpak --system install flathub com.spotify.Client -y
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
#sincroniza os repositórios/procura por atualização
sudo pacman -Syu --noconfirm
