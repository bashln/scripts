
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
