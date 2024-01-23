#!/bin/bash

# install

# must pass an ss url $1
if [ -z "$1" ]; then
	echo "Must pass an ss url, like ss://method:password@server:port"
	exit 1
fi

export SS_SERVER_URL=$1
export SS_LOCAL_PORT=${2:="1080"}
export SS_PROTOCOL=${3:="socks"}
# http proxy port = ss local port + 1
export SS_LOCAL_PORT_HTTP_PORT=$(($SS_LOCAL_PORT + 1))
export SS_LOCAL_REDIR_PORT=$(($SS_LOCAL_PORT + 59000))

# set config json, do not change
SS_CONFIG=$(
	cat <<EOF
{
  "mode": "tcp_and_udp",
  "locals":[
    {
      "local_address":"127.0.0.1",
      "local_port":$SS_LOCAL_PORT
    },
    {
      "protocol": "http",
      "local_address": "127.0.0.1",
      "local_port": $SS_LOCAL_PORT_HTTP_PORT
    },
    {
      "protocol": "redir",
      "local_address": "127.0.0.1",
      "local_port": $SS_LOCAL_REDIR_PORT
    }
  ]
}
EOF
)

echo "$SS_CONFIG"

# write config json to file
mkdir -p /etc/ss
echo "$SS_CONFIG" >/etc/ss/config.json

sudo apt-get -y update
sudo apt -y install snapd
sudo apt -y install sudo
sudo snap install shadowsocks-rust
sudo mkdir -p /etc/systemd/system/snap.shadowsocks-rust.sslocal-daemon.service.d/
sudo tee /etc/systemd/system/snap.shadowsocks-rust.sslocal-daemon.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/snap run shadowsocks-rust.sslocal-daemon -c /etc/ss/config.json --server-url $SS_SERVER_URL -U
EOF
sudo systemctl daemon-reload
sudo systemctl enable snap.shadowsocks-rust.sslocal-daemon
sudo systemctl restart snap.shadowsocks-rust.sslocal-daemon
sudo systemctl status snap.shadowsocks-rust.sslocal-daemon | head -n 100
export http_proxy=http://127.0.0.1:$SS_LOCAL_PORT
export https_proxy=http://127.0.0.1:$SS_LOCAL_PORT
