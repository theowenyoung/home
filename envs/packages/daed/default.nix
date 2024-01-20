{unzip, makeWrapper,gzip, fetchgit, lib, stdenv, fetchurl, git}:

let 
  os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isx86 then "x86_64" else "arm64";
  sha256s = {
    linux_amd64 = "";
    darwin_amd64 = "";
  };
in

stdenv.mkDerivation rec {
    showPhaseHeader = true;
    name = "daed";
    version = "0.4.0rc1";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        url = "https://github.com/daeuniverse/${name}/releases/download/v${version}/${name}-${os}-${arch}.zip";
        sha256 = sha256s."${os}_${arch}";
    };
    # uiSrc = fetchurl {
    #   url = "https://github.com/daeuniverse/daed/releases/download/v${version}/web.zip";
    #   sha256 = "";  # 此处填写 fetchgit 计算出的哈希值
    # };
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


