{ unzip, lib, stdenv, fetchurl}:

# https://developer.hashicorp.com/vault/tutorials/hcp-vault-secrets-get-started/hcp-vault-secrets-install-cli
# release
# https://releases.hashicorp.com/vlt

let 
  os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isx86 then "x64" else "arm64";
  sha256s = {
    linux_x64 = "sha256-Gnq1nLFkRvOUEthcqyTscpmGymrA96SdCuIQ4nkCS/I=";
darwin_x64 = "";
    # darwin_x64_6_17_1 = "sha256-gDPgel2nWa8A23NkwjRPEe7/c7UWR9OZJr+jbyExuZA=";
  };
in

stdenv.mkDerivation rec {
    name = "nodejs";
    pname = "node";
    version = "0.12.18";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        name = "nodejs";
        url = "https://nodejs.org/download/release/v${version}/node-v${version}-${os}-${arch}.tar.gz";
        sha256 = sha256s."${os}_${arch}";
    };
    # buildInputs = [  ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      tar -xf $src
    '';
    installPhase = ''
        ls -l 
        cp -R ./node-v${version}-${os}-${arch} $out
    '';
}
