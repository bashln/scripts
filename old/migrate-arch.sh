#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Migração CachyOS → EndeavourOS (Arch repo + Flatpak + npm -g)
# Criado por: leonamsh | Atualizado: 2025-09-08
# ─────────────────────────────────────────────────────────────────────────────

log() { printf "\033[1;36m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

DIR="./migration-exports"
MODE="${1:-}"

# Parse simples
while [[ $# -gt 0 ]]; do
  case "$1" in
  export | import | dry-run)
    MODE="$1"
    shift
    ;;
  --dir)
    [[ $# -ge 2 ]] || {
      err "Faltou diretório após --dir"
      exit 1
    }
    DIR="$2"
    shift 2
    ;;
  *)
    shift
    ;;
  esac
done

mkdir -p "$DIR"

PAC_FILE="$DIR/pacman_official.txt"
FLAT_REMOTES_FILE="$DIR/flatpak_remotes.txt"
FLAT_APPS_FILE="$DIR/flatpak_apps.txt"
NPM_FILE="$DIR/npm_globals.txt"

# ── EXPORT ───────────────────────────────────────────────────────────────────

collect_pacman_official() {
  log "Coletando pacotes explícitos do Arch (excluindo 'cachyos')…"
  # explícitos instalados pelo usuário
  mapfile -t explicit < <(pacman -Qqe || true)
  # nativos (não-foreign)
  mapfile -t native < <(pacman -Qnq || true)

  # índice de nativos
  declare -A is_native=()
  for p in "${native[@]}"; do
    is_native["$p"]=1
  done

  # filtra: explícito ∩ nativo
  filtered=()
  for p in "${explicit[@]}"; do
    if [[ -n "${is_native[$p]:-}" ]]; then
      filtered+=("$p")
    fi
  done

  # remove pacotes do repo 'cachyos' e nomes contendo 'cachyos'
  out=()
  for p in "${filtered[@]}"; do
    repo="$(LC_ALL=C pacman -Qi "$p" 2>/dev/null | awk -F': ' '/^Repository/{print $2}')"
    shopt -s nocasematch
    if [[ "${repo,,}" == "cachyos" || "$p" =~ cachyos ]]; then
      shopt -u nocasematch
      continue
    fi
    shopt -u nocasematch
    out+=("$p")
  done

  printf "%s\n" "${out[@]}" | sort -u >"$PAC_FILE"
  log "Salvo: $PAC_FILE ($(wc -l <"$PAC_FILE") pacotes)"
}

collect_flatpak() {
  if ! have flatpak; then
    warn "flatpak ausente; export vazio."
    : >"$FLAT_REMOTES_FILE"
    : >"$FLAT_APPS_FILE"
    return
  fi

  log "Coletando remotes do Flatpak…"
  flatpak remotes --columns=name,url | awk 'NR>1' >"$FLAT_REMOTES_FILE" || true

  log "Coletando apps do Flatpak…"
  flatpak list --app --columns=application >"$FLAT_APPS_FILE" || true
  log "Salvo: $FLAT_APPS_FILE ($(wc -l <"$FLAT_APPS_FILE") apps)"
}

collect_npm_globals() {
  if ! have npm; then
    warn "npm ausente; export vazio."
    : >"$NPM_FILE"
    return
  fi

  log "Coletando npm -g…"
  if have jq; then
    npm -g list --depth=0 --json 2>/dev/null |
      jq -r '.dependencies | keys[]' 2>/dev/null |
      sort -u >"$NPM_FILE" || true
  else
    npm -g ls --depth=0 --parseable 2>/dev/null |
      awk -F'/node_modules/' 'NF>1{print $2}' |
      awk -F'/' '{print $1 (NF>1? "/" $2:"")}' |
      sort -u >"$NPM_FILE" || true
  fi
  log "Salvo: $NPM_FILE ($(wc -l <"$NPM_FILE") pacotes)"
}

# ── IMPORT ───────────────────────────────────────────────────────────────────

install_pacman_official() {
  [[ -s "$PAC_FILE" ]] || {
    warn "Sem $PAC_FILE"
    return
  }

  log "pacman -Sy…"
  sudo pacman -Sy --noconfirm

  log "Instalando pacotes oficiais (excl. cachyos)…"
  mapfile -t wanted < <(grep -v '^\s*$' "$PAC_FILE" | sort -u)

  # Lista de exclusões (ajuste à vontade)
  EXCLUDE_REGEX='^(linux-cachyos|linux-cachyos-headers|cachyos-|mkinitcpio-busybox)$'

  to_install=()
  for p in "${wanted[@]}"; do
    if [[ "$p" =~ $EXCLUDE_REGEX ]]; then
      continue
    fi
    if ! pacman -Qq "$p" >/dev/null 2>&1; then
      to_install+=("$p")
    fi
  done


  if ((${#to_install[@]})); then
    sudo pacman -S --needed --noconfirm "${to_install[@]}"
  else
    log "Nada novo para instalar via pacman."
  fi
}

install_flatpak() {
  if [[ ! -s "$FLAT_APPS_FILE" && ! -s "$FLAT_REMOTES_FILE" ]]; then
    warn "Sem dados de Flatpak."
    return
  fi
  if ! have flatpak; then
    log "Instalando flatpak…"
    sudo pacman -S --needed --noconfirm flatpak
  fi

  if [[ -s "$FLAT_REMOTES_FILE" ]]; then
    log "Sincronizando remotes…"
    while read -r name url; do
      [[ -z "${name:-}" || -z "${url:-}" ]] && continue
      if ! flatpak remotes --columns=name | grep -qx "$name"; then
        flatpak remote-add --if-not-exists "$name" "$url" || warn "Falhou remote $name"
      fi
    done <"$FLAT_REMOTES_FILE"
  fi

  if [[ -s "$FLAT_APPS_FILE" ]]; then
    log "Instalando apps Flatpak…"
    while read -r app; do
      [[ -z "$app" ]] && continue
      if ! flatpak list --app --columns=application | grep -qx "$app"; then
        flatpak install -y "$app" || warn "Falha Flatpak $app"
      fi
    done <"$FLAT_APPS_FILE"
  fi
}

install_npm_globals() {
  [[ -s "$NPM_FILE" ]] || {
    warn "Sem $NPM_FILE"
    return
  }
  if ! have npm; then
    warn "npm ausente; instale nodejs npm antes."
    return
  fi

  log "Instalando npm -g…"
  while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    if npm -g ls --depth=0 "$pkg" >/dev/null 2>&1; then
      continue
    fi
    npm -g i "$pkg" || warn "Falhou npm -g $pkg"
  done <"$NPM_FILE"
}

# ── DRY-RUN ──────────────────────────────────────────────────────────────────

dry_run_show() {
  log "DRY-RUN lendo: $DIR"

  if [[ -s "$PAC_FILE" ]]; then
    log "Pacman (faltantes):"
    comm -23 <(sort -u "$PAC_FILE") <(pacman -Qq | sort -u) | sed 's/^/  - /' || true
  else
    warn "Sem $PAC_FILE"
  fi

  if [[ -s "$FLAT_APPS_FILE" ]]; then
    if have flatpak; then
      log "Flatpak (faltantes):"
      comm -23 <(sort -u "$FLAT_APPS_FILE") <(flatpak list --app --columns=application | sort -u) | sed 's/^/  - /' || true
    else
      log "Flatpak listados (flatpak não instalado):"
      sed 's/^/  - /' "$FLAT_APPS_FILE"
    fi
  else
    warn "Sem $FLAT_APPS_FILE"
  fi

  if [[ -s "$NPM_FILE" ]]; then
    log "npm -g (faltantes):"
    if have npm; then
      if have jq; then
        mapfile -t current < <(npm -g list --depth=0 --json 2>/dev/null | jq -r '.dependencies | keys[]' 2>/dev/null || true)
      else
        mapfile -t current < <(npm -g ls --depth=0 --parseable 2>/dev/null | awk -F'/node_modules/' 'NF>1{print $2}' | awk -F'/' '{print $1 (NF>1? "/" $2:"")}')
      fi
      comm -23 <(sort -u "$NPM_FILE") <(printf "%s\n" "${current[@]}" | sort -u) | sed 's/^/  - /' || true
    else
      sed 's/^/  - /' "$NPM_FILE"
    fi
  else
    warn "Sem $NPM_FILE"
  fi
}

# ── MAIN ─────────────────────────────────────────────────────────────────────

case "${MODE:-}" in
export)
  log "EXPORT → $DIR"
  collect_pacman_official
  collect_flatpak
  collect_npm_globals
  log "EXPORT concluído."
  ;;
import)
  log "IMPORT ← $DIR"
  install_pacman_official
  install_flatpak
  install_npm_globals
  log "IMPORT concluído."
  ;;
dry-run)
  dry_run_show
  ;;
*)
  cat <<EOF
Uso:
  $0 export   [--dir DIR]
  $0 import   [--dir DIR]
  $0 dry-run  [--dir DIR]
EOF
  exit 1
  ;;
esac
