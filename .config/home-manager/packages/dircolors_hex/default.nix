{ stdenv, fetchFromGitHub, ... }:

let
  pname = "dircolors.hex";
  version = "master";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "andreykaipov";
    repo = pname;
    rev = version;
    sha256 = "sha256-27HugC8UZJKVCmeuE7+8iR4Lyh6BSKEL3SEWm4DtkgE=";
  };

  installPhase = ''
    mkdir -p "$out/bin"
    cp bin/dircolors.hex "$out/bin/dircolors.hex"
  '';
}
