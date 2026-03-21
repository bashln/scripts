#!/usr/bin/env bash
set -euo pipefail

# tarball-installer — instala/desinstala apps empacotados como tarballs
# Uso:
#   tarball-installer [--user] [--name NOME] <arquivo.tar.gz|.tgz|.tar.xz|.tar.bz2|.zip|URL>
#   tarball-installer --uninstall <nome> [--user]
#
# Exemplos:
#   tarball-installer --name jetbrains-idea https://download.jetbrains.com/idea/ideaIC-2024.3.tar.gz
#   tarball-installer ~/Downloads/eclipse-jee-2024-09-R-linux-gtk-x86_64.tar.gz
#   tarball-installer --uninstall eclipse
#
# Notas:
# - Para sistema (padrão) precisa de sudo para criar /opt, /usr/local/bin, etc.
# - Com --user instala em ~/.local/* (não precisa sudo).

die() {
  printf "Erro: %s\n" "$*" >&2
  exit 1
}
info() { printf "==> %s\n" "$*"; }

# --------- parse flags ----------
MODE_SYSTEM=1
APP_NAME=""
UNINSTALL=""
SRC=""

while (("$#")); do
  case "${1:-}" in
  --user)
    MODE_SYSTEM=0
    shift
    ;;
  --name)
    APP_NAME="${2:-}"
    shift 2
    ;;
  --uninstall)
    UNINSTALL="${2:-}"
    shift 2
    ;;
  -h | --help)
    sed -n '1,80p' "$0"
    exit 0
    ;;
  *)
    if [[ -z "${SRC:-}" ]]; then SRC="$1"; else die "muitos argumentos"; fi
    shift
    ;;
  esac
done

if [[ -n "$UNINSTALL" ]]; then SRC=""; fi
if [[ -z "$UNINSTALL" && -z "$SRC" ]]; then die "faltou o arquivo/URL"; fi

# --------- paths ----------
if ((MODE_SYSTEM)); then
  PREFIX_OPT="/opt"
  PREFIX_BIN="/usr/local/bin"
  PREFIX_APPS="/usr/share/applications"
  PREFIX_ICONS="/usr/share/icons/hicolor/256x256/apps"
  MANIFEST_DIR="/var/lib/tarball-installer"
  SUDO=${SUDO:-sudo}
else
  PREFIX_OPT="$HOME/.local/opt"
  PREFIX_BIN="$HOME/.local/bin"
  PREFIX_APPS="$HOME/.local/share/applications"
  PREFIX_ICONS="$HOME/.local/share/icons/hicolor/256x256/apps"
  MANIFEST_DIR="$HOME/.local/share/tarball-installer"
  SUDO=""
fi

mkdir -p "$MANIFEST_DIR" "$PREFIX_OPT" "$PREFIX_BIN" "$PREFIX_APPS" "$PREFIX_ICONS"

# --------- uninstall ----------
if [[ -n "$UNINSTALL" ]]; then
  MANIFEST_FILE="$MANIFEST_DIR/$UNINSTALL.manifest"
  [[ -f "$MANIFEST_FILE" ]] || die "manifesto não encontrado para '$UNINSTALL'"
  info "Desinstalando $UNINSTALL..."
  # remove em ordem reversa para apagar symlinks/pastas vazias por último
  tac "$MANIFEST_FILE" | while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ -L "$path" || -f "$path" ]]; then
      ${SUDO:+$SUDO} rm -f "$path" || true
    elif [[ -d "$path" ]]; then
      ${SUDO:+$SUDO} rmdir "$path" 2>/dev/null || true
    fi
  done
  ${SUDO:+$SUDO} rm -f "$MANIFEST_FILE"
  # atualizar caches de desktop
  command -v update-desktop-database >/dev/null && ${SUDO:+$SUDO} update-desktop-database -q || true
  command -v xdg-desktop-menu >/dev/null && ${SUDO:+$SUDO} xdg-desktop-menu forceupdate || true
  info "Pronto. '$UNINSTALL' removido."
  exit 0
