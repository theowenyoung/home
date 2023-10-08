#!/bin/sh

cmd='
    git clean -xdff
    -e .config/sh/env.work
    -e .config/nix/links
    -e .config/nvim/autoload
    .config bin/
'

todo="$($cmd -n)"

if [ -z "$todo" ]; then
        echo "Configuration is already pristine!"
else
        echo "$todo"
        echo
        echo "press <enter> to continue, <ctrl>+c (^C) to cancel"
        read -r
        $cmd
fi
