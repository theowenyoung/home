{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    coreutils
    whistle
    web-ext
  ];
}
