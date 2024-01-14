{ unzip, lib, stdenv, fetchurl}:

# https://developer.hashicorp.com/vault/tutorials/hcp-vault-secrets-get-started/hcp-vault-secrets-install-cli
# release
# https://releases.hashicorp.com/vlt

let 
  sha256s = {
    linux_amd64 = "sha256-Gnq1nLFkRvOUEthcqyTscpmGymrA96SdCuIQ4nkCS/I=";
    darwin_amd64 = "sha256-R7DJnMiP1ejg3mDyg/htD12bpG3RC7Smw8binu/f4ds=";
  };
  vlt_os = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  vlt_arch = if stdenv.hostPlatform.isx86 then "amd64" else "arm64";
in

stdenv.mkDerivation rec {
    name = "vlt";
    pname = "vlt";
    version = "1.0.0";
    # linux_amd64 or darwin_amd64 or linux_amd64 or darwin_arm64
    src = fetchurl {
        name = "vlt";
        url = "https://releases.hashicorp.com/vlt/${version}/vlt_${version}_${vlt_os}_${vlt_arch}.zip";
        sha256 = sha256s."${vlt_os}_${vlt_arch}";
    };
    buildInputs = [ unzip ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      unzip $src
    '';
    installPhase = ''
        install -D ./vlt $out/bin/vlt
    '';
}
