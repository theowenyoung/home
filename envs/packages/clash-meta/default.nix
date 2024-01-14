{ makeWrapper,gzip, fetchgit, lib, stdenv, fetchurl, git}:

let 
  os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isx86 then "amd64" else "arm64";
  sha256s = {
    linux_amd64 = "sha256-8chjjVfgqAcFhUKG7J0KJmgfwYRB19cIvmuTSQKVVKw=";
    darwin_amd64 = "sha256-ogJfYM6/bZRovtxJW67jnmveE6dYhcj5BgTZm4i4D7w=";
  };
in

stdenv.mkDerivation rec {
    showPhaseHeader = true;
    name = "clash-meta";
    pname = "clash";
    version = "1.18.0";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        url = "https://github.com/MetaCubeX/mihomo/releases/download/v${version}/mihomo-${os}-${arch}-v${version}.gz";
        sha256 = sha256s."${os}_${arch}";
    };
    uiSrc = fetchurl {
      url = "https://github.com/MetaCubeX/metacubexd/releases/download/v1.134.0/compressed-dist.tgz";
      sha256 = "sha256-Xx2UReUAxHg4CrKqGs9vGmWRsosJE1OqnYSmp2wOC9M=";  # 此处填写 fetchgit 计算出的哈希值
    };
    buildInputs = [ gzip makeWrapper ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      mkdir -p ./ui
      cd ./ui
      tar -xf $uiSrc
      cd ../
      pwd
      ls -l
      cp $src $TMPDIR/
      cd $TMPDIR
      gunzip -f $(basename $src)
      ls -l
      pwd
    '';
    installPhase = ''
        install -D $(basename $src .gz) $out/bin/clash
        mkdir -p $out/ui
        cp -r ./ui/* $out/ui/
        # 创建包装启动器
        mkdir -p $out/bin
        makeWrapper $out/bin/clash $out/bin/clash-with-ui \
          --add-flags "-ext-ui $out/ui"
    '';
}


