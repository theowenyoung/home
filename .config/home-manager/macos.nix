{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    # coreutils
    # ruby
    # whistle
    # web-ext
    # nodePackages.thelounge
  ];
}
