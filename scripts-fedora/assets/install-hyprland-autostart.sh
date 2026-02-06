#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

main() {
    HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    OVERRIDES_CONFIG="$SCRIPT_DIR/autostart.conf"
    SOURCE_LINE="source = $OVERRIDES_CONFIG"

    info "Configurando autostart do Hyprland"

    if [ ! -f "$HYPRLAND_CONFIG" ]; then
        warn "Configuracao do Hyprland nao encontrada em $HYPRLAND_CONFIG"
        warn "Por favor, instale o Hyprland primeiro"
        return 1
    fi

    if [ ! -f "$OVERRIDES_CONFIG" ]; then
        warn "Arquivo de autostart nao encontrado em $OVERRIDES_CONFIG"
        return 1
    fi

    if grep -Fxq "$SOURCE_LINE" "$HYPRLAND_CONFIG"; then
        ok "Linha de source ja existe em $HYPRLAND_CONFIG"
    else
        info "Adicionando linha de source em $HYPRLAND_CONFIG"
        echo "" >> "$HYPRLAND_CONFIG"
        echo "$SOURCE_LINE" >> "$HYPRLAND_CONFIG"
        ok "Linha de source adicionada com sucesso"
    fi

    ok "Setup de autostart do Hyprland completo!"
}

main "$@"
