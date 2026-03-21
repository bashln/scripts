#!/bin/bash

# Define monitor parameters
MONITOR_NAME="DP-1"
RESOLUTION="1440x900"
REFRESH_RATE="75"
# Parameters for GRUB: remove rhgb and quiet, add video and keymap
GRUB_CMDLINE_PARAMS="video=${MONITOR_NAME}:${RESOLUTION}@${REFRESH_RATE} rd.vconsole.keymap=br-abnt2"

echo "Detectado que /boot/efi/loader/entries/ não existe."
echo "Assumindo que GRUB2 é o bootloader principal no Fedora."
echo "Configurando os parâmetros de vídeo para o GRUB2 no Fedora..."

# Function to update GRUB configuration
update_grub_cmdline() {
  GRUB_DEFAULT_FILE="/etc/default/grub"
  GRUB_CONFIG_FILE="/boot/grub2/grub.cfg" # Common path for Fedora

  if [[ ! -f "$GRUB_DEFAULT_FILE" ]]; then
    echo "Erro: Arquivo $GRUB_DEFAULT_FILE não encontrado. Verifique a instalação do GRUB."
    return 1
  fi

  echo "Modificando $GRUB_DEFAULT_FILE..."

  # Backup the original GRUB default file
  sudo cp "$GRUB_DEFAULT_FILE" "${GRUB_DEFAULT_FILE}.bak_$(date +%Y%m%d%H%M%S)"
  echo "Backup de $GRUB_DEFAULT_FILE criado em ${GRUB_DEFAULT_FILE}.bak_$(date +%Y%m%d%H%M%S)"

  # Use sed to update GRUB_CMDLINE_LINUX.
  # This command will:
  # 1. Ensure GRUB_CMDLINE_LINUX exists. If not, add it.
  # 2. Replace existing GRUB_CMDLINE_LINUX content with the new parameters,
  #    while preserving other critical parameters like root=UUID or rootflags if they exist.
  # We'll parse current /proc/cmdline for essential parameters that should remain.
  CURRENT_KERNEL_PARAMS=$(cat /proc/cmdline | sed -e 's/BOOT_IMAGE=[^ ]*//g' -e 's/initrd=[^ ]*//g' -e 's/\s\s*/ /g' | xargs)
  
  # Filter out specific parameters that we want to manage (rhgb, quiet, existing video, keymap)
  CLEANED_CURRENT_PARAMS=$(echo "$CURRENT_KERNEL_PARAMS" | sed -e 's/\srhgb//g' -e 's/\squiet//g' -e 's/video=[^ ]*//g' -e 's/rd.vconsole.keymap=[^ ]*//g' -e 's/\s\s*/ /g' | xargs)

  # Construct the new GRUB_CMDLINE_LINUX value
  NEW_GRUB_CMDLINE_VALUE="${CLEANED_CURRENT_PARAMS} ${GRUB_CMDLINE_PARAMS}"
  NEW_GRUB_CMDLINE_VALUE=$(echo "$NEW_GRUB_CMDLINE_VALUE" | xargs) # Clean up extra spaces

  # Use sed to replace or add the GRUB_CMDLINE_LINUX line
  if grep -q "^GRUB_CMDLINE_LINUX=" "$GRUB_DEFAULT_FILE"; then
    sudo sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$NEW_GRUB_CMDLINE_VALUE\"|" "$GRUB_DEFAULT_FILE"
  else
    # If GRUB_CMDLINE_LINUX does not exist, append it. This is unlikely for Fedora.
    echo "GRUB_CMDLINE_LINUX=\"$NEW_GRUB_CMDLINE_VALUE\"" | sudo tee -a "$GRUB_DEFAULT_FILE" > /dev/null
  fi

  echo "GRUB_CMDLINE_LINUX atualizado em $GRUB_DEFAULT_FILE: GRUB_CMDLINE_LINUX=\"$NEW_GRUB_CMDLINE_VALUE\""

  echo "Gerando novo arquivo de configuração do GRUB: $GRUB_CONFIG_FILE..."
  # For UEFI systems on Fedora, grub2-mkconfig is typically used
  if sudo grub2-mkconfig -o "$GRUB_CONFIG_FILE"; then
    echo "Configuração do GRUB atualizada com sucesso."
    echo "Por favor, reinicie para aplicar as alterações."
    echo "Verificação: Para confirmar se o parâmetro foi aplicado, após reiniciar, execute: cat /proc/cmdline"
    echo "Nota: A linha de comando pode não mostrar 'rhgb quiet' se foram removidos."
  else
    echo "Erro ao gerar a configuração do GRUB. Verifique os logs para mais detalhes."
    return 1
  fi
}

update_grub_cmdline

# Append installation instructions to the script itself
if ! grep -q "# Installation Instructions" "$0"; then
  cat << 'EOF' >> "$0"

# Installation Instructions
# To make this script executable:
# chmod +x display-fedora.sh

# To run this script:
# sudo ./display-fedora.sh

# After running, you MUST REBOOT for kernel parameters to take effect.

# If the kernel parameter method (via GRUB) does not work after reboot,
# and you are using Xorg, consider creating a systemd user service or a startup script
# for your desktop environment to execute the xrandr command on login.

# Example systemd user service for xrandr (if needed for Xorg persistence)
# 1. Create ~/.config/systemd/user/display-setup.service:
#    (Note: This is a user service, so it goes in ~/.config/systemd/user/)
#    [Unit]
#    Description=Set display resolution on user login
#    After=graphical-session.target

#    [Service]
#    ExecStart=/usr/bin/xrandr --output DP-1 --mode 1440x900 --rate 75
#    Type=oneshot
#    RemainAfterExit=yes

#    [Install]
#    WantedBy=graphical-session.target

# 2. Enable and start the user service:
#    systemctl --user daemon-reload
#    systemctl --user enable display-setup.service
#    systemctl --user start display-setup.service
#    (Note: This service runs on user login, not system boot, and requires an active user session)

EOF
fi
