# Blueprint Estrutural - bashln-scripts

## Visao Geral do Projeto

**bashln-scripts** e uma colecao abrangente de scripts Bash para pos-instalacao e configuracao completa de ambientes Linux. O projeto automatiza a instalacao de ferramentas de desenvolvimento, linguagens de programacao, utilitarios e configuracoes pessoais, suportando multiplas distribuicoes Linux.

---

## Proposito Principal

O objetivo do projeto e facilitar a configuracao rapida e reprodutivel de novos ambientes de trabalho Linux, permitindo:

- Recriar rapidamente o ambiente de desenvolvimento completo
- Executar scripts individualmente ou em sequencia
- Evitar reinstalacoes desnecessarias atraves de idempotencia
- Manter scripts legiveis, simples e padronizados

---

## Distribuicoes Suportadas

### 1. Fedora Workstation (41+)

Diretorio: `scripts-fedora/`

- Gerenciador de pacotes: DNF
- Repositorios extras: COPR, RPM Fusion
- Suporte a Flatpak
- Container Distrobox para pacotes AUR

### 2. Arch Linux / CachyOS

Diretorio: `scripts-arch/`

- Gerenciador de pacotes: pacman
- Suporte a AUR (via yay/paru)
- Suporte a Flatpak

### 3. Pop!\_OS / Ubuntu (documentado, mas nao implementado)

- Gerenciador de pacotes: APT

---

## Estrutura de Diretorios

```
bashln-scripts/
|
+-- README.md                    # Documentacao principal
+-- README.org                   # Documentacao em formato Org-mode
+-- project.md                  # Planejamentos e objetivos do projeto
+-- current-state.md            # Estado atual do desenvolvimento
+-- blueprints.md                # Este arquivo
+-- .prettierrc                 # Configuracao de formatting
|
+-- docs/
|   +-- EQUIVALENCES.md         # Tabela comparativa pacman vs dnf
|   +-- MIGRATION.md            # Guia migracao Arch -> Fedora
|
+-- scripts-fedora/             # Scripts Fedora (mais completo)
|   +-- install-all.sh         # Orquestrador principal
|   +-- update.sh              # Atualizacao leve
|   +-- full-update.sh         # Atualizacao completa com firmware
|   +-- system-maintenance.sh  # Rotina completa de manutencao
|   +-- copr-manager.sh         # Gerenciador repos COPR
|   +-- flatpak-manager.sh      # Gerenciador apps Flatpak
|   +-- distrobox-setup.sh      # Container Arch para AUR
|   +-- fix-install-errors.sh   # Correcao de erros
|   +-- lib/
|   |   +-- utils.sh            # Biblioteca core (DNF/COPR)
|   +-- assets/
|   |   +-- install-*.sh       # 50+ scripts individuais
|   |   +-- configure-git.sh   # Configuracao Git
|   |   +-- set-shell.sh       # Define shell padrao
|   |   +-- autofs.sh          # Configuracao automount
|   |   +-- fix-services.sh    # Correcao servicos
|   |   +-- *.conf             # Arquivos de configuracao
|   +-- install.log            # Log de instalacao
|   +-- fail.log               # Log de falhas
|
+-- scripts-arch/               # Scripts Arch Linux
|   +-- install.sh             # Orquestrador principal
|   +-- update.sh              # Atualizacao
|   +-- full-update.sh         # Atualizacao completa
|   +-- lib/
|   |   +-- utils.sh           # Biblioteca core (pacman/AUR)
|   +-- assets/
|   |   +-- install-*.sh       # Scripts individuais
|   +-- backup_scripts/        # Scripts de backup/legado
|   +-- install.log
```

---

## Tecnologias e Ferramentas

### Gerenciadores de Pacotes

| Tecnologia | Descricao                        | Uso                 |
| ---------- | -------------------------------- | ------------------- |
| pacman     | Gerenciador Arch                 | scripts-arch        |
| dnf        | Gerenciador Fedora               | scripts-fedora      |
| yay/paru   | AUR Helper                       | scripts-arch        |
| copr       | Repositorios comunitarios Fedora | scripts-fedora      |
| rpmfusion  | Repositorio extras Fedora        | scripts-fedora      |
| flatpak    | Empacotamento universal          | Ambas distribuicoes |

