#!/bin/bash

# is linux, we need to merge tun config  to config.yml
#

function cleanup {
	EXIT_CODE=$?
	set +e # disable termination on error
	# check if /etc/resolv.conf.bak exists
	echo cleanup ipforward
	sysctl -w net.ipv4.ip_forward=0
	exit $EXIT_CODE
}

# is macos , we need to cp $HOME/secret/clash/config.yml to $HOME/.config/clash/config.yml

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	# Do something under GNU/Linux platform
	echo "is linux"

	trap cleanup EXIT

	if [ ! -f "/tmp/daed_started" ]; then
		echo "file /tmp/daed_started not exists, sleep 10s to wait for network to be ready"
		sleep 10
	fi
	# create /tmp/clash_started
	touch /tmp/daed_started

	# from https://lancellc.gitbook.io/clash/start-clash/clash-tun-mode/setup-system-stack-in-fake-ip-mode
	# set ip forward
	sysctl -w net.ipv4.ip_forward=1

else
	echo "unknow os"
	exit 1
fi

$HOME/.nix-profile/bin/daed run
