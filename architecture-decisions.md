<!-- markdownlint-disable MD013 -->

# Architecture Decisions (Seed)

## 1. Linguagem

Go foi escolhido para:

- Controle explícito de processos
- Manipulação robusta de stdout/stderr
- Facilidade para TUI moderna
- Binário único

## 2. TUI Framework

Bubble Tea será usado como base da interface.

Motivos:

- Arquitetura Model-View-Update previsível
- Comunidade ativa
- Controle fino da interação

## 3. Estrutura dos Scripts

Scripts deixarão de ser uma sequência linear.

Cada script será:

- Uma unidade isolada
- Chamado via exec.Command
- Independente dos demais

## 4. Execução

Execução será:

- Manual
- Sob demanda
- Controlada pelo usuário

Não haverá:

- Persistência
<!-- - Estado global complexo -->

## 5. Interatividade

Scripts que exigem interação (ex: PostgreSQL):

- Rodarão com stdin conectado ao terminal
- A TUI deve permitir fallback para modo interativo direto

## 6. Complexidade

Evitar:

- Plugins
  <!-- - Sistema de módulos dinâmicos -->
  <!-- - Configuração excessiva -->

A estrutura deve ser simples o suficiente para ser compreendida em 5 minutos.
