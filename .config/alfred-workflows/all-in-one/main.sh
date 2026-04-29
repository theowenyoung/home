#!/bin/bash

SCRIPT_PATH="$HOME/.config/alfred-workflows/all-in-one/translate.mjs"

exec /opt/homebrew/bin/mise exec -- node "$SCRIPT_PATH" en "$@"
