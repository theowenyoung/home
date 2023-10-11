{ config
, lib
, pkgs
, pkgs-stable
, devenv
, ...
}:
{
  home.enableNixpkgsReleaseCheck = false;
  home.packages = with pkgs;
    [
      bashInteractive
      devenv
      git
      nodejs
      nodePackages.npm
      deno
      mas
      tmux
      neovim
      ripgrep
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    home-manager = {
      enable = true;
    };

    
  };
  fonts.fontconfig.enable = true;

  home.activation = lib.my.activationScripts (map toString [
    ''
      mkdir -p ~/.{cache,config,local,run}
    ''
  ]);
}

