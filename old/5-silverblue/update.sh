#!/bin/bash

echo -e "\n#-------------------- INICIANDO ATUALIZAÇÃO COMPLETA --------------------#\n"

# Atualizando o sistema usando rpm-ostree
echo -e "\n[+] Atualizando o sistema usando rpm-ostree...\n"
sudo rpm-ostree upgrade
sudo rpm-ostree update

# Instalando o Homebrew (caso ainda não esteja instalado)
if ! command -v brew &>/dev/null; then
  echo -e "\n[+] Instalando Homebrew...\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Atualizando o Homebrew e os pacotes
echo -e "\n[+] Atualizando Homebrew e pacotes...\n"
brew update
brew upgrade

# Removendo pacotes antigos e versões desnecessárias
echo -e "\n[+] Limpando pacotes antigos...\n"
brew cleanup

echo -e "\n✅ Atualização completa concluída com sucesso!\n"
