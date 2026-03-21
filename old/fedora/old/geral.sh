#Prepare system to recieve programs
sudo dnf update -y
sudo dnf upgrade --refresh -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.visualstudio.code
#Finishing
sudo dnf update -y
sudo dnf upgrade --refresh -y
flatpak update -y

