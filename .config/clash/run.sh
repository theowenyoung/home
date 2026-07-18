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
		cp /etc/resolv.conf.bak /etc/resolv.conf
	else
		echo "file /etc/resolv.conf.bak not exists"
	fi
	sysctl -w net.ipv4.ip_forward=0
	exit $EXIT_CODE
}

config_source_path="$HOME/secret/clash/config.yaml"
if [ ! -f "$config_source_path" ]; then
	config_source_path="$HOME/secret/clash/config.yml"
fi

# On macOS, copy the shared config to Mihomo's runtime config path.

if [ "$(uname)" == "Darwin" ]; then
	# Do something under Mac OS X platform
	if [ ! -f "$config_source_path" ]; then
		echo "shared config not found (config.yaml or config.yml)" >&2
		exit 1
	fi
	cp "$config_source_path" "$HOME/.config/clash/config.yml"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	# Do something under GNU/Linux platform
	echo "is linux"
	if [ "$(id -u)" != "0" ]; then
		echo "Error: Linux TUN mode must run as root" >&2
		exit 1
	fi
	# merge config_linux_add.yml content to config_linux.yml

	config_linux_add_path="$HOME/.config/clash/config_linux_add.yml"
	config_target_path="$HOME/.config/clash/config.yml"

	if [ ! -f "$config_linux_add_path" ]; then
		echo "$HOME/.config/clash/config_linux_add.yml not exist"
		exit 1
	fi

	if [ ! -f "$config_source_path" ]; then
		echo "shared config not found (config.yaml or config.yml)" >&2
		exit 1
	fi

	# The shared config and Linux overlay own distinct top-level keys, so they
	# can be composed without requiring a third-party YAML processor.
	config_tmp_path="$(mktemp "${config_target_path}.tmp.XXXXXX")" || exit 1
	if ! {
		cat "$config_source_path"
		printf '\n'
		cat "$config_linux_add_path"
	} >"$config_tmp_path"; then
		echo "failed to compose the Linux mihomo configuration" >&2
		rm -f "$config_tmp_path"
		exit 1
	fi
	chmod 600 "$config_tmp_path"

	# Refuse accidental duplicate top-level keys instead of handing an
	# ambiguous YAML document to Mihomo. awk is part of a standard Debian base.
	if ! duplicate_keys="$(awk '
		match($0, /^[[:alnum:]_-]+[[:space:]]*:/) {
			key = substr($0, RSTART, RLENGTH)
			sub(/[[:space:]]*:$/, "", key)
			if (++seen[key] == 2) {
				duplicates = duplicates (duplicates ? ", " : "") key
			}
		}
		END {
			if (duplicates) {
				print duplicates
				exit 1
			}
		}
	' "$config_tmp_path")"; then
		echo "duplicate top-level YAML keys: $duplicate_keys" >&2
		rm -f "$config_tmp_path"
		exit 1
	fi

	# Validate before replacing the last known-good runtime configuration or
	# changing DNS and sysctls.
	if ! /usr/local/bin/mihomo -t -f "$config_tmp_path" -d "$HOME/.config/clash"; then
		echo "merged mihomo configuration is invalid" >&2
		rm -f "$config_tmp_path"
		exit 1
	fi
	if ! mv "$config_tmp_path" "$config_target_path"; then
		echo "failed to install the merged mihomo configuration" >&2
		rm -f "$config_tmp_path"
		exit 1
	fi

	trap cleanup EXIT

	# check if bak exists
	if [ -f "/etc/resolv.conf.bak" ]; then
		echo "file /etc/resolv.conf.bak exists, do nothing"
	else
		echo "file /etc/resolv.conf.bak not exists, backup it"
		cp /etc/resolv.conf /etc/resolv.conf.bak
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

/usr/local/bin/mihomo -f "$HOME/.config/clash/config.yml" -d "$HOME/.config/clash"
