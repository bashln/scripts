#!/bin/bash

set -euo pipefail

echo "🔧 Iniciando setup para Pop!_OS..."
echo "💡 Este script instalará pacotes úteis para terminal, dev e produtividade."

# Função auxiliar para instalar pacotes
instalar_pacotes() {
    echo -e "\n📦 Instalando: $*"
    sudo apt install -y "$@"
}

# Atualização básica
echo "🔄 Atualizando sistema..."
sudo apt update -y
sudo apt upgrade -y

# Repositórios adicionais (apt já tem boa cobertura, dnf-plugins-core não tem análogo direto aqui)
echo "➕ Verificando dependências comuns para repositórios adicionais..."
instalar_pacotes software-properties-common apt-transport-https ca-certificates

# Utilitários essenciais
instalar_pacotes \
    curl wget git rsync unzip bzip2 lsof \
    tree mtr traceroute netcat nmap tcpdump \
    neovim zsh bash-completion fzf ripgrep fd-find bat \
    man-db manpages less dos2unix

# Desenvolvimento
instalar_pacotes \
    build-essential cmake gdb \
    python3 python3-pip \
    rustc cargo \
    nodejs npm \
    rpm # rpm para compatibilidade de build, mas não é nativo do Debian/Ubuntu

# Acesso à rede
instalar_pacotes \
    openssh-client openssh-server \
    cifs-utils nfs-common net-tools dnsutils

# Gerenciador de containers
echo "🐳 Instalando Podman (útil para containerização)..."
# Podman pode não estar na versão mais recente ou mesmo nos reposit padrão do Pop!_OS.
# Para versões mais recentes, pode ser necessário adicionar um PPA ou usar o pacote Snap/Flatpak.
instalar_pacotes podman

# ZSH + LazyGit
echo "🐚 Instalando ZSH e LazyGit (para terminal aprimorado)..."
instalar_pacotes zsh lazygit

# Ativar zsh como shell padrão, se desejado
if [[ "$SHELL" != *zsh ]]; then
    echo "🎯 Alterando shell padrão para zsh (opcional)..."
    chsh -s /bin/zsh || echo "⚠️ Não foi possível alterar shell. Faça manualmente com: chsh -s /bin/zsh"
fi

# Alias úteis (opcional)
echo "🔧 Adicionando aliases úteis ao ~/.bashrc e ~/.zshrc..."
for file in ~/.bashrc ~/.zshrc; do
    cat <<'EOF' >>"$file"

# Alias Pop!_OS úteis
alias ll='ls -lah'
alias gs='git status'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
EOF
done

# Mensagem final
echo -e "\n✅ Setup finalizado com sucesso!"
echo "🔁 Reinicie a sessão do terminal ou rode 'exec zsh' para ativar ZSH (se alterado)."
