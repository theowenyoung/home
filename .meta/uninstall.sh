#!/bin/sh

# Change the shell back to regular Bash

chsh -s /bin/bash

# Uninstall Nix

rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

# Don't remove the apps installed by Nix from the configs in ~/.nixpkgs/apps
# rm -rf ~/Applications/Nix\ Apps

# Delete the APFS volume created by the macOS installation for the Nix store at /nix

# sudo rm -rf /nix
# diskutil unmountDisk force /nix
# diskutil apfs deleteVolume 'Nix Store'

if grep -q LABEL=Nix /etc/fstab; then
        echo "Hey! Remove the Nix Store entry from /etc/fstab using 'sudo vifs'"
fi

if grep -q ^nix$ /etc/synthetic.conf; then
        echo "Hey! Remove the nix entry from /etc/synthetic.conf"
fi
