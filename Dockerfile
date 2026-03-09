FROM debian:stable-slim

# 1. Install minimal bootstrap dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git xz-utils sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup the non-root 'dev' user
RUN useradd -m -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev

# 3. Install Determinate Nix
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --init none --no-confirm

# 4. Configure Nix
ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"
RUN mkdir -p /etc/nix && echo "trusted-users = root dev" >> /etc/nix/nix.conf
RUN chown -R dev:dev /nix/var/nix

# 5. Prepare the Application directory
WORKDIR /opt/universal-nvim
# Explicitly COPY only what exists
COPY flake.nix /opt/universal-nvim/
COPY scripts/update-nvim-config.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/update-nvim-config.sh /usr/local/bin/docker-entrypoint.sh

# 6. Pre-initialize the Nix Store
# This will generate the flake.lock INSIDE the image build context
RUN nix --extra-experimental-features "nix-command flakes" \
    develop . --impure --command true

# 7. Finalize home directory
RUN mkdir -p /home/dev/.local/share/nvim /home/dev/.local/state/nvim /home/dev/.cache/nvim \
    && chown -R dev:dev /opt/universal-nvim /home/dev

USER dev
ENV USER=dev
ENV HOME=/home/dev
ENV WORKSPACE=/workspace

ENTRYPOINT ["docker-entrypoint.sh"]
