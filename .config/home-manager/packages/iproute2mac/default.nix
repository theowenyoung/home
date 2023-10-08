{ stdenv, lib, fetchurl, ... }:

let
  pname = "iproute2mac";
  version = "0.0.0";
in
stdenv.mkDerivation {
  meta.platforms = lib.platforms.darwin;

  inherit pname version;

  src = fetchurl {
    url = "https://github.com/brona/iproute2mac/raw/master/src/ip.py";
    sha256 = "sha256-5HHChJvDTtDLlMfa70/Um4vM4zuIzsXy0/JhIZfqs3E=";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ip
    chmod +x $out/bin/*
  '';
}
