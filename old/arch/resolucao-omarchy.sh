#!/usr/bin/env bash
set -euo pipefail

# ---- Alvos desejados ----
HDMI="${HDMI_NAME:-HDMI-A-1}"
HDMI_RES="${HDMI_RES:-1920x1080}"
HDMI_HZ="${HDMI_REFRESH:-}"       # vazio = preferido

DP="${DP_NAME:-DP-1}"
DP_RES="${DP_RES:-1440x900}"      # se for 1140x900, mude aqui
DP_HZ="${DP_REFRESH:-75}"

have() { command -v "$1" >/dev/null 2>&1; }

echo "[i] Objetivo: $DP ${DP_RES}${DP_HZ:+@$DP_HZ} | $HDMI ${HDMI_RES}${HDMI_HZ:+@$HDMI_HZ}"

if have swaymsg; then
  # ===== Sway =====
  echo "[i] Sway detectado."

  # 1) Aplica os modos requisitados
  swaymsg -q output "$DP" enable
  if [[ -n "$DP_HZ" ]]; then
    swaymsg -q output "$DP" mode "${DP_RES}@${DP_HZ}Hz" position 0 0
  else
    swaymsg -q output "$DP" mode "${DP_RES}" position 0 0
  fi

  swaymsg -q output "$HDMI" enable
  if [[ -n "$HDMI_HZ" ]]; then
    swaymsg -q output "$HDMI" mode "${HDMI_RES}@${HDMI_HZ}Hz"
  else
    swaymsg -q output "$HDMI" mode "${HDMI_RES}"
  fi

  # 2) Lê as saídas reais (largura e scale)
  if ! have jq; then
    echo "[!] Precisa do jq (sudo dnf/apt/pacman install jq)."
    exit 1
  fi

  # largura_lógica = largura_px / scale
  DP_LOGICAL_W=$(swaymsg -t get_outputs | jq -r \
    --arg N "$DP" '.[] | select(.name==$N) | (.current_mode.width / (.scale // 1))' | awk '{print int($1)}')

  # Fallback se não achar (ex.: output off)
  : "${DP_LOGICAL_W:=0}"

  echo "[i] Largura lógica do $DP = $DP_LOGICAL_W"
  swaymsg -q output "$HDMI" position "$DP_LOGICAL_W" 0

  exit 0
fi

if have hyprctl; then
  # ===== Hyprland =====
  echo "[i] Hyprland detectado."

  # 1) Aplica os modos requisitados
  hyprctl keyword monitor "$DP,${DP_RES}${DP_HZ:+@${DP_HZ}},auto,1"
  hyprctl keyword monitor "$HDMI,${HDMI_RES}${HDMI_HZ:+@${HDMI_HZ}},0x0,1"
  hyprctl dispatch dpms on >/dev/null 2>&1 || true

  # 2) Lê as saídas reais (largura e scale)
  if ! have jq; then
    echo "[!] Precisa do jq (sudo dnf/apt/pacman install jq)."
    exit 1
  fi
  # No Hyprland, as posições são em coords lógicas (width/scale).
  DP_LOGICAL_W=$(hyprctl monitors -j | jq -r \
    --arg N "$DP" '.[] | select(.name==$N) | (.width / (.scale // 1))' | awk '{print int($1)}')

  : "${DP_LOGICAL_W:=0}"
  echo "[i] Largura lógica do $DP = $DP_LOGICAL_W"

  hyprctl keyword monitor "$HDMI,${HDMI_RES}${HDMI_HZ:+@${HDMI_HZ}},${DP_LOGICAL_W}x0,1"
  exit 0
fi

echo "[!] Nenhum compositor wlroots suportado detectado (Sway/Hyprland)."
exit 1
