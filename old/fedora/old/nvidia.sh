# #Install Nvidia driver
# sudo dnf update -y # and reboot if you are not on the latest kernel
# sudo dnf install -y akmod-nvidia # rhel/centos users can use kmod-nvidia instead
# sudo dnf install -y xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
#Uninstall Nvidia driver
#sudo dnf update -y # and reboot if you are not on the latest kernel
#sudo dnf remove -y akmod-nvidia # rhel/centos users can use kmod-nvidia instead
#sudo dnf remove -y xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
#sudo dnf install xorg-x11-drv-nvidia-470xx akmod-nvidia-470xx xorg-x11-drv-nvidia-470xx-cuda
sudo dnf install -y kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
sudo dnf install -y xorg-x11-drv-nvidia-470xx akmod-nvidia-470xx xorg-x11-drv-nvidia-470xx-cuda xorg-x11-drv-nvidia-470xx-cuda-libs.i686 xorg-x11-drv-nvidia-470xx-cuda-libs.x86_64 xorg-x11-drv-nvidia-470xx-libs.i686 xorg-x11-drv-nvidia-470xx-libs.x86_64 nvidia-settings-470xx.x86_64 xorg-x11-drv-nvidia-470xx-power.x86_64
