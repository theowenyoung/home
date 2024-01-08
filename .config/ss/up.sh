#!/bin/bash

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/ssserver -c $HOME/secret/ss/config.json
