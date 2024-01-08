#!/bin/bash

# $HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops exec-env $HOME/.config/env/secrets.yaml '$HOME/.nix-profile/bin/sslocal -b "127.0.0.1:1080" -s "$SHADOWSOCKS_SERVER_KO:36000" -m "chacha20-ietf-poly1305" -k "$SS_PASSWORD"'

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops exec-env $HOME/.config/env/secrets.yaml 'echo $HOME/.nix-profile/bin/sslocal -b "127.0.0.1:1080" -s "$SHADOWSOCKS_SERVER_KO:36000"  -k "${SS_PASSWORD}" --yes -m "chacha20-ietf-poly1305"'
