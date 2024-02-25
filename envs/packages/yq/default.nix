
{ gzip, lib, stdenv, fetchurl}:

let 
  os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isx86 then "amd64" else "arm64";
  sha256s = {
    linux_amd64 = "";
    darwin_amd64 = "sha256-XixQreFo2sAWwonumidZ81Lv+dls9LWf6J36PJ+Xhoo=";
    darwin_arm64 = "sha256-DGguCmXnJUUX2a1qV5ZLVgv5zPQmLDWsytcYdS/TM/I=";
  };
in

stdenv.mkDerivation rec {
    name = "yq";
    pname = "yq";
    version = "4.40.5";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        url = "https://github.com/mikefarah/yq/releases/download/v${version}/yq_${os}_${arch}.tar.gz";
        sha256 = sha256s."${os}_${arch}";
    };
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
        tar -xf $src
    '';
    installPhase = ''
        ls -l 
        install -D yq_${os}_${arch} $out/bin/yq

    '';
}