fi

# --------- preparar fonte (URL ou arquivo) ----------
WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

ARCHIVE="$WORKDIR/pkg"
if [[ "$SRC" =~ ^https?:// ]]; then
  info "Baixando: $SRC"
  curl -fL "$SRC" -o "$ARCHIVE" || die "download falhou"
else
  [[ -f "$SRC" ]] || die "arquivo não existe: $SRC"
  cp -f "$SRC" "$ARCHIVE"
fi

# Detectar tipo e extrair
detect_and_extract() {
  local f="$1"
  case "$f" in
  *.tar.gz | *.tgz | *.tar.xz | *.tar.bz2 | *.tar) tar -xf "$f" -C "$WORKDIR" ;;
  *.zip) unzip -q "$f" -d "$WORKDIR" ;;
  *) # tentar pela assinatura
    file "$f" | grep -qiE 'tar|gzip|bzip2|xz|Zip' || die "formato não suportado"
    tar -xf "$f" -C "$WORKDIR" 2>/dev/null || unzip -q "$f" -d "$WORKDIR" || die "não foi possível extrair"
    ;;
  esac
}
detect_and_extract "$ARCHIVE"

# Descobrir diretório raiz extraído
ROOT_DIR="$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
[[ -n "$ROOT_DIR" ]] || die "não encontrei diretório após extração"

# Sugerir nome/versão se não informado
if [[ -z "$APP_NAME" ]]; then
  # pega nome da pasta raiz, limpa sufixos comuns (x86_64, linux, gtk etc.)
  base="$(basename "$ROOT_DIR")"
  APP_NAME="$(sed -E 's/-?(linux|gtk|x86_64|amd64|bin|portable)$//I; s/[ _]+/-/g' <<<"$base" | sed -E 's/[.-]?[0-9].*$//')"
  APP_NAME="${APP_NAME,,}"
  [[ -n "$APP_NAME" ]] || APP_NAME="tarball-app"
fi

