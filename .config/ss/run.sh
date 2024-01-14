#!/bin/bash

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops exec-env $HOME/envs/secrets.yaml '$HOME/.nix-profile/bin/ssserver -c $HOME/.config/ss/config.json'
