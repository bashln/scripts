#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Encerrando instâncias do IntelliJ (Flatpak)…"
flatpak kill com.jetbrains.IntelliJ-IDEA-Community 2>/dev/null || true
flatpak kill com.jetbrains.IntelliJ-IDEA-Ultimate 2>/dev/null || true
# se houver algum processo residual do binário dentro do flatpak:
pkill -f -TERM '/app/extra/bin/idea|com.intellij' 2>/dev/null || true
sleep 1
pkill -f -KILL '/app/extra/bin/idea|com.intellij' 2>/dev/null || true

echo "[2/4] Limpando sockets/locks órfãos do sandbox…"
for APP in com.jetbrains.IntelliJ-IDEA-Community com.jetbrains.IntelliJ-IDEA-Ultimate; do
  BASE="$HOME/.var/app/$APP"
  for ROOT in cache config local/share; do
    DIR="$BASE/$ROOT/JetBrains"
    [ -d "$DIR" ] || continue
    # soquetes unix
    find "$DIR" -maxdepth 7 -type s -print -delete 2>/dev/null || true
    # arquivos de porta e locks
    find "$DIR" -maxdepth 7 -name 'port*' -print -delete 2>/dev/null || true
    find "$DIR" -maxdepth 7 -name '*.lock' -print -delete 2>/dev/null || true
  done
done

# Se você usa Toolbox e ele deixou o socket:
rm -f /run/user/1000/jb.station.sock 2>/dev/null || true

echo "[3/4] Verificando restos de sockets do JetBrains/IntelliJ…"
if lsof -U | egrep -i 'idea|jetbrains|intellij'; then
  echo "Ainda há sockets/ processos ativos acima. Se necessário, faça logout/login."
else
  echo "Tudo limpo 🚀"
fi

# Modo opcional: executar diagnóstico com paths temporários
if [[ "${1-}" == "--diag" ]]; then
  echo "[4/4] Iniciando IntelliJ com IDEA_PROPERTIES temporário (diagnóstico)…"
  mkdir -p /tmp/idea-{config,system,plugins,log}
  cat >/tmp/idea.properties <<'EOF'
idea.config.path=/tmp/idea-config
idea.system.path=/tmp/idea-system
idea.plugins.path=/tmp/idea-plugins
idea.log.path=/tmp/idea-log
EOF

  # Descobre qual edição você tem instalada e tenta rodar
  if flatpak info com.jetbrains.IntelliJ-IDEA-Community >/dev/null 2>&1; then
    flatpak run --env=IDEA_PROPERTIES=/tmp/idea.properties com.jetbrains.IntelliJ-IDEA-Community
  elif flatpak info com.jetbrains.IntelliJ-IDEA-Ultimate >/dev/null 2>&1; then
    flatpak run --env=IDEA_PROPERTIES=/tmp/idea.properties com.jetbrains.IntelliJ-IDEA-Ultimate
  else
    echo "Nenhuma edição Flatpak do IntelliJ encontrada para rodar em modo diagnóstico."
  fi
fi