# Tentar achar o binário lançador
find_launcher() {
  # 1) se houver bin/* executável, preferir o primeiro “.sh” ou binário
  local cand
  cand="$(find "$ROOT_DIR" -type f \( -path "*/bin/*" -o -maxdepth 2 -path "$ROOT_DIR/*" \) -perm -u+x |
    grep -Ei '/(bin/)?(start|launch|run|app|idea|eclipse|studio|bin)$|\.sh$' |
    head -n1 || true)"
  [[ -n "$cand" ]] && {
    echo "$cand"
    return
  }

  # 2) script .sh na raiz que pareça lançador
  cand="$(find "$ROOT_DIR" -maxdepth 2 -type f -name "*.sh" | head -n1 || true)"
  [[ -n "$cand" ]] && {
    echo "$cand"
    return
  }

  # 3) maior executável dentro de bin/
  cand="$(find "$ROOT_DIR/bin" -type f -perm -u+x 2>/dev/null | head -n1 || true)"
  [[ -n "$cand" ]] && {
    echo "$cand"
    return
  }

  # 4) último recurso: arquivo executável top-level
  cand="$(find "$ROOT_DIR" -maxdepth 1 -type f -perm -u+x | head -n1 || true)"
  [[ -n "$cand" ]] && {
    echo "$cand"
    return
  }

  echo ""
}

LAUNCHER="$(find_launcher)"
[[ -n "$LAUNCHER" ]] || die "não consegui detectar o launcher. Use --name e crie seu próprio wrapper depois."

# Destino final: /opt/<app>/<conteudo>
DEST_DIR="$PREFIX_OPT/$APP_NAME"
if [[ -e "$DEST_DIR" ]]; then
  TS=$(date +%s)
  info "Diretório $DEST_DIR já existe. Vou versionar como ${DEST_DIR}-${TS}"
  DEST_DIR="${DEST_DIR}-${TS}"
fi

info "Instalando em: $DEST_DIR"
${SUDO:+$SUDO} mkdir -p "$DEST_DIR"
${SUDO:+$SUDO} cp -a "$ROOT_DIR"/. "$DEST_DIR"/

# Criar wrapper em PATH
WRAPPER="$PREFIX_BIN/$APP_NAME"
info "Criando wrapper: $WRAPPER"
${SUDO:+$SUDO} tee "$WRAPPER" >/dev/null <<EOF
#!/usr/bin/env bash
APP_DIR="$(dirname "$(readlink -f "$0")")/../opt/$APP_NAME"
LAUNCHER_REL="$(realpath --relative-to="\$APP_DIR" "$DEST_DIR")/$(realpath --relative-to="$DEST_DIR" "$LAUNCHER")"
exec "\$APP_DIR/\$LAUNCHER_REL" "\$@"
EOF
${SUDO:+$SUDO} chmod +x "$WRAPPER"

# Ícone (opcional)
ICON_SRC="$(find "$DEST_DIR" -type f \( -iname "*256*png" -o -iname "*icon*.png" -o -iname "*.svg" \) | head -n1 || true)"
ICON_PATH=""
if [[ -n "$ICON_SRC" ]]; then
  EXT="${ICON_SRC##*.}"
  ICON_PATH="$PREFIX_ICONS/$APP_NAME.$EXT"
  info "Instalando ícone: $ICON_PATH"
  ${SUDO:+$SUDO} install -D -m 0644 "$ICON_SRC" "$ICON_PATH" || true
fi

# Desktop entry
DESKTOP_FILE="$PREFIX_APPS/$APP_NAME.desktop"
if [[ -f "$DEST_DIR/$APP_NAME.desktop" ]]; then
  info "Instalando desktop file fornecido: $DESKTOP_FILE"
  ${SUDO:+$SUDO} install -m 0644 "$DEST_DIR/$APP_NAME.desktop" "$DESKTOP_FILE"
  # garantir Exec e Icon corretos
  ${SUDO:+$SUDO} sed -i -E "s|^Exec=.*|Exec=$WRAPPER|; s|^Icon=.*|Icon=${ICON_PATH:-$APP_NAME}|" "$DESKTOP_FILE" || true
else
  info "Gerando desktop file: $DESKTOP_FILE"
  ${SUDO:+$SUDO} tee "$DESKTOP_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=${APP_NAME^}
Comment=Aplicativo instalado via tarball-installer
Exec=$WRAPPER
Icon=${ICON_PATH:-$APP_NAME}
Terminal=false
Type=Application
Categories=Utility;
EOF
fi

# Atualizar caches
command -v update-desktop-database >/dev/null && ${SUDO:+$SUDO} update-desktop-database -q || true
command -v xdg-desktop-menu >/dev/null && ${SUDO:+$SUDO} xdg-desktop-menu forceupdate || true
command -v gtk-update-icon-cache >/dev/null && ${SUDO:+$SUDO} gtk-update-icon-cache -q "$(dirname "$(dirname "$PREFIX_ICONS")")" 2>/dev/null || true

# Manifest para desinstalar depois
MANIFEST_FILE="$MANIFEST_DIR/$APP_NAME.manifest"
info "Gravando manifest: $MANIFEST_FILE"
{
  echo "$DEST_DIR"
  echo "$WRAPPER"
  [[ -n "$ICON_PATH" ]] && echo "$ICON_PATH"
  echo "$DESKTOP_FILE"
  # pastas raiz podem ser removidas se vazias
  echo "$PREFIX_OPT"
  echo "$PREFIX_BIN"
  echo "$PREFIX_APPS"
  echo "$PREFIX_ICONS"
} >"$MANIFEST_FILE"

info "Concluído!"
echo
echo "Comandos úteis:"
echo "  Executar: $APP_NAME"
echo "  Desinstalar: $(basename "$0") --uninstall $APP_NAME$([[ $MODE_SYSTEM -eq 0 ]] && echo " --user")"
