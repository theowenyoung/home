#!/bin/bash

# is linux, we need to merge tun config  to config.yml
#

function cleanup {
	EXIT_CODE=$?
	set +e # disable termination on error
	# check if /etc/resolv.conf.bak exists
	echo cleanup dns and ipforward
	if [ -f "/etc/resolv.conf.bak" ]; then
		echo "file /etc/resolv.conf.bak exists, restore it"
		sudo cp /etc/resolv.conf.bak /etc/resolv.conf
	else
		echo "file /etc/resolv.conf.bak not exists"
	fi
	sysctl -w net.ipv4.ip_forward=0
	exit $EXIT_CODE
}

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
		echo "$HOME/.config/clash/config_linux_add.yml not exist"
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

	trap cleanup EXIT

	# check if bak exists
	if [ -f "/etc/resolv.conf.bak" ]; then
		echo "file /etc/resolv.conf.bak exists, do nothing"
	else
		echo "file /etc/resolv.conf.bak not exists, backup it"
		sudo cp /etc/resolv.conf /etc/resolv.conf.bak
	fi

	# backup /etc/resolv.conf

	# check /tmp/clash_started is first time run this script, if so sleep 10s to wait for network to be ready

	if [ ! -f "/tmp/clash_started" ]; then
		echo "file /tmp/clash_started not exists, sleep 10s to wait for network to be ready"
		sleep 10
	fi
	# create /tmp/clash_started
	touch /tmp/clash_started

	# change the dns server to 127.0.0.1

	dnsresolv=$(
		cat <<-END
			nameserver 127.0.0.1
			nameserver 119.29.29.29
		END
	)
	echo "$dnsresolv" >/etc/resolv.conf

	# from https://lancellc.gitbook.io/clash/start-clash/clash-tun-mode/setup-system-stack-in-fake-ip-mode

	# set ip forward
	sysctl -w net.ipv4.ip_forward=1

else
	echo "unknow os"
	exit 1
fi

/usr/local/bin/mihomo -f $HOME/.config/clash/config.yml -d $HOME/.config/clash
