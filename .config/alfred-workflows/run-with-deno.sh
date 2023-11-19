#!/bin/bash

SCRIPT_PATH="translate.js" # Change this to your script's path

# List of common locations where Node.js might be installed
NODE_PATHS=(
	"$HOME/.nix-profile/bin/deno"
	"/usr/local/bin/deno"
	"/usr/bin/deno"
	"/opt/local/bin/deno"
	"$HOME/.deno/bin/deno"
)

# Loop through the paths and use the first one that exists
for node in "${NODE_PATHS[@]}"; do
	if [ -f "$node" ]; then
		"$node" run -A $SCRIPT_PATH "$@"
		exit
	fi
done

echo "deno not found. Please install it or check your paths."
exit 1
