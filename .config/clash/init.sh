#!/bin/bash

set -e

# check is linux, only run on linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
	echo "only run on linux"
	exit 1
fi

# add to systemd service

# use run.sh

service_content="$(
	cat <<EOF
[Unit]
Description=service
After=network.target

[Service]
Type=simple
ExecStart=/opt/ss/bin/sslocal -c /etc/opt/ss/config.json
Restart=on-failure
WorkingDirectory=/etc/opt/ss
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
StandardOutput=null
[Install]
WantedBy=multi-user.target
EOF
)"

# write ss_service to /etc/systemd/system/ss.service

echo "$ss_service" >/etc/systemd/system/ss.service

UNIT=ss

systemctl enable $UNIT

systemctl daemon-reload
systemctl restart $UNIT
systemctl status $UNIT
