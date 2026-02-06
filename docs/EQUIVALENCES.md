# Equivalencias de Comandos: Arch Linux (Pacman) -> Fedora (DNF)

Referencia completa de equivalencia entre os gerenciadores de pacotes.

---

## Operacoes Basicas

| Operacao | Arch (pacman/paru/yay) | Fedora (dnf) |
|----------|------------------------|--------------|
| Instalar pacote | `pacman -S pkg` | `dnf install pkg` |
| Instalar sem confirmacao | `pacman -S --noconfirm pkg` | `dnf install -y pkg` |
| Instalar se necessario | `pacman -S --needed pkg` | `dnf install pkg` (ja e idempotente) |
| Remover pacote | `pacman -R pkg` | `dnf remove pkg` |
| Remover + dependencias | `pacman -Rns pkg` | `dnf remove pkg && dnf autoremove` |
| Atualizar sistema | `pacman -Syu` | `dnf upgrade --refresh` |
| Forcar refresh | `pacman -Syyu` | `dnf makecache --refresh && dnf upgrade` |
| Buscar pacote | `pacman -Ss termo` | `dnf search termo` |
| Info do pacote | `pacman -Qi pkg` | `dnf info pkg` |
| Listar instalados | `pacman -Q` | `dnf list installed` |
| Instalados explicitamente | `pacman -Qe` | `dnf repoquery --userinstalled` |
| Listar orfaos | `pacman -Qtdq` | `dnf autoremove --assumeno` (preview) |
| Remover orfaos | `pacman -Rns $(pacman -Qtdq)` | `dnf autoremove -y` |
| Limpar cache | `pacman -Sc` | `dnf clean packages` |
| Limpar todo cache | `pacman -Scc` | `dnf clean all` |
| Cache inteligente | `paccache -rk3` | `dnf clean packages` (dnf gerencia auto) |
| Arquivo pertence a | `pacman -Qo /path/file` | `dnf provides /path/file` |
| Listar arquivos do pkg | `pacman -Ql pkg` | `dnf repoquery -l pkg` |
| Verificar pacote | `pacman -Qk pkg` | `rpm -V pkg` |

## AUR vs COPR

| Operacao | Arch (paru/yay) | Fedora (dnf copr) |
|----------|-----------------|-------------------|
| Instalar do AUR | `paru -S pkg` | `dnf copr enable owner/repo && dnf install pkg` |
| Buscar no AUR | `paru -Ss pkg` | `dnf copr search termo` |
| Atualizar AUR | `paru -Sua` | `dnf upgrade` (inclui COPR habilitados) |
| Listar repos extras | `pacman -Sl` | `dnf copr list` |

## Grupos de Pacotes

| Operacao | Arch | Fedora |
|----------|------|--------|
| Instalar grupo | `pacman -S base-devel` | `dnf group install "Development Tools"` |
| Listar grupos | `pacman -Sg` | `dnf group list` |
| Info do grupo | `pacman -Sg grupo` | `dnf group info "grupo"` |

## Flatpak (Igual em ambos)

| Operacao | Comando |
|----------|---------|
| Instalar | `flatpak install flathub app.id` |
| Remover | `flatpak uninstall app.id` |
| Atualizar | `flatpak update` |
| Listar | `flatpak list` |
| Buscar | `flatpak search termo` |
| Limpar unused | `flatpak uninstall --unused` |

## Servicos e Sistema

| Operacao | Arch | Fedora |
|----------|------|--------|
| Configs pendentes | `find /etc -name "*.pacnew"` | `find /etc -name "*.rpmnew" -o -name "*.rpmsave"` |
| Resolver configs | `pacdiff` | `rpmconf -a` |
| Verificar reinicio | Manual | `needs-restarting -r` |
| Firmware update | `fwupdmgr update` | `fwupdmgr update` (igual) |

---

## Mapeamento de Nomes de Pacotes

### Pacotes que mudam de nome

| Arch | Fedora | Notas |
|------|--------|-------|
| `base-devel` | `@development-tools` | Grupo de pacotes |
| `python` | `python3` | Nome diferente |
| `python-pip` | `python3-pip` | Prefixo python3 |
| `python-pylsp` | `python3-lsp-server` | Nome diferente |
| `python-black` | `python3-black` | Prefixo python3 |
| `go` | `golang` | Nome diferente |
| `fd` | `fd-find` | Nome diferente |
| `shellcheck` | `ShellCheck` | Case diferente |
| `ttf-fira-code` | `fira-code-fonts` | Convencao diferente |
| `ttf-jetbrains-mono` | `jetbrains-mono-fonts-all` | Convencao diferente |
| `lib32-*` | `*.i686` | Sufixo .i686 para 32-bit |
| `vulkan-icd-loader` | `vulkan-loader` | Nome simplificado |
| `mesa` | `mesa-dri-drivers` | Mais especifico |
| `vulkan-radeon` | `mesa-vulkan-drivers` | Inclui todos os drivers |
| `xf86-video-amdgpu` | `xorg-x11-drv-amdgpu` | Convencao xorg-x11 |
| `p7zip` / `7zip` | `p7zip` | Mesmo nome |
| `imagemagick` | `ImageMagick` | Case diferente |

### Pacotes que mantem o mesmo nome

Estes pacotes tem o mesmo nome em ambas as distros:
- `git`, `curl`, `unzip`, `jq`, `cmake`, `stow`
- `nodejs`, `npm`, `rust`, `cargo`, `ruby`
- `alacritty`, `kitty`, `tmux`, `zsh`
- `mesa`, `libva-utils`, `gvfs`
- `ntfs-3g`, `samba`, `wl-clipboard`
- `wine`, `winetricks`, `vlc`, `remmina`
- `ripgrep`, `fzf`, `zoxide`, `eza`
- `emacs`, `flatpak`, `steam` (via RPM Fusion)
- `postgresql` (mas Fedora tambem precisa de `postgresql-server`)

### Pacotes que precisam de repositorio extra

| Pacote | Arch | Fedora | Repositorio |
|--------|------|--------|-------------|
| Steam | Repos oficiais | RPM Fusion (nonfree) | `rpmfusion-nonfree` |
| VLC | Repos oficiais | RPM Fusion (free) | `rpmfusion-free` |
| VSCode | AUR (`visual-studio-code-bin`) | Repo Microsoft | Repo externo |
| Vivaldi | Repos oficiais | Repo Vivaldi | Repo externo |
| Brave | AUR | Repo Brave | Repo externo |
| Ghostty | AUR | COPR `pgdev/ghostty` | COPR |
| Lazygit | Repos oficiais | COPR `atim/lazygit` | COPR |
| Yazi | Repos oficiais | COPR `atim/yazi` | COPR |
| Nerd Fonts | Repos oficiais | COPR `che/nerd-fonts` | COPR |
| Starship | Repos oficiais | COPR `atim/starship` ou script | COPR/Script |

### Pacotes sem equivalente direto

| Arch | Alternativa Fedora |
|------|--------------------|
| `asdf-vm` (AUR) | Git clone manual de `github.com/asdf-vm/asdf` |
| `dank-material-shell` (AUR) | Script remoto `install.danklinux.com` |
| `paccache` | Nao necessario (DNF gerencia cache automaticamente) |
| `reflector` | Nao necessario (Fedora gerencia mirrors automaticamente) |
| `pacman-contrib` | `dnf-utils` (funcionalidade diferente) |
