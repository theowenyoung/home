{ stdenv, fetchFromGitHub, ... }:

let
  pname = "wsl-sudo";
  version = "master";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Chronial";
    repo = "wsl-sudo";
    rev = version;
    sha256 = "sha256-nbvXUvJWtXeDgtaBIh/5Cl732t+WS8l5J3/J2blgYWM=";
  };

  installPhase = ''
    mkdir -p "$out/bin"
    cp wsl-sudo.py "$out/bin/wudo"
  '';
}
