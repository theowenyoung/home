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
      cachix
      devenv
      direnv
      nix-direnv
      git
      fzf
      nodejs
      nodePackages.npm
      deno
      mas
      tmux
      neovim
      ripgrep
      home-manager
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];

  fonts.fontconfig.enable = true;
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  home.activation = lib.my.activationScripts (map toString [
    ''
      mkdir -p ~/.{cache,config,local,run}
    ''
  ]);
}

