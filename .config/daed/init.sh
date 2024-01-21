#!/bin/bash

set -e

# check is linux, only run on linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
	echo "only run on linux"
	exit 1
fi

# check is root
if [ "$(id -u)" != "0" ]; then
	echo "Error: You must be root to run this script!"
	exit 1
fi
# add to systemd service

PNAME=daed

service_content="$(
	cat <<EOF
[Unit]
Description=service
After=network.target

[Service]
Type=simple
Environment="HOME=/root"
ExecStart=%h/.config/daed/run.sh
Restart=on-failure
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
[Install]
WantedBy=multi-user.target
EOF
)"

echo "$service_content" >/etc/systemd/system/$PNAME.service

sudo systemctl enable $PNAME
sudo systemctl daemon-reload
sudo systemctl restart $PNAME
sudo systemctl status $PNAME | head -n 100
