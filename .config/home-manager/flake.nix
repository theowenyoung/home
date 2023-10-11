{
  description = "Home Manager config";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-webextfixed.url = "github:wingdeans/nixpkgs/web-ext-node-env";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    devenv.url = "github:cachix/devenv/latest"; # don't follow 
  };

  outputs =
    inputs @ { self
    , nixos
    , nixos-unstable
    , nixpkgs-unstable
    , home-manager
    , devenv
    , nixpkgs-webextfixed
    , ...
    }:
    let
      lib = nixpkgs-unstable.lib;
      homeConfig = system: cfg: hostName:
        let
          username = cfg.username;
          homedir = lib.attrsets.attrByPath [ "homedir" ] "" cfg;
          extraModules = cfg.extraModules;
        in
        #username: system: extraModules: hostName:
        home-manager.lib.homeManagerConfiguration
          rec {
            pkgs = nixpkgs-unstable.legacyPackages.${system}; # or just reimport again
            #pkgs = import <nixpkgs> { }; # or just reimport again

            lib = nixos.lib.extend (libself: super: {
              my = import ./lib.nix {
                inherit system pkgs;
                lib = libself;
                flake = self;
              };
            });

            modules = [
              {
                # alternatively, we can set these in `import nixpkgs { ... }`
                # instead of using legacyPackages above
                nixpkgs.config.allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                nixpkgs.overlays = lib.my.overlays;
              }
              {
                home.username = username;
                home.homeDirectory = if homedir != "" then homedir else lib.my.homedir username;
                home.stateVersion = "22.11";
              }
              ./shared.nix
            ]
            ++ extraModules;

            extraSpecialArgs = {
              pkgs-stable = import nixos { inherit system; config.allowUnfree = true; };
              devenv = devenv.packages.${system}.devenv;
              # web-ext = nixpkgs-webextfixed.legacyPackages.${system}.nodePackages."web-ext";
            };
          };
    in
    {
      homeConfigurations = builtins.mapAttrs (hostname: configurer: configurer hostname) {
        dustbox = homeConfig "x86_64-linux" {
          username = "andrey";
          extraModules = [ ./wsl.nix ];
        };
        x86_64-darwin = homeConfig "x86_64-darwin" {
          # aarch64-darwin ?
          username = "green";
          homedir = "/Users/green";
          extraModules = [ ./macos.nix ];
        };
      };
    };
}


