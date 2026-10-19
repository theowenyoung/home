#!/bin/bash

SCRIPT_PATH="$HOME/.config/alfred-workflows/all-in-one/translate.mjs"

source "$HOME/.config/alfred-workflows/all-in-one/proxy-env.sh"

exec /opt/homebrew/bin/mise exec -- node "$SCRIPT_PATH" en "$@"
