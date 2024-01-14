#!/bin/bash

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops exec-env $HOME/envs/secrets.yaml 'echo "ss://$(printf "chacha20-ietf-poly1305:$SHADOWSOCKS_PASSWORD" | base64)@$SHADOWSOCKS_SERVER_KO:36000"'
