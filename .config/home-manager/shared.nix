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
    home.activation.firstScript = lib.hm.dag.entryAfter [
        "installPackages"
        "onFilesChange"
        "reloadSystemd"
    ] ''
      mkdir -p ~/.{cache,config,local,run}
    '';

  home.activation.secondScript = lib.hm.dag.entryAfter ["firstScript"] ''
    echo "Everything is ready now!"
  '';
}