### Ferramentas TUI

| Ferramenta  | Descricao                        | Uso                                 |
| ----------- | -------------------------------- | ----------------------------------- |
| Gum (Charm) | TUI para output colorido einners | Logging sp e feedback visual        |
| Bubble Tea  | Framework TUI em Go              | Planejado para interface interativa |

### Ferramentas de Container

| Ferramenta | Descricao         | Uso                            |
| ---------- | ----------------- | ------------------------------ |
| Distrobox  | Container Linux   | Executar pacotes AUR no Fedora |
| Podman     | Container runtime | Backend para Distrobox         |

### Linguagens e Runtimes Instalados

- Node.js (via install-nodejs.sh)
- Python (via install-python.sh)
- Rust/Cargo (via install-rust.sh)
- Ruby (via install-ruby.sh)
- Go (via install-go-tools.sh)
- PostgreSQL (via install-postgresql.sh)
- ASDF (version manager multi-linguagem)

### Aplicativos e Ferramentas

- **Terminal Emulators**: Alacritty, Kitty, Ghostty
- **Shells**: Zsh, Oh My Bash, Starship prompt
- **File Managers**: Yazi, Nautilus (GVFS)
- **Tools**: Git, LazyGit, Neovim, Emacs, VS Code, Tmux
- **Browsers**: Brave, Vivaldi, Microsoft Edge (Flatpak)
- **Multimedia**: VLC, Spotify (Flatpak), Steam
- **Development**: CMake, Node.js, NPM, Git, PostgreSQL
- **Fonts**: Fira Code, JetBrains Mono, Nerd Fonts

---

## Arquitetura de Scripts

### Biblioteca Core (lib/utils.sh)

Cada distribuicao possui sua propria implementacao da biblioteca utils.sh com funcoes equivalentes:

#### Funcoes de Logging

```bash
info()   # Log nivel INFO (azul)
ok()     # Log nivel OK (verde)
warn()   # Log nivel WARN (amarelo)
fail()   # Log nivel FAIL (vermelho)
die()    # Log erro e sai
```

#### Funcoes de Verificacao

```bash
# Fedora
ensure_package "pkg"              # Instala via DNF
ensure_group "grp"               # Instala grupo DNF
ensure_copr_package "repo" "pkg" # Habilita COPR + instala
ensure_flatpak_package "app"     # Instala Flatpak
ensure_rpmfusion                 # Habilita RPM Fusion
ensure_cargo_package "pkg"       # Instala via Cargo
ensure_npm_global "pkg"           # Instala via NPM global

# Arch
ensure_package "pkg"             # Instala via pacman
ensure_aur_package "pkg"         # Instala via AUR (yay)
ensure_flatpak_package "app"      # Instala Flatpak
```

### Orquestrador Principal (install-all.sh)

O script install-all.sh executa todos os scripts em uma ordem especifica e categorizada:

```bash
# Categorias de instalacao:
# 1. System Base & Core Utilities
# 2. RPM Fusion
# 3. Languages & Runtimes
# 4. Graphics, Multimedia & Drivers
# 5. Terminal Emulators & Shells
# 6. Networking & Storage
# 7. Browsers
# 8. Development Tools
# 9. Applications
# 10. Flatpak Applications
# 11. Desktop Environment Overrides
```

### Sistema de Logs

- **Log completo**: `install.log` - Todas as operacoes
- **Log de falhas**: `install-failures.log` - Apenas operacoes que falharam
- **Timestamp**: Formato `YYYY-MM-DD HH:MM:SS`
- **Cores**: Suporte a output colorido via ANSI ou Gum TUI

---

## Gerenciadores Dedicados

### COPR Manager (copr-manager.sh)

Equivalente ao AUR helper do Arch, gerencia repositorios COPR:

