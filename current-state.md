<!-- markdownlint-disable MD013 -->

# Current State

O MVP (Minimum Viable Product) foi concluído, auditado e aprovado para produção. O sistema antigo foi substituído por uma ferramenta moderna em Go que oferece controle total e visibilidade sobre o processo de instalação.

## Sistema Atual (TUI Go)

- **Base Tecnológica**: Go, Bubble Tea e Lipgloss.
- **Interface**: TUI interativa com tema Catppuccin Mocha e fallback automático para terminais monocromáticos.
- **Arquitetura**: Modularizada com separação entre UI, Runner de processos e Discovery de scripts.
- **Robustez**: Cancelamento por grupo de processos (evita processos órfãos) e validação estrita de caminhos.
- **Navegação**: Menu Inicial com acesso rápido a Instalação, Configurações e Sair.

## O que funciona

- [x] **Discovery Automático**: Scripts listados dinamicamente a partir do `install.sh` original.
- [x] **Seleção Flexível**: Toggle de ativação/desativação por item ou global (tecla 'a').
- [x] **Execução Controlada**: Fila de execução manual com feedback de progresso em tempo real.
- [x] **Output Live**: Visualização de stdout/stderr sem travamento da interface.
- [x] **Suporte Interativo**: Scripts que pedem input (como Git ou PostgreSQL) funcionam via attach de TTY.
- [x] **Idempotência**: Scripts revisados e corrigidos para permitir múltiplas execuções sem erro.
- [x] **Logging**: Registro consolidado de todas as operações em `install.log`.
- [x] **Segurança**: Tratamento de permissões root (sudo) com preservação de ambiente.
- [x] **Menu Inicial**: Tela principal com opções (Instalar pacotes / Configurações / Sair).
- [x] **Detecção de Sistema**: Identificação automática da distribuição Linux via `/etc/os-release`.
- [x] **Navegação Intuitiva**: Atalhos estilo Vim (j/k) + setas + Enter/Esc para navegação.

## O que foi concluído

- [x] Adicionar cores e um UI/UX mais refinado (Tema Catppuccin)
- [x] Verificar se os instaladores podem ser rodados repetidas vezes sem dar erro (Idempotência validada)
- [x] Implementar navegação avançada (Viewport, paginação, Home/End)
- [x] Implementar sistema de cancelamento robusto
- [x] **Criar Menu Inicial com seções dedicadas (Instalar / Configurações / Sair)**

## Próximos passos (Pós-MVP)

- [ ] Limpeza de arquivos legados na pasta `scripts-arch/backup_scripts/`.
- [ ] Implementar rotação de logs para o arquivo `install.log`.
- [ ] Adicionar mais informações na tela de Configurações (versão, atalhos, etc).
