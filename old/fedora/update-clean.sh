#!/usr/bin/env bash
# Fedora Conversion - LeonamSH
# Converted: 2025-10-17
# Notes: automated conversion from apt/apt-get to dnf. 
#        Verify any external repositories (PPAs) manually on Fedora.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "Starting Ubuntu cleanup process..."
echo "---"

clean_residual_configs() {
  echo "Removing residual config packages (dpkg rc)..."
  mapfile -t RC < <(dpkg -l | awk '/^rc/ {print $2}')
  if [[ ${#RC[@]} -gt 0 ]]; then
    sudo dnf -y remove -y "${RC[@]}" || true
  else
    echo "No residual configs found."
  fi
}

clean_cache() {
  echo "Cleaning APT caches..."
  sudo dnf -y autoremove --purge -y || true
  sudo dnf clean all -y || true
  sudo dnf clean all -y || true
}

vacuum_journal() {
  echo "Vacuuming journal logs (7 days)..."
  sudo journalctl --vacuum-time=7d || true
}

clean_thumbs() {
  echo "Cleaning thumbnail cache..."
  rm -rf "${HOME}/.cache/thumbnails/"* || true
}

clean_snap() {
  if command -v snap >/dev/null 2>&1; then
    echo "Removing disabled/old snap revisions..."
    # Snap 2.60+ possui auto-clean; versões antigas podem usar 'snap list --all' + remove --revision
    sudo snap set system refresh.retain=2 || true
    sudo snap saved || true
  fi
}

clean_residual_configs
echo "---"
clean_cache
echo "---"
vacuum_journal
echo "---"
clean_thumbs
echo "---"
clean_snap
echo "---"

echo "Ubuntu cleanup process finished."
