#!/usr/bin/env bash
set -euo pipefail

# Configuration with defaults
REPO="${NVIM_CONFIG_REPO:-https://github.com/murtaza-shah/nvim-config}"
REF="${NVIM_CONFIG_REF:-main}"
UPDATE="${NVIM_CONFIG_UPDATE:-1}"
TARGET="/home/dev/.config/nvim"

log() { printf "[\033[0;34mconfig\033[0m] %s\n" "$*"; }

mkdir -p "$(dirname "$TARGET")"

if [ ! -d "$TARGET/.git" ]; then
    log "Cloning Neovim config from $REPO..."
    git clone "$REPO" "$TARGET"
    git -C "$TARGET" checkout "$REF"
elif [ "$UPDATE" = "1" ]; then
    log "Checking for config updates (REF: $REF)..."
    # Attempt to fetch and reset
    if git -C "$TARGET" fetch origin "$REF" --quiet; then
        git -C "$TARGET" reset --hard "origin/$REF" --quiet
        log "Config successfully updated."
    else
        log "Warning: Could not update config (network issue?), staying on local state."
    fi
else
    log "NVIM_CONFIG_UPDATE=0, skipping update."
fi
