#!/bin/bash

# Script para preparar Fedora com cache DNF automático atualizado e instalação rápida

# Inclui otimizações para downloads paralelos e outras melhorias de performance

DNF_CONF="/etc/dnf/dnf.conf"

echo "Atualizando todo o sistema (pode levar algum tempo)..."

sudo dnf update -y

echo "Configurando otimizações DNF..."

# Faz backup do dnf.conf antes
sudo cp "$DNF_CONF" "${DNF_CONF}.backup.$(date +%Y%m%d\_%H%M%S)"

# Ajusta ou adiciona as configurações otimizadas em dnf.conf
# Usamos awk para atualizar ou inserir as chaves desejadas

sudo awk -v parallel=10 '

    BEGIN {

        max_parallel_set=0;
        fastestmirror_set=0;
        metadata_expire_set=0;
        cache_set=0;

    }

    /^\[ \\t\]\*max_parallel_downloads \*=/ {
        print "max_parallel_downloads=" parallel;
        max_parallel_set=1; 
        next
    }

    /^\[ \\t\]\*fastestmirror \*=/ {
        print "fastestmirror=1";
        fastestmirror_set=1;
        next
    }

    /^\[ \\t\]\*metadata_expire \*=/ {
        print "metadata_expire=6h";
        metadata_expire_set=1;
        next
    }

    /^\[ \\t\]\*cache \*=/ {
        print "cache=1";
        cache_set=1;
        next
    }

    {print}

    END {
        if (!max_parallel_set)
            print "max_parallel_downloads=" parallel;
        if (!fastestmirror_set)
            print "fastestmirror=1";
        if (!metadata_expire_set)
            print "metadata_expire=6h";
        if (!cache_set)
            print "cache=1";
    }

' "$DNF_CONF" | sudo tee "$DNF_CONF.tmp" > /dev/null

sudo mv "$DNF_CONF.tmp" "$DNF_CONF"
sudo chmod 644 "$DNF_CONF"

echo "Configurações DNF atualizadas com:"
echo "  max_parallel_downloads=10"
echo "  fastestmirror=1"
echo "  metadata_expire=6h"
echo "  cache=1"
echo

echo "Habilitando e iniciando o timer dnf-makecache.timer para atualizar cache automaticamente..."

sudo systemctl enable --now dnf-makecache.timer

echo

echo "Verificando status do timer dnf-makecache.timer..."

systemctl status dnf-makecache.timer --no-pager

echo

echo "Listando próximos agendamentos do timer dnf-makecache..."

systemctl list-timers --all | grep dnf-makecache

echo

echo "Configuração concluída! Agora você pode usar:"
echo "  sudo dnf install nome-do-pacote"
echo "para instalar pacotes rapidamente usando o cache atualizado em segundo plano."
