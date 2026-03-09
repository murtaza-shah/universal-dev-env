#!/usr/bin/env bash
set -e

# 1. Fix Volume Permissions
# Named volumes mounted by Docker are often owned by root. 
# We fix ownership of the home directory subfolders so the dev user can write.
if [ "$(id -u)" -eq 1000 ]; then
    sudo chown -R dev:dev /home/dev/.local /home/dev/.config /home/dev/.cache 2>/dev/null || true
fi

# 2. Sync Neovim Config
/usr/local/bin/update-nvim-config.sh

# 3. Enter Workspace
cd /workspace

# 4. Determine execution path
if [ $# -eq 0 ]; then
    # Default: Enter the Nix Dev Shell
    # --impure is required to keep $HOME and $USER variables inside the shell
    exec nix --extra-experimental-features "nix-command flakes" \
         develop /opt/universal-nvim --impure \
         --command bash
else
    # Allow bypassing the shell (e.g. 'docker run ... universal-nvim nvim .')
    # We still use 'nix develop -c' so the command has access to the toolchains
    exec nix --extra-experimental-features "nix-command flakes" \
         develop /opt/universal-nvim --impure \
         --command "$@"
fi
