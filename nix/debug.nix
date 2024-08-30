let pkgs = import <nixpkgs> {}; in
pkgs.callPackage ./packages/mongodb-ce.nix {}
