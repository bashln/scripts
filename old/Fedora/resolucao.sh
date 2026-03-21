#!/usr/bin/env bash
# Configurar resolução no KDE (Wayland/X11) de forma pragmática
# Uso:
#   ./resolucao.sh DP-1 1440x900@75
#   ./resolucao.sh HDMI-A-1 1920x1080@60
#
# Em Wayland (KDE), tenta usar kscreen-doctor; em X11, usa xrandr.
set -euo pipefail

BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; GREEN="\e[32m"; RESET="\e[0m"

msg() { echo -e "${BLUE}[$(date '+%F %T')] $*${RESET}"; }
warn(){ echo -e "${YELLOW}[WARN] $*${RESET}"; }
err() { echo -e "${RED}[ERRO] $*${RESET}"; exit 1; }

if [[ $# -lt 2 ]]; then
  err "Uso: $0 <SAIDA> <MODO>   Ex.: $0 DP-1 1440x900@75"
fi

OUTPUT="$1"
MODE="$2"

IS_WAYLAND="${XDG_SESSION_TYPE:-}"
HAS_KSCREEN="$(command -v kscreen-doctor || true)"
HAS_XRANDR="$(command -v xrandr || true)"

if [[ "${IS_WAYLAND}" == "wayland" && -n "${HAS_KSCREEN}" ]]; then
  msg "Detectado Wayland (KDE). Usando kscreen-doctor..."
  # Tenta aplicar resolução. Se falhar, mostrará conexões disponíveis.
  if ! kscreen-doctor output."$OUTPUT".mode."$MODE" 2>/dev/null; then
    warn "Falhou ao aplicar $MODE em $OUTPUT."
    msg "Saídas disponíveis:"
    kscreen-doctor -o || true
    exit 1
  fi
  msg "Resolução aplicada: $OUTPUT -> $MODE"
  exit 0
fi

if [[ -n "${HAS_XRANDR}" ]]; then
  msg "Usando X11/xrandr..."
  if ! xrandr | grep -q "^$OUTPUT "; then
    warn "Saída $OUTPUT não encontrada. Disponíveis:"
    xrandr | grep ' connected' || true
    exit 1
  fi

  # Se o modo não existir, tenta criar
  if ! xrandr | grep -q "$MODE"; then
    WIDTH="$(echo "$MODE" | cut -d'x' -f1)"
    HEIGHT_RATE="$(echo "$MODE" | cut -d'x' -f2)"
    HEIGHT="$(echo "$HEIGHT_RATE" | cut -d'@' -f1)"
    RATE="$(echo "$HEIGHT_RATE" | cut -d'@' -f2)"
    CVT_OUT="$(cvt "$WIDTH" "$HEIGHT" "$RATE" | tail -n1)"
    NEWMODE_NAME="$(echo "$CVT_OUT" | awk '{print $2}')"
    xrandr --newmode $NEWMODE_NAME $(echo "$CVT_OUT" | cut -d' ' -f3-)
    xrandr --addmode "$OUTPUT" "$NEWMODE_NAME"
    MODE="$NEWMODE_NAME"
  fi

  xrandr --output "$OUTPUT" --mode "$MODE"
  msg "Resolução aplicada: $OUTPUT -> $MODE"
  exit 0
fi

err "Nem kscreen-doctor (Wayland) nem xrandr (X11) disponíveis."
