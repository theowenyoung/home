{unzip, makeWrapper,gzip, fetchgit, lib, stdenv, fetchurl, git}:


stdenv.mkDerivation rec {
    showPhaseHeader = true;
    name = "daed";
    version = "0.4.0rc1";
    src = fetchurl {
        url = "https://github.com/daeuniverse/${name}/releases/download/v${version}/${name}-linux-x86_64.zip";
        sha256 = sha256s."${os}_amd64";
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
        install -D ./vlt $out/bin/daed
    '';
}