```bash
./copr-manager.sh list              # Lista repositorios
./copr-manager.sh search <termo>   # Busca pacotes
./copr-manager.sh install <repo> <pkg>  # Instala pacote
./copr-manager.sh enable <repo>    # Habilita repositorio
./copr-manager.sh disable <repo>   # Desabilita repositorio
```

### Flatpak Manager (flatpak-manager.sh)

Gerencia aplicacoes Flatpak:

```bash
./flatpak-manager.sh list          # Lista apps instalados
./flatpak-manager.sh search <termo>  # Busca no Flathub
./flatpak-manager.sh install <app>  # Instala app
./flatpak-manager.sh update         # Atualiza todos
./flatpak-manager.sh cleanup        # Remove nao utilizados
./flatpak-manager.sh size           # Espaco usado
```

### Distrobox Setup (distrobox-setup.sh)

Cria container Arch Linux para pacotes AUR sem equivalente Fedora:

```bash
./distrobox-setup.sh create         # Cria container
./distrobox-setup.sh install <pkg>  # Instala pacote AUR
./distrobox-setup.sh export <app>   # Exporta app para host
./distrobox-setup.sh remove         # Remove container
```

---

## Idempotencia

Todos os scripts seguem o principio de idempotencia:

- Se pacote ja esta instalado -> apenas registra e pula
- Se repositorio ja foi clonado -> atualiza com git pull
- Se configuracao ja existe -> nada e sobrescrito

Isso permite executar os scripts multiplas vezes sem causar erros ou reinstalacoes desnecessarias.

---

## Filosofia do Projeto

1. **Idempotencia**: rodar 100 vezes deve dar o mesmo resultado
2. **Legibilidade**: codigo simples > "magico"
3. **Autonomia**: cada script faz uma coisa so
4. **Logs claros**: sempre saber o que foi feito e o que falhou
5. **Reprodutibilidade**: do zero ao ambiente pronto em minutos
6. **Multi-distro**: mesma logica, adaptada para cada gerenciador

---

## COPR Repositorios Utilizados

| COPR           | Pacotes    | Descricao               |
| -------------- | ---------- | ----------------------- |
| atim/lazygit   | lazygit    | TUI Git client          |
| atim/yazi      | yazi       | Terminal file manager   |
| atim/starship  | starship   | Cross-shell prompt      |
| pgdev/ghostty  | ghostty    | Terminal emulator       |
| che/nerd-fonts | nerd-fonts | Fontes para programacao |

---

## Fluxo de Execucao Típico

### Fedora

```bash
cd scripts-fedora
chmod +x *.sh assets/*.sh

# Instalacao completa
./install-all.sh

# Atualizacao semanal
./update.sh

# Manutencao completa
./system-maintenance.sh --dry-run  # Preview
./system-maintenance.sh              # Executa
```

### Arch

```bash
cd scripts-arch
chmod +x *.sh assets/*.sh

# Instalacao
./install.sh

# Atualizacao
./update.sh
```

---

## Documentacao

- **docs/EQUIVALENCES.md**: Tabela completa de equivalencias entre comandos pacman e dnf
- **docs/MIGRATION.md**: Guia detalhado de migracao do Arch para Fedora
- **README.md**: Documentacao principal do projeto
- **README.org**: Documentacao em formato Org-mode

---

## Contribuicao

Para adicionar novos scripts:

1. Criar branch: `git checkout -b feature/novo-script`
2. Adicionar script no diretorio da distribuicao
3. Adicionar ao array STEPS em `install-all.sh`
4. Testar: `./assets/install-novo-script.sh`
5. Commit e pull request

---

## Licenca

MIT License - Use, modifique e compartilhe livremente.

---

## Estatisticas

- **~50 scripts de instalacao** no directorio assets (Fedora)
- **~45 scripts de instalacao** no directorio assets (Arch)
- **3 gerenciadores especializados**: COPR, Flatpak, Distrobox
- **2 implementacoes de utils.sh**: Fedora e Arch
- **Suporte a 3 distribuicoes**: Fedora, Arch, Ubuntu (documentado)
