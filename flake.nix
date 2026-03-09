{
  description = "Universal Neovim dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { 
            inherit system; 
            config.allowUnfree = true; 
          };
          nvim = neovim-nightly.packages.${system}.default;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Core Editor
              nvim
              
              # Language Runtimes
              go
              bun
              nodejs_22
              python312
              zig
              
              # C/C++ Toolchain
              clang
              lld
              llvmPackages.bintools
              gnumake
              cmake
              pkg-config
              
              # CLI Utilities required by Neovim/Plugins
              bashInteractive
              git
              curl
              ripgrep
              fd
              fzf
              jq
              unzip
              zip
              cacert
              stdenv.cc.cc.lib
            ];

            shellHook = ''
              export EDITOR=nvim
              export VISUAL=nvim
              export HOME=/home/dev
              export PS1="\[\e[1;32m\]universal-dev \[\e[1;34m\]\w\[\e[0m\] \$ "
              
              echo "-------------------------------------------------------"
              echo " Environment: Go, C (Clang), Bun, Node, Python, Zig"
              echo " Editor: $(nvim --version | head -n 1)"
              echo "-------------------------------------------------------"
            '';
          };
        });
    };
}
