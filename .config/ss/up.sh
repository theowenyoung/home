#!/bin/bash

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops exec-env $HOME/.config/env/secrets.yaml '$HOME/.nix-profile/bin/ssserver -v -c $HOME/secret/ss/config.json'
