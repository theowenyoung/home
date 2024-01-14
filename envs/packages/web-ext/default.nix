{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "web-ext";
  version = "7.9.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "web-ext";
    rev = version;
    hash = "sha256-7fBUWQFUsIGQnyNhZISvdtAQMAMZ38mbzGuC+6Cwu1Y=";
  };

  npmDepsHash = "sha256-3Dq4sNPZm9fDxPxOZL+rDxFA/FEs2/+zdz8sF3JFJ3s=";

  # web-ext defaults to development builds:
  #   https://github.com/mozilla/web-ext/blob/master/CONTRIBUTING.md#build-web-ext
  # Use production build while still installing devDependencies
  NODE_ENV = "production";

  npmInstallFlags = "--include=dev";
  # preBuild = ''
  #   export NODE_ENV=production
  # '';

  meta = {
    description = "A command line tool to help build, run, and test web extensions";
    homepage = "https://github.com/mozilla/web-ext";
    license = lib.licenses.mpl20;
    mainProgram = "web-ext";
    maintainers = with lib.maintainers; [ ];
  };
}
