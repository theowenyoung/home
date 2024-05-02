let pkgs = import <nixpkgs> {}; in
pkgs.callPackage ./packages/clash-meta/default.nix {}
