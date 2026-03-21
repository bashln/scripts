#!/bin/bash

set -euo pipefail

echo "🔧 Iniciando setup para Fedora no WSL2..."
echo "💡 Este script instalará pacotes úteis para terminal, dev e produtividade."

# Função auxiliar para instalar pacotes
instalar_pacotes() {
    echo -e "\n📦 Instalando: $*"
    sudo dnf install -y "$@"
}

# Atualização básica
echo "🔄 Atualizando sistema..."
sudo dnf upgrade -y

# Repositórios adicionais (se necessário)
echo "➕ Verificando dnf-plugins-core..."
instalar_pacotes dnf-plugins-core

# Utilitários essenciais
instalar_pacotes \
    curl wget git rsync unzip bzip2 lsof \
    tree mtr traceroute nc nmap tcpdump \
    neovim zsh bash-completion fzf ripgrep fd-find bat \
    man-db man-pages less dos2unix

# Desenvolvimento
instalar_pacotes \
    gcc make cmake gdb \
    python3 python3-pip \
    rust cargo \
    nodejs npm \
    rpm-build

# Acesso à rede
instalar_pacotes \
    openssh-clients openssh-server \
    cifs-utils nfs-utils net-tools bind-utils

# Gerenciador de containers
echo "🐳 Instalando Podman (útil no WSL2 para containerização)..."
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

# Alias WSL2 úteis
alias ll='ls -lah'
alias gs='git status'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
EOF
done

# Mensagem final
echo -e "\n✅ Setup finalizado com sucesso!"
echo "🔁 Reinicie a sessão do terminal ou rode 'exec zsh' para ativar ZSH (se alterado)."
