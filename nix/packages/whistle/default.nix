{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "whistle";
  version = "2.9.57";

  src = fetchFromGitHub {
    owner = "avwo";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SKiaGIncFFRFUf8mxdydyg2Y8ZGo9OfzGcQdw+AEx2I=";
  };

  npmDepsHash = "sha256-rwxNdHs8MHhDno2pXQezNFr2taDEgY5Q4S3ys2UtYvM=";
  dontNpmBuild = true;

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "A modern web UI for various torrent clients with a Node.js backend and React frontend";
    homepage = "https://wproxy.org/whistle/";
    license = licenses.mit;
    maintainers = with maintainers; [ avwo ];
  };
}
