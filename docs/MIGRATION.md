# Guia de Migracao: Arch Linux -> Fedora Workstation

Guia completo para migrar do CachyOS/Arch Linux para Fedora Workstation 41+.

---

## Indice

1. [Visao Geral](#visao-geral)
2. [Pre-requisitos](#pre-requisitos)
3. [Estrutura dos Scripts](#estrutura-dos-scripts)
4. [Primeiros Passos no Fedora](#primeiros-passos-no-fedora)
5. [Gerenciamento de Pacotes](#gerenciamento-de-pacotes)
6. [Repositorios Extras](#repositorios-extras)
7. [Casos Especiais](#casos-especiais)
8. [FAQ e Troubleshooting](#faq-e-troubleshooting)

---

## Visao Geral

### O que muda

| Aspecto | Arch Linux | Fedora |
|---------|-----------|--------|
| Package Manager | pacman | dnf |
| AUR helper | paru / yay | dnf copr |
| Release model | Rolling | Semi-anual (6 meses) |
| Init system | systemd | systemd (igual) |
| Pacotes extras | AUR | COPR, RPM Fusion, Flatpak |
| Config pendentes | .pacnew | .rpmnew / .rpmsave |
| 32-bit libs | lib32-* | *.i686 |

### O que NAO muda

- Shell scripts (bash/zsh) funcionam igual
- Systemd services, timers, mounts
- Dotfiles e configs do usuario (~/.config/*)
- Flatpak apps
- Docker / Podman
- Git workflows

---

## Pre-requisitos

Antes de usar os scripts Fedora, certifique-se de ter:

```bash
# Minimo necessario (ja vem com Fedora)
sudo dnf install -y git curl

# Para usar os scripts de instalacao
git clone <repo-url>
cd scripts/scripts-fedora
chmod +x *.sh assets/*.sh
```

---

## Estrutura dos Scripts

```
scripts-fedora/
├── install-all.sh          # Orquestrador principal
├── update.sh               # Atualizacao leve do sistema
├── full-update.sh           # Atualizacao completa (mirrors + firmware)
├── copr-manager.sh          # Gerenciador de repos COPR
├── flatpak-manager.sh       # Gerenciador de apps Flatpak
├── distrobox-setup.sh       # Container Arch para pacotes AUR orfaos
├── system-maintenance.sh    # Rotina completa de manutencao
├── lib/
│   └── utils.sh            # Biblioteca core (ensure_package, logs, etc)
└── assets/
    ├── install-*.sh         # Scripts individuais de instalacao
    ├── configure-git.sh     # Configuracao do Git
    ├── set-shell.sh         # Define shell padrao
    ├── autofs.sh            # Configuracao de automount
    └── fix-services.sh      # Correcao de servicos
```

### Funcoes da lib/utils.sh

| Funcao | Descricao | Equivalente Arch |
|--------|-----------|------------------|
| `ensure_package "pkg"` | Instala via DNF se nao instalado | `ensure_package` (pacman) |
| `ensure_group "grupo"` | Instala grupo DNF | `pacman -S base-devel` |
| `ensure_copr_package "repo" "pkg"` | Habilita COPR + instala | `ensure_aur_package` (yay) |
| `ensure_flatpak_package "app"` | Instala via Flatpak | `ensure_flatpak_package` (igual) |
| `ensure_rpmfusion` | Habilita RPM Fusion free+nonfree | N/A |

---

## Primeiros Passos no Fedora

### 1. Instalar tudo automaticamente

```bash
cd scripts-fedora
./install-all.sh
```

### 2. Ou instalar modulos individualmente

```bash
# Exemplo: apenas ferramentas de dev
./assets/install-dev-tools.sh
./assets/install-git.sh
./assets/install-nodejs.sh
./assets/install-rust.sh
```

### 3. Atualizacao do sistema

```bash
# Atualizacao rapida
./update.sh

# Atualizacao completa com firmware
./full-update.sh

# Manutencao completa (update + limpeza + firmware)
./system-maintenance.sh

# Preview sem executar
./system-maintenance.sh --dry-run
```

---

## Gerenciamento de Pacotes

### DNF Basico

```bash
# Instalar
sudo dnf install pacote

# Remover
sudo dnf remove pacote

# Buscar
dnf search termo

# Info
dnf info pacote

# Atualizar tudo
sudo dnf upgrade --refresh

# Listar instalados
dnf list installed

# Desfazer ultima transacao
sudo dnf history undo last
```

### COPR (equivalente AUR)

```bash
# Usando o copr-manager.sh
./copr-manager.sh search yazi
./copr-manager.sh install atim/yazi yazi
./copr-manager.sh list

# Ou manualmente
sudo dnf copr enable atim/yazi
sudo dnf install yazi
```

### Flatpak

```bash
# Usando o flatpak-manager.sh
./flatpak-manager.sh search spotify
./flatpak-manager.sh install com.spotify.Client
./flatpak-manager.sh update
./flatpak-manager.sh cleanup

# Ou manualmente
flatpak install flathub com.spotify.Client
flatpak update
```

---

## Repositorios Extras

### RPM Fusion (necessario para Steam, VLC, codecs, etc)

```bash
# Os scripts habilitam automaticamente, mas pode fazer manual:
sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### COPR usados neste projeto

| COPR | Pacotes | Descricao |
|------|---------|-----------|
| `atim/lazygit` | lazygit | TUI Git client |
| `atim/yazi` | yazi | Terminal file manager |
| `atim/starship` | starship | Cross-shell prompt |
| `pgdev/ghostty` | ghostty | Terminal emulator |
| `che/nerd-fonts` | *-nerd-fonts | Fontes para programacao |

---

## Casos Especiais

### Pacotes AUR sem equivalente (usar Distrobox)

Para pacotes que so existem no AUR e nao tem equivalente DNF/COPR/Flatpak:

```bash
# Setup inicial (cria container Arch com yay)
./distrobox-setup.sh create

# Instalar pacote AUR dentro do container
./distrobox-setup.sh install pacote-aur

# Exportar app para o host (aparece no menu)
./distrobox-setup.sh export pacote-aur

# Exportar apenas o binario
./distrobox-setup.sh export-bin binario
```

### Drivers GPU (AMD Radeon)

No Arch, instalamos drivers individualmente. No Fedora:

```bash
# Drivers Mesa (ja vem por padrao no Fedora)
sudo dnf install mesa-dri-drivers mesa-vulkan-drivers mesa-va-drivers

# Para NVIDIA, usar akmod (equivalente ao dkms do Arch)
sudo dnf install akmod-nvidia
```

### Codecs Multimedia

```bash
# Habilitar RPM Fusion primeiro, depois:
sudo dnf install gstreamer1-plugins-{bad-*,good-*,base} \
  gstreamer1-plugin-openh264 \
  gstreamer1-libav \
  lame\* --exclude=lame-devel
```

### PostgreSQL

A inicializacao e diferente no Fedora:

```bash
# Arch: sudo -u postgres initdb -D /var/lib/postgres/data
# Fedora: sudo postgresql-setup --initdb
```

---

## FAQ e Troubleshooting

### "Pacote nao encontrado"

1. Verifique se o nome mudou: `dnf provides "*/binario"`
2. Verifique se precisa de RPM Fusion: `sudo dnf install rpmfusion-free-release rpmfusion-nonfree-release`
3. Busque no COPR: `dnf copr search pacote`
4. Use Flatpak: `flatpak search app`
5. Ultimo recurso: Distrobox com Arch

### "dnf e lento"

O DNF pode parecer mais lento que o pacman na primeira execucao porque atualiza metadados. Para acelerar:

```bash
# Adicione ao /etc/dnf/dnf.conf:
max_parallel_downloads=10
fastestmirror=True
```

### "Preciso de lib32-* mas no Fedora..."

No Fedora, pacotes 32-bit usam o sufixo `.i686`:

```bash
# Arch: pacman -S lib32-mesa
# Fedora: dnf install mesa-dri-drivers.i686
```

### "Como faco rollback?"

```bash
# Ver historico de transacoes
dnf history list

# Desfazer ultima transacao
sudo dnf history undo last

# Desfazer transacao especifica
sudo dnf history undo <ID>
```

### "Configs .rpmnew aparecendo"

```bash
# Instalar rpmconf
sudo dnf install rpmconf

# Resolver interativamente
sudo rpmconf -a
```

### "Preciso reiniciar?"

```bash
# Fedora tem ferramenta propria
needs-restarting -r

# Listar servicos que precisam restart
needs-restarting -s
```

---

## Workflow Recomendado

1. **Instalacao inicial**: `./install-all.sh`
2. **Atualizacao semanal**: `./update.sh` ou `./system-maintenance.sh`
3. **Pacotes COPR**: `./copr-manager.sh install owner/repo pacote`
4. **Apps Flatpak**: `./flatpak-manager.sh install app.id`
5. **Pacotes AUR**: `./distrobox-setup.sh install pacote`
