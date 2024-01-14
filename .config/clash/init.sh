#!/bin/bash

set -e

# check is linux, only run on linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
	echo "only run on linux"
	exit 1
fi

# add to systemd service

# wget data first
wget https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country.mmdb -O ~/.config/clash/Country.mmdb
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202401132209/geosite.dat -O ~/.config/clash/geosite.dat
# use run.sh

PNAME=clash

service_content="$(
	cat <<EOF
[Unit]
Description=service
After=network.target

[Service]
Type=simple
EnvironmentFile=%h/.infisicalenv
Environment="HOME=/root"
ExecStart=%h/.config/clash/run.sh
WorkingDirectory=%h/.config/clash
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
sudo systemctl status $PNAME
