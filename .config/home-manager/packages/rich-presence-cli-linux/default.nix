{ stdenv, fetchurl, ... }:

let
  os = "linux";
  ext = "";

  name = "rich-presence";
  pname = "${name}-${os}";
  version = "0.2.0";
  url = "https://github.com/andreykaipov/rich-presence-cli/releases/download/v${version}/${name}-${os}-amd64${ext}";
  sha256 = "sha256-v6wjLL/dLq2iIs8/tb3iO8gNthV1eEQk6qYayQMAIdM=";
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
