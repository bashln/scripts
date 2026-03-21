#!/usr/bin/env bash
set -euo pipefail

# Configura Timeshift para snapshots em Btrfs no Pop!_OS 24.04
# Requisitos:
#  - / deve estar em Btrfs
#  - Timeshift instalado (apt install timeshift)
# O script:
#  - Verifica se root está em Btrfs
#  - Cria/ajusta config do Timeshift para Btrfs
#  - Ativa autosnap em upgrades via 'timeshift-autosnap-apt' (se disponível via PPA) OU cria timer próprio

if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado como root." >&2
  exit 1
fi

if ! command -v timeshift >/dev/null 2>&1; then
  echo "Instalando Timeshift..."
  apt update -y && apt install -y timeshift
fi

FSTYPE="$(findmnt -no FSTYPE / || true)"
if [ "$FSTYPE" != "btrfs" ]; then
  echo "Raiz não está em Btrfs (FSTYPE=$FSTYPE). Abortando configuração de snapshots Btrfs." >&2
  exit 0
fi

CFG="/etc/timeshift/timeshift.json"
mkdir -p /etc/timeshift

echo "Gerando configuração do Timeshift para Btrfs..."
cat > "$CFG" <<'JSON'
{
  "backup_device_uuid" : "",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "true",
  "include_btrfs_home" : "true",
  "stop_cron_emails" : "false",
  "schedule_monthly" : "true",
  "schedule_weekly" : "true",
  "schedule_daily" : "true",
  "schedule_hourly" : "false",
  "schedule_boot" : "true",
  "count_monthly" : "2",
  "count_weekly" : "3",
  "count_daily" : "5",
  "count_hourly" : "0",
  "count_boot" : "3",
  "snapshot_size" : "0"
}
JSON

echo "Criando snapshot inicial..."
timeshift --create --comments "snapshot-inicial" --yes || true

# Timer simples para snapshot diário via systemd (caso não use autosnap do apt)
UNIT_DIR="/etc/systemd/system"
cat > "${UNIT_DIR}/timeshift-daily.service" <<'SERVICE'
[Unit]
Description=Timeshift daily snapshot

[Service]
Type=oneshot
ExecStart=/usr/bin/timeshift --create --comments "snapshot-diario" --yes
SERVICE

cat > "${UNIT_DIR}/timeshift-daily.timer" <<'TIMER'
[Unit]
Description=Timeshift daily snapshot timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
TIMER

systemctl daemon-reload
systemctl enable --now timeshift-daily.timer

echo "Configuração de snapshots Btrfs concluída."
