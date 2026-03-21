sudo dnf update -y
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y
flatpak update
sudo rm /etc/dnf/preferences.d/nosnap.pref
sudo dnf update -y
sudo dnf install -y snapd
sudo dnf install -y snap 
sudo snap install spotify
sudo snap install thunderbird
sudo snap install discord
sudo snap install zoom-client
sudo dnf install -y variety
sudo dnf install -y numix-gtk-theme
sudo apt install -y numix-icon-theme
