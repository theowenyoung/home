#!/bin/bash

set -e

# merge config_linux_add.yml content to config_linux.yml

config_source_path="$HOME/secret/clash/config.yml"
config_linux_add_path="$HOME/.config/clash/config_linux_add.yml"
config_target_path="$HOME/.config/clash/config.yml"

if [ ! -f "$config_linux_add_path" ]; then
	echo "config_linux_add.yml not exist"
	exit 1
fi

if [ ! -f "$config_source_path" ]; then
	echo "config_source_path config.yml not exist"
	exit 1
fi

# merge config_linux_add.yml content to config_linux.yml
# clean config_linux.yml
echo "" >"$config_target_path"

# concat config.yml to config_linux_add.yml
cat "$config_linux_add_path" >>"$config_target_path"
cat "$config_source_path" >>"$config_target_path"
