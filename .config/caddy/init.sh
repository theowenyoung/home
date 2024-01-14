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

PNAME=caddy

service_content="$(
	cat <<EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
Environment="HOME=/root"
ExecStart=%h/.config/caddy/run.sh
WorkingDirectory=%h/.config/caddy
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF
)"

echo "$service_content" >/etc/systemd/system/$PNAME.service

sudo systemctl enable $PNAME
sudo systemctl daemon-reload
sudo systemctl restart $PNAME
sudo systemctl status $PNAME
