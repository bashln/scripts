# 🧩 bshln-scripts

Coleção de scripts Bash para pós-instalação e setup completo de ambiente Arch Linux.  
Automatiza a instalação de ferramentas de desenvolvimento, linguagens, utilitários e configurações pessoais.

Cada script foi projetado para ser **idempotente** — você pode executá-los quantas vezes quiser sem quebrar o sistema ou repetir tarefas desnecessárias.

---

## 🚀 Objetivo

Facilitar a configuração de novos sistemas e ambientes de trabalho de forma segura, reprodutível e modular.

Esses scripts foram escritos para:

- Recriar rapidamente o ambiente de desenvolvimento completo.
- Serem executados individualmente ou em sequência.
- Evitar reinstalações desnecessárias.
- Ser legíveis, simples e padronizados.

---

## 🧠 Estrutura do projeto

- bshln-scripts/scripts

├── install-all.sh # Executa todos os scripts em ordem  
├── modelo.sh # Modelo padrão para novos scripts  
├── lib.sh # (opcional) Funções globais de log  
├── install-\*.sh # Scripts individuais de instalação  
│
├── configure-git.sh # Exemplo de configuração (Git)  
├── install-ohmybash-starship.sh # Instalação do Oh My Bash + Starship  
├── install-dotfiles.sh # Aplica dotfiles com GNU Stow  
├── set-shell.sh # Define Zsh como shell padrão  
└── ... # Outros scripts de setup

- Cada script segue o mesmo padrão:

```bash
set -euo pipefail
info()  { printf "\e[34m[*]\e[0m %s\n" "$*"; }
ok()    { printf "\e[32m[+]\e[0m %s\n" "$*"; }
warn()  { printf "\e[33m[!]\e[0m %s\n" "$*"; }
fail()  { printf "\e[31m[✗]\e[0m %s\n" "$*"; }
```

⚙️ Como usar

1. Clonar o repositório

```bash

git clone https://gitlab.com/teuusuario/bshln-scripts.git
cd bshln-scripts
cd scripts/
```

2. Tornar scripts executáveis

```bash

chmod +x *.sh
```

3. Executar o instalador principal

```bash

./install-all.sh
```

O script install-all.sh irá executar todos os scripts em ordem.
Se algum falhar, ele registra o erro mas continua a execução (modo resiliente).

Você também pode rodar um script individual:

```bash

./install-ohmybash-starship.sh
```

## 🔁 Idempotência

Todos os scripts foram escritos para poderem ser executados várias vezes sem causar erros ou reinstalações desnecessárias.

Por exemplo:

Se o pacote já está instalado → apenas registra e pula.

Se o repositório já foi clonado → apenas atualiza com git pull.

Se a configuração já existe → nada é sobrescrito.

🧩 Criando novos scripts

Para adicionar um novo script, basta copiar o modelo:

```bash

cp modelo.sh install-nome-da-ferramenta.sh
chmod +x install-nome-da-ferramenta.sh
```

Edite apenas a função main() e adicione o nome do novo arquivo ao array steps dentro de install-all.sh.

Exemplo de trecho em install-all.sh:

```bash

local steps=(
  install-nodejs.sh
  install-rust.sh
  install-nome-da-ferramenta.sh  # novo script aqui
)
```

## 🔒 Permissões e sudo

Os scripts detectam automaticamente se estão sendo executados como root.
Se não estiver, o sudo será usado nas operações que exigem privilégios.

## 🧰 Dependências básicas

Antes de rodar o setup completo, certifique-se de que tem o mínimo necessário instalado:

```bash

sudo pacman -S --needed git base-devel curl
```

## 🧙‍♂️ Filosofia

Este projeto segue alguns princípios:

- Idempotência: rodar 100 vezes deve dar o mesmo resultado.

- Legibilidade: código simples > “mágico”.

- Autonomia: cada script faz uma coisa só.

- Logs claros: sempre saber o que foi feito e o que falhou.

- Reprodutibilidade: do zero ao ambiente pronto em minutos.

## 🛠️ Exemplos de scripts incluídos

- Script Descrição
  - install-base-devel.sh -> Instala ferramentas de compilação básicas
  - ainstall-flatpak-flathub.sh Configura o Flatpak com o repositório Flathub
  - install-go-tools.sh Instala gopls, goimports e outras ferramentas Go
  - install-ohmybash-starship.sh Instala Oh My Bash + Starship Prompt
  - install-tmux.sh Instala e configura tmux + TPM
  - install-dotfiles.sh Clona e aplica seus dotfiles com GNU Stow
  - set-shell.sh Define Zsh como shell padrão

## 🧩 Exemplo de saída

- [*] Executando: install-nodejs.sh

- [+] nodejs já está instalado.

- [*] Executando: install-vscode.sh

- [+] Visual Studio Code instalado com sucesso.

- [!] Falha ao instalar Steam (pacote ausente no repositório)

- [+] Todas as etapas concluídas!

## 💬 Contribuição

Crie uma branch:

````bash

git checkout -b feature/novo-script
```wbash

Copie o modelo (modelo.sh) e adicione sua automação.

Teste localmente rodando:
```bash

    ./install-novo-script.sh
````

Faça commit e abra um merge request no GitLab.

## 🧾 Licença

Este projeto é distribuído sob a licença MIT.

Use, modifique e compartilhe livremente, mas mencione a origem se for reutilizar partes do código.
