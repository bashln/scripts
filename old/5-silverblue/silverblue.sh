#!/bin/bash

set -euo pipefail

# Cores
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[1;33m'
nc='\033[0m' # no color

clear
echo -e "${yellow}#-------------------- 🔁 Iniciando Atualização do Fedora Silverblue --------------------#${nc}\n"
sleep 2s

# Solicita sudo no início
echo -e "${yellow}🔑 Solicitando permissões de superusuário...${nc}"
if ! sudo -v; then
    echo -e "${red}❌ Falha ao obter permissões de superusuário. O script será encerrado.${nc}"
    exit 1
fi
echo -e "${green}✅ Permissões de superusuário obtidas.${nc}"

# Atualização do sistema base
echo -e "\n${yellow}🔄 Atualizando o sistema base com rpm-ostree...${nc}"
if sudo rpm-ostree upgrade; then
    echo -e "${green}✅ Sistema base atualizado ou já na versão mais recente.${nc}"
else
    echo -e "${red}❌ Erro ao atualizar o sistema base com rpm-ostree. Verifique a saída acima.${nc}"
    # Não vamos sair aqui, pois Flatpaks e Toolboxes podem ser atualizados independentemente.
fi

# Atualização dos Flatpaks
echo -e "\n${yellow}🔄 Atualizando pacotes Flatpak...${nc}"
if command -v flatpak &>/dev/null; then
    if flatpak update -y; then
        echo -e "${green}✅ Pacotes Flatpak atualizados com sucesso!${nc}"
    else
        echo -e "${red}❌ Erro ao atualizar pacotes Flatpak. Verifique a saída acima.${nc}"
    fi
else
    echo -e "${yellow}⚠️ Flatpak não encontrado. Pulei a atualização de Flatpaks.${nc}"
fi

# Atualização de Toolboxes
echo -e "\n${yellow}🔧 Atualizando Toolboxes (se houver)...${nc}"
if command -v toolbox &>/dev/null; then
    # Obtém a lista de todas as toolboxes ativas
    # O comando `toolbox list --containers` lista containers, então filtramos para obter apenas os nomes
    mapfile -t boxes < <(toolbox list --containers | awk '{print $1}' | tail -n +2)
    
    if [ "${#boxes[@]}" -eq 0 ]; then
        echo -e "${yellow}ℹ️ Nenhuma toolbox encontrada.${nc}"
    else
        for box in "${boxes[@]}"; do
            echo -e "\n${yellow}📦 Atualizando toolbox: ${box}${nc}"
            # Executa dnf upgrade dentro de cada toolbox
            if toolbox run -c "$box" sudo dnf upgrade --refresh -y; then
                echo -e "${green}✅ Toolbox '${box}' atualizada com sucesso!${nc}"
            else
                echo -e "${red}⚠️ Falha ao atualizar a toolbox '${box}'. Verifique a saída para detalhes.${nc}"
            fi
        done
    fi
else
    echo -e "${yellow}⚠️ Toolbox não encontrado. Pulei a atualização em containers.${nc}"
fi

# Limpeza de versões antigas do sistema
echo -e "\n${yellow}🧹 Limpando versões antigas do sistema (rpm-ostree)...${nc}"
if sudo rpm-ostree cleanup -prune; then
    echo -e "${green}✅ Limpeza de versões antigas concluída.${nc}"
else
    echo -e "${red}⚠️ Falha ao limpar versões antigas do rpm-ostree. Verifique a saída acima.${nc}"
fi

echo -e "\n${green}✅ Processo de atualização concluído!${nc}"
echo -e "${yellow}✨ Para aplicar todas as atualizações do sistema base, ${red}reinicie seu computador${yellow}.${nc}"
