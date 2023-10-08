{ config
, lib
, pkgs
, pkgs-stable
, devenv
, web-ext
, ...
}:
{
  home.packages = with pkgs;
    [
      bashInteractive
      devenv
      git
      nodejs
      deno
      mas
      tmux
      neovim
      ripgrep
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      web-ext
    ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  home.activation = lib.my.activationScripts (map toString [
    ''
      mkdir -p ~/.{cache,config,local,run}
    ''
  ]);
}

# (pkgs.writeText "hello" ''
#   echo ${pkgs.bash-completion}
# '')
