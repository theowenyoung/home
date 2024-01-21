let pkgs = import <nixpkgs> {}; in
pkgs.callPackage ./packages/daed/default.nix {}
