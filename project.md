# Bashln Install Scripts

## Objetivo

Reestruturar a antiga pasta `scripts-arch` em um sistema interativo baseado em TUI para executar, acompanhar e controlar scripts de instalação no Arch Linux.

O sistema permitirá:

- Executar scripts individualmente
- Visualizar saída em tempo real
- Interagir quando necessário (ex: PostgreSQL setup)
- Ativar ou desativar scripts antes da execução
- Rodar scripts sob demanda

## Escopo (MVP)

- Menu principal listando todos os scripts disponíveis
- Toggle de ativação/desativação por script
- Execução manual de scripts selecionados
- Visualização de stdout/stderr em tempo real
- Suporte a interação via stdin (quando necessário)

## Fora do Escopo

- Persistência de estado
- Execução automática em sequência
- Sistema de rollback
- Configuração avançada via arquivos externos
- Suporte a múltiplas distribuições

## Público-Alvo

Usuário único (autor do projeto), com foco em controle manual do ambiente Arch Linux.

## Filosofia

- Minimalismo estrutural
- Clareza acima de abstração
- Execução explícita > automação mágica
- Segurança e previsibilidade
- Manutenção solo

## Ambiente

- Arch Linux
- Go
- Bubble Tea
- Gum (para pequenas interações shell se necessário)
