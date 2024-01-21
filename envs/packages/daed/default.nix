{unzip, makeWrapper,gzip, fetchgit, lib, stdenv, fetchurl, git}:

# only linux

stdenv.mkDerivation rec {
    name = "daed";
    version = "0.4.0rc1";
    src = fetchurl {
        url = "https://github.com/daeuniverse/${name}/releases/download/v${version}/${name}-linux-x86_64.zip";
        sha256 = "sha256-Udfqjkd8tZ7SgbmLuy647NHWPENp9GKQTyLXdV58MZI=";
    };
    buildInputs = [ unzip makeWrapper ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      unzip $src
    '';
    installPhase = ''
        install -D ./daed-linux-x86_64 $out/bin/raw-daed
        mkdir -p $out/assets
        cp ./geoip.dat $out/assets/geoip.dat
        cp ./geosite.dat $out/assets/geosite.dat
        makeWrapper $out/bin/raw-daed $out/bin/daed \
          --set-default DAE_LOCATION_ASSET $out/assets
    '';
}
