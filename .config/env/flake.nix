{
  description = "my global env";

  inputs = {
	  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv/latest";
  };
  outputs = { self, nixpkgs,devenv }: {
    # default profile for my x86_64-darwin machine
    packages."x86_64-darwin".default = let
        system = "x86_64-darwin";
        pkgs = (nixpkgs.legacyPackages.${system}.extend (import ./overlays.nix));
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        bashInteractive
        cachix
        direnv
        devenv.packages."${system}".default
        nix-direnv
        git
        fzf
        inetutils # telnet
        awscli2
        jq
        miniserve # http serve
        nodejs_20
        # (pkgs.callPackage ./packages/nodejs/default.nix {})
        nodePackages.pnpm
        nodePackages.nodemon
        nodePackages.grunt-cli
        deno
        wget
        mas
        tmux
        neovim
        ripgrep
        (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
        coreutils
        ruby
        # custom packages
        (pkgs.callPackage ./packages/whistle/default.nix {})
        (pkgs.callPackage ./packages/web-ext/default.nix {})
        gnupg
        age
        sops
        (pkgs.callPackage ./packages/vlt/default.nix {})
        asciidoctor
      ];
    };

    # profile for my x86_64-darwin machine with less packages
    packages."x86_64-darwin".pure = let
	      pkgs = nixpkgs.legacyPackages."x86_64-darwin";
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
      bashInteractive
      git
      tmux
      fzf
      neovim
      ripgrep
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      ];
    };

    # profile for x86_64-linux proxy machine with less packages
    packages."x86_64-linux".proxy = let
	      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        git
        gnumake
        gcc
        bashInteractive
        iptables
        tmux
        deno
        neovim
        fzf
        ripgrep
        unzip
        nodejs
        nodePackages.npm
        shadowsocks-rust
        sops
        (pkgs.callPackage ./packages/vlt/default.nix {})
      ];
    };
  };
}
