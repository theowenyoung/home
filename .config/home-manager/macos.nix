{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    coreutils
  ];
}
