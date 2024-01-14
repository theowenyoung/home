#!/bin/bash

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops -d $HOME/envs/secrets.yaml
