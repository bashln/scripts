##Setup Snap
sudo rm /etc/apt/preferences.d/nosnap.pref
sudo apt update -y
sudo apt install snapd -y
sudo apt install snap -y
sudo apt update -y
sudo snap refresh
#Snap Store
sudo snap install snap-store
sudo apt update -y
##Setup Zoom
sudo snap install zoom-client
##Setup Notion
sudo snap install -y notion-snap
##Setup Spotify
sudo snap install spotify
##Setup Thunderbird
sudo snap install thunderbird
##Setup Discord
sudo snap install discord
##Setup Steam
sudo snap install steam
##Setup OnlyOffice
sudo snap install onlyoffice
##Setup Lutris
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt update -y
sudo apt install lutris -y
##Finishing
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
