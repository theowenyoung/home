{unzip, makeWrapper,gzip, fetchgit, lib, stdenv, fetchurl, git}:

# only linux

stdenv.mkDerivation rec {
    # showPhaseHeader = true;
    name = "daed";
    version = "0.4.0rc1";
    src = fetchurl {
        url = "https://github.com/daeuniverse/${name}/releases/download/v${version}/${name}-linux-x86_64.zip";
        sha256 = "sha256-Udfqjkd8tZ7SgbmLuy647NHWPENp9GKQTyLXdV58MZI=";
    };
    buildInputs = [ unzip ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      pwd
      ls -l
      unzip $src
      ls -l 
      pwd
    '';
    installPhase = ''
        ls -l
        pwd
        install -D ./daed-linux-x86_64 $out/bin/daed
    '';
}


