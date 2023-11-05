let pkgs = import <nixpkgs> {}; in
pkgs.callPackage ./packages/vlt/default.nix {}
