#!/bin/bash

# is linux, we need to merge tun config  to config.yml

# is macos , we need to cp $HOME/secret/clash/config.yml to $HOME/.config/clash/config.yml

if [ "$(uname)" == "Darwin" ]; then
	# Do something under Mac OS X platform
	cp "$HOME/secret/clash/config.yml" "$HOME/.config/clash/config.yml"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	# Do something under GNU/Linux platform
	echo "is linux"
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
else
	echo "unknow os"
	exit 1
fi

$HOME/.nix-profile/bin/infisical run --env=prod -- $HOME/.nix-profile/bin/sops exec-env $HOME/envs/secrets.yaml '$HOME/.nix-profile/bin/clash-with-ui -f $HOME/.config/clash/config.yml -d $HOME/.config/clash'
