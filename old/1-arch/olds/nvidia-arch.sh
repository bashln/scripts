#!/bin/bash
echo "#--------------------Instalando drivers Nvidia 470xx--------------------#"
echo ""

# #install linux headers for your current linux kernel (use uname -r to see current kernel version)

# sudo pacman -S linux515-headers --noconfirm

# #install nvidia drivers
# paru -S nvidia-470xx-dkms --noconfirm
# sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader libvdpau lib32-libvdpau opencl-nvidia lib32-opencl-nvidia libxnvctrl
sudo pacman -S linux61-headers --needed --noconfirm
sudo pacman -S nvidia-470xx-dkms --needed --noconfirm
sudo mkinitcpio -P
