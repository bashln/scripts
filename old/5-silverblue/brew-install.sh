#!/bin/bash

echo -e "\n#-------------------- INICIANDO CONFIGURAÇÃO INICIAL --------------------#\n"
sleep 1

# Verificar e instalar o Homebrew se não estiver presente
if ! command -v brew &> /dev/null; then
    echo -e "\n[+] Homebrew não encontrado, instalando...\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo -e "\n[+] Homebrew já está instalado.\n"
fi

echo -e "\n[+] Atualizando Homebrew...\n"
brew update
brew upgrade

echo -e "\n[+] Instalando pacotes essenciais...\n"
brew install curl
brew install unzip
brew install git
brew install jq
brew install ntfs-3g
brew install gedit
brew install emacs
brew install alacritty
brew install vlc
brew install steam
brew install lutris
brew install goverlay
brew install pcmanfm-gtk3
brew install thunar
brew install feh
brew install wlogout
brew install numlockx
brew install gvfs
brew install dosbox
brew install samba
brew install xfce4-power-manager
brew install lxappearance
brew install flameshot
brew install wine
brew install winetricks
brew install vulkan-loader
brew install vulkan-tools
brew install zsh-fzf-plugin
brew install zsh-autosuggestions
brew install zsh-completions
brew install zsh-syntax-highlighting
brew install fzf
brew install neovim
brew install node
brew install python
brew install picom
brew install rofi
brew install dmenu

echo -e "\n[+] Instalando fontes...\n"
brew tap homebrew/cask-fonts
brew install --cask font-fira-code
brew install --cask font-jetbrains-mono
brew install --cask font-ubuntu

echo -e "\n[+] Instalando Neovide e suas dependências...\n"
brew install rust
cargo install --git https://github.com/neovide/neovide

echo -e "\n[+] Instalando suporte Flatpak e aplicativos (se aplicável, Flatpak é menos comum no macOS)...\n"
# Flatpak não é a forma idiomática de instalar aplicativos no macOS,
# mas se você realmente precisar, pode tentar instalar o pacote Flatpak
# e gerenciar os aplicativos Flatpak separadamente.
# Para aplicativos macOS, a Homebrew Cask é preferível.
# Se precisar de Flatpak:
# brew install flatpak
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak install flathub net.davidotek.pupgui2
# flatpak install flathub com.spotify.Client
# flatpak install flathub com.mattjakeman.ExtensionManager

# Alternativa macOS para os Flatpaks listados:
echo -e "\n[+] Instalando aplicativos via Homebrew Cask (alternativa Flatpak para macOS)...\n"
brew install --cask spotify
# Para outros aplicativos como 'pupgui2' e 'ExtensionManager', pode ser necessário
# procurá-los individualmente no Homebrew Cask ou alternativas nativas do macOS.
# Se não estiverem disponíveis via Homebrew Cask, talvez sejam apenas para Linux/Flatpak.

echo -e "\n[+] Configurando Oh-My-Zsh e plugins...\n"
# Oh-My-Zsh base installation (if not already installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Instalando Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh-My-Zsh já está instalado."
fi

# Zsh plugins
# Nota: Os plugins zsh já foram instalados via `brew install` acima.
# Apenas a parte do `git clone` é para verificar se o Oh-My-Zsh já tem esses repositórios.
# Removi as partes que clonam os plugins novamente, pois Homebrew já os instalou.
# A configuração dos plugins no ~/.zshrc ainda precisará ser feita manualmente ou por outro script.

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" || echo "powerlevel10k already exists, skipping clone."

echo -e "\n[+] Instalando Visual Studio Code...\n"
brew install --cask visual-studio-code

echo -e "\n[+] Configurando Git...\n"
read -rep "Digite seu email para Git: " git_email
read -rep "Digite seu nome para Git: " git_name
git config --global user.email "${git_email}"
git config --global user.name "${git_name}"

echo -e "\n[+] Instalando qtile-extras (se aplicável)...\n"
# Qtile é um gerenciador de janelas para Linux. Não é diretamente aplicável ao macOS.
# Se você estiver procurando por um gerenciador de janelas para macOS, o Homebrew
# pode ter alternativas, mas não "qtile" ou "qtile-extras".
# Se você realmente precisa de uma funcionalidade semelhante ou está executando Linux
# em uma VM/Docker no macOS, então o pip pode ser usado.
# brew install python
# pip3 install qtile-extras

echo -e "\n✅ Configuração inicial concluída com sucesso!\n"
