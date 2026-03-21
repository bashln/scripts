# 🐾 archpaw/scripts

Uma coleção de scripts úteis para ajustes rápidos, automações e melhorias no uso diário de distribuições Linux.

> ⚙️ Pensado para usuários reais. Testado em ambientes reais. Inspirado na filosofia do "faça você mesmo", mas com menos sofrimento.

---

## 📁 Estrutura do Repositório

Organizado por distribuição para facilitar testes e modularização:

```bash
archpaw/scripts/
├── arch/                   # Scripts específicos para Arch Linux
├── biglinux/               # Scripts otimizados para BigLinux
├── endeavour/              # Ajustes e ferramentas para EndeavourOS
├── fedora/                 # Scripts pensados para usuários Fedora
├── popos/                  # Scripts para facilitar a vida em Pop!_OS
├── ubuntu/                 # Automação e tweaks para Ubuntu
```

- **`<distro>/`**: Scripts específicos para cada sistema.
- **`automount-disks.sh`**: Automatiza montagem de discos após boot.
- **`git.sh`**: Alias e funções úteis pro dia a dia com Git.
- **`mudar_resolucao.sh`**: Troca de resolução em setups híbridos (X11/Wayland).
- **`resolucao_wayland.txt`**: Dicas e ajustes manuais para monitores em Wayland.

---

## 🎯 Objetivo

Facilitar a vida de quem usa Linux no dia a dia. Seja você um técnico, power user ou só alguém que se recusa a digitar o mesmo comando 10 vezes.

---

## 🚀 Como usar

Clone o repo:

```bash
git clone https://gitlab.com/archpaw/scripts.git
cd scripts
Acesse a pasta da sua distro ou use os scripts genéricos direto. Dê permissão de execução:
```

```bash
chmod +x mudar_resolucao.sh
./mudar_resolucao.sh
```

## 🧠 Para quem é isso?

Usuários de Linux com várias distros

Técnicos que fazem manutenção ou config em máquinas de clientes

Quem curte terminal e quer produtividade

Alguém que odeia configurar tudo do zero 😅

## 📌 To-Do / Melhorias futuras

- Documentar cada script individualmente
- Adicionar suporte a outras distros (ex: NixOS, Debian puro)
- Criar um instalador interativo (menu.sh)
- Adicionar testes automáticos básicos

## 👤 Autor

Desenvolvido por @archpaw — técnico em eletrônica, apaixonado por Linux, segurança e terminal.

## 🦁 Mascote: "Simba", o leão terminal

Futuro mascote do projeto, inspirado no navegador Brave e no Rei Leão.
Porque um terminal também pode ser fofo e feroz ao mesmo tempo. 🐾

## 📜 Licença

MIT – use, modifique, compartilhe.
