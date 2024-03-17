{
  description = "my global env";

  inputs = {
	  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv/latest";
  };
  outputs = { self, nixpkgs,devenv }: {
    # profile for my arm -darwin machine
    
    packages."aarch64-darwin".default = let
      system = "aarch64-darwin";
      pkgs = (nixpkgs.legacyPackages.${system}.extend (import ./overlays.nix));
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        nixVersions.nix_2_21
        bashInteractive
        cachix
        # direnv
        devenv.packages."${system}".default
        # nix-direnv
        git
        fzf
        inetutils # telnet
        awscli2
        stripe-cli
        jq
        miniserve # http serve
        nodejs_20
        # (pkgs.callPackage ./packages/nodejs/default.nix {})
        nodePackages.pnpm
        nodePackages.nodemon
        # nodePackages.wrangler # broken https://github.com/NixOS/nixpkgs/issues/265653
        nodePackages.grunt-cli
        shadowsocks-rust
        # clash-meta # clash
        # (pkgs.callPackage ./packages/clash-meta/default.nix {})
        deno
        infisical
        wget
        mas
        tmux
        neovim
        ripgrep
        (nerdfonts.override { fonts = [ "FiraCode" ]; })
        coreutils
        ruby
        # custom packages
        (pkgs.callPackage ./packages/whistle/default.nix {})
        (pkgs.callPackage ./packages/web-ext/default.nix {})
        # yq
        (pkgs.callPackage ./packages/yq/default.nix {})
        gnupg
        age
        sops
        asciidoctor
      ];
    };


    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 这里导入之前我们使用的 configuration.nix，
        # 这样旧的配置文件仍然能生效
        ./configuration.nix
      ];
    };

    # profile for my x86_64-darwin machine
    packages."x86_64-darwin".x86 = let
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
        stripe-cli
        jq
        miniserve # http serve
        nodejs_20
        # (pkgs.callPackage ./packages/nodejs/default.nix {})
        nodePackages.pnpm
        nodePackages.nodemon
        # nodePackages.wrangler # broken https://github.com/NixOS/nixpkgs/issues/265653
        nodePackages.grunt-cli
        shadowsocks-rust
        # clash-meta # clash
        # (pkgs.callPackage ./packages/clash-meta/default.nix {})
        deno
        infisical
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
        # yq
        (pkgs.callPackage ./packages/yq/default.nix {})
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
      bashInteractive
      git
      tmux
      fzf
      neovim
      ripgrep
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
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
        bashInteractive
        iptables
        # infisical
        # sops
        (pkgs.callPackage ./packages/clash-meta/default.nix {})
        # (pkgs.callPackage ./packages/daed/default.nix {})

      ];
    };

  };
}
