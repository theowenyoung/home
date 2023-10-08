{ stdenv, fetchurl, ... }:

let
  os = "windows";
  ext = ".exe";

  name = "rich-presence";
  pname = "${name}-${os}";
  version = "0.2.0";
  url = "https://github.com/andreykaipov/rich-presence-cli/releases/download/v${version}/${name}-${os}-amd64${ext}";
  sha256 = "sha256-HPtOz3Px6ww6TZAC+IT3sPArIfx8/u36rTfM6/+TDxs=";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    inherit url sha256;
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${name}${ext}
    chmod +x $out/bin/*
  '';
}
