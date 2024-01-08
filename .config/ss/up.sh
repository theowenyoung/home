#!/bin/bash

%/.nix-profile/bin/infisical run --env=prod -- %h/.nix-profile/bin/ssserver -c %h/secret/ss/config.json
