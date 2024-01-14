{ gzip, lib, stdenv, fetchurl}:

let 
  os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isx86 then "amd64" else "arm64";
  sha256s = {
    linux_amd64 = "";
    darwin_amd64 = "sha256-ogJfYM6/bZRovtxJW67jnmveE6dYhcj5BgTZm4i4D7w=";
  };
in

stdenv.mkDerivation rec {
    name = "clash-meta";
    pname = "clash";
    version = "1.18.0";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        url = "https://github.com/MetaCubeX/mihomo/releases/download/v${version}/mihomo-${os}-${arch}-v${version}.gz";
        sha256 = sha256s."${os}_${arch}";
    };
    buildInputs = [ gzip ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      cp $src $TMPDIR/
      cd $TMPDIR
      gunzip -f $(basename $src)
    '';
    installPhase = ''
        ls -l 
        install -D $(basename $src .gz) $out/bin/clash

    '';
}


