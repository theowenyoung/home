{
  description = "Home Manager config";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
        
        # this is a general function, in general, you do not need to change it
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
                nixpkgs.config.allowUnfreePredicate = (pkg: true); # <https://github.com/nix-community/home-manager/issues/2942>
                nixpkgs.overlays = lib.my.overlays;
              }
              {
                home.username = username;
                home.homeDirectory = if homedir != "" then homedir else lib.my.homedir username;
                home.stateVersion = "23.05";
              }
              ./shared.nix
            ]
            ++ extraModules;

            extraSpecialArgs = {
              pkgs-stable = import nixos { inherit system; config.allowUnfree = true; };
              devenv = devenv.packages.${system}.devenv;
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
          # change this to your username
          username = "green";
          homedir = "/Users/green";
          extraModules = [ ./macos.nix ];
        };
      };
    };
}


