{ pkgs
, pkgs-stable
, ...
}:
{
  home.packages = with pkgs; [
    expect
    gcc
    gnumake
    rich-presence-cli-linux
    rich-presence-cli-windows
    unzip
    win32yank
    wsl-sudo
    wslu
  ];
}
