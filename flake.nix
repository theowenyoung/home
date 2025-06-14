{
  description = "my global env";

  inputs = {
	  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv/latest";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
        # 添加特定版本的 Deno 输入
    deno-old.url = "github:NixOS/nixpkgs/351e470e61610ab5cc1625891d6b540ff638796f";
    deno-old.flake = false;
  };
  outputs = { self, nixpkgs,devenv,disko,agenix,deno-old}: {
    # profile for my arm -darwin machine
    
    packages."aarch64-darwin".default = let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (final: prev: {
            deno = (import deno-old { inherit system; }).deno;
          })
        ];
      };
      customOverlays = import ./nix/overlays.nix;
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        deno
        cachix
        # fastlane
        # direnv
        devenv.packages."${system}".default
        # nix-direnv
        git
        fzf
        inetutils # telnet
        awscli2
        claude-code
        mdbook
        hurl
        stripe-cli
        jq
        miniserve # http serve
        nss
        cargo
        mkcert # ssl, localhost
        nodejs
        # mongodb
        mongodb-ce
        pnpm
        # (pkgs.callPackage ./nix/packages/nodejs/default.nix {})
        nodePackages.nodemon
        # nodePackages.wrangler # broken https://github.com/NixOS/nixpkgs/issues/265653
        nodePackages.grunt-cli
        yarn
        shadowsocks-rust
        python3
        python3Packages.virtualenv
        # clash-meta # clash
        # (pkgs.callPackage ./nix/packages/clash-meta/default.nix {})
        infisical
        wget
        mas
        tmux
        neovim
        ripgrep
        nerd-fonts.fira-code
        coreutils
        ruby
        # custom packages
        (pkgs.callPackage ./nix/packages/whistle/default.nix {})
        (pkgs.callPackage ./nix/packages/web-ext/default.nix {})
        # yq
        (pkgs.callPackage ./nix/packages/yq/default.nix {})
        gnupg
        age
        sops
        asciidoctor
        (pkgs.callPackage ./nix/packages/yq/default.nix {})
        (pkgs.callPackage ./nix/packages/kraft.nix {})
        niv # nix version manager
        (pkgs.callPackage "${(import ./nix/sources.nix).agenix}/pkgs/agenix.nix" {})
        # (pkgs.callPackage "${(import ./nix/sources.nix).flox}/flake.nix" {})
        nodePackages.node2nix
        mise
        kubectl
        nmap
        kubernetes-helm
        kompose
        envsubst
        devbox
        caddy
      ];
    };


    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./nix/configuration.nix
        agenix.nixosModules.default
      ];
    };

    # profile for my x86_64-darwin machine
    packages."x86_64-darwin".x86 = let
        system = "x86_64-darwin";
        pkgs = (nixpkgs.legacyPackages.${system}.extend (import ./nix/overlays.nix));
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        cachix
        direnv
        devenv.packages."${system}".default
        nix-direnv
        git
        fzf
        inetutils # telnet
        awscli2
        stripe-cli
        jq
        miniserve # http serve
        nodejs_20
        # (pkgs.callPackage ./nix/packages/nodejs/default.nix {})
        nodePackages.pnpm
        nodePackages.nodemon
        # nodePackages.wrangler # broken https://github.com/NixOS/nixpkgs/issues/265653
        nodePackages.grunt-cli
        shadowsocks-rust
        # clash-meta # clash
        # (pkgs.callPackage ./nix/packages/clash-meta/default.nix {})
        deno
        infisical
        wget
        mas
        tmux
        neovim
        ripgrep
        coreutils
        nerd-fonts.fira-code
        # ruby
        # rubyPackages.rails
        # custom packages
        (pkgs.callPackage ./nix/packages/whistle/default.nix {})
        (pkgs.callPackage ./nix/packages/web-ext/default.nix {})
        # yq
        (pkgs.callPackage ./nix/packages/yq/default.nix {})
        gnupg
        age
        sops
        asciidoctor
      ];
    };



    # profile for my x86_64-darwin machine with less packages
    packages."x86_64-darwin".pure = let
	      pkgs = nixpkgs.legacyPackages."x86_64-darwin";
    in pkgs.buildEnv {
      name = "pure-env";
      paths = with pkgs; [
      git
      tmux
      fzf
      neovim
      ripgrep
      nerd-fonts.fira-code
      ];
    };

    # profile for x86_64-linux proxy build machine with less packages
    packages."x86_64-linux".proxybuild = let
	      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in pkgs.buildEnv {
      name = "proxy-build";
      paths = with pkgs; [
        git
        gnumake
        gcc
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
        infisical
        sops
      ];
    };

        # profile for x86_64-linux proxy machine with less packages
    packages."x86_64-linux".proxy = let
	      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        git
        iptables
        shadowsocks-rust
        infisical
        sops
      ];
    };



    # profile for x86_64-linux homedebian build machine with less packages
    packages."x86_64-linux".homedebian = let
	      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in pkgs.buildEnv {
      name = "homedebian";
      paths = with pkgs; [
        git
        gnumake
        gcc
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
        infisical
        sops
      ];
    };

    # profile for x86_64-linux rootonly build machine with less packages
    packages."x86_64-linux".rootonly = let
	      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in pkgs.buildEnv {
      name = "rootonly";
      paths = with pkgs; [
        git
        gnumake
        caddy
        gcc
        adguardhome
        iptables
        # infisical
        # sops
        (pkgs.callPackage ./nix/packages/clash-meta/default.nix {})
        # (pkgs.callPackage ./nix/packages/daed/default.nix {})

      ];
    };

  };
}
