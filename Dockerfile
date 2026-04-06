FROM debian:13-slim

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    fzf \
    git \
    jq \
    less \
    locales \
    procps \
    python3 \
    python3-pip \
    ripgrep \
    sudo \
    unzip \
    xz-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Make `fd` available (Debian ships it as `fdfind`)
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Create a non-root user for daily development
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

WORKDIR /workspace

# Copy tool versions early so Docker can cache installs when app code changes
COPY --chown=${USERNAME}:${USERNAME} mise.toml /workspace/mise.toml

USER ${USERNAME}

ENV HOME=/home/${USERNAME} \
    PATH=/home/${USERNAME}/.local/bin:/home/${USERNAME}/.local/share/mise/shims:${PATH}

# Install mise and activate it for interactive shells
RUN curl https://mise.run | sh
RUN echo 'eval "$(~/.local/bin/mise activate bash)"' >> ${HOME}/.bashrc \
    && echo '' >> ${HOME}/.bashrc \
    && echo '# Reminder when opening an interactive shell in the container' >> ${HOME}/.bashrc \
    && echo 'if [[ $- == *i* ]]; then echo "Remember to set OPENCODE_API_KEY for LLM use"; fi' >> ${HOME}/.bashrc

# Install toolchain declared in mise.toml
RUN cd /workspace && ~/.local/bin/mise trust && ~/.local/bin/mise install

# Install pi CLI with npm from the mise-managed node
RUN ~/.local/bin/mise exec -- npm install -g @mariozechner/pi-coding-agent

# Install your Neovim config
RUN mkdir -p ${HOME}/.config \
    && git clone --depth=1 https://github.com/murtaza-shah/nvim-config.git ${HOME}/.config/nvim

CMD ["bash", "-l"]
