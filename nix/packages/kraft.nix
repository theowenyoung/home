

{ gzip, lib, stdenv, fetchurl}:

let 
  os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isx86 then "amd64" else "arm64";
  sha256s = {
    linux_amd64 = "";
    darwin_amd64 = "sha256-XixQreFo2sAWwonumidZ81Lv+dls9LWf6J36PJ+Xhoo=";
    darwin_arm64 = "";
  };
in

stdenv.mkDerivation rec {
    name = "kraft";
    version = "0.8.6";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        url = "https://github.com/unikraft/kraftkit/releases/download/v${version}/kraft_${version}_${os}_${arch}.tar.gz";
        sha256 = sha256s."${os}_${arch}";
    };
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
        tar -xf $src
    '';
    installPhase = ''
        ls -l 
        install -D kraft_${os}_${arch} $out/bin/kraft

    '';
}


