#!/bin/sh
# Record path to nix executable.
nix_binary_path=$(readlink -f $(which nix))

# Record index of nix installation in profile.
nix_profile_index=$(nix profile list | grep $(echo $nix_binary_path | sed 's|^/nix/store/\([^/]*\)/.*$|\1|g') | cut -d ' ' -f 1)

# Remove the symbolic link to the nix executable.
nix profile remove $nix_profile_index

# Install the latest nix release.
# $nix_binary_path profile install "nixpkgs#nix"
$nix_binary_path profile install github:NixOS/nixpkgs/nixos-unstable#nixVersions.nix_2_19

# Display the new nix version.
nix --version
