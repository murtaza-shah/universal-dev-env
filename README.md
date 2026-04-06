Super slim, portable dev environment across OSes

## Included

- Debian 13 slim base
- `mise` for tool version management
- Pinned tools from `mise.toml`:
    - Node.js `24.14.1`
    - Neovim `0.12.0` (required for `vim.pack`)
- Common CLI utilities (`git`, `curl`, `ripgrep`, `fd`, `fzf`, `jq`, etc.)
- `pi` CLI (`@mariozechner/pi-coding-agent`)
- Neovim config from: https://github.com/murtaza-shah/nvim-config

## Build

```bash
docker compose build
```

Or without compose:

```bash
docker build -t personal-dev-env:latest .
```

## Run

With compose:

```bash
docker compose run --rm dev
```

Without compose:

```bash
docker run --rm -it -v "$PWD:/workspace" personal-dev-env:latest
```

## Verify quickly inside container

```bash
mise doctor
node --version
nvim --version
pi --version
git --version
```

## Notes

- The container defaults to a non-root `dev` user.
- UID/GID are configurable at build time via compose args (`UID`, `GID`).
- Neovim config is cloned into `~/.config/nvim` during image build.
