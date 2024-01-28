#!/bin/bash
set -e
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
export SS_LOCAL_PORT_HTTP_PORT=$(($SS_LOCAL_PORT + 7000))
export SS_LOCAL_REDIR_PORT=$(($SS_LOCAL_PORT + 59000))

# set config json, do not change
SS_CONFIG=$(
	cat <<EOF
{
  "mode": "tcp_and_udp",
  "no_delay": true,
  "ipv6_first": true,
  "locals":[
    {
      "local_address": "::",
      "local_port":$SS_LOCAL_PORT
    },
    {
      "protocol": "http",
      "local_address": "::",
      "local_port": $SS_LOCAL_PORT_HTTP_PORT
    },
    {
      "protocol": "redir",
      "tcp_redir": "tproxy",
      "udp_redir": "tproxy",
      "local_address": "::",
      "local_port": $SS_LOCAL_REDIR_PORT
    }
  ]
}
EOF
)

# echo "$SS_CONFIG"

# write config json to file
mkdir -p /etc/ss
echo "$SS_CONFIG" >/etc/ss/config.json

sudo apt-get -y update
sudo apt -y install sudo perl
get_latest_release() {
	api_url="https://sslocal.owenyoung.com/proxy/api.github.com/repos/$1/releases/latest"
	curl --silent "$api_url" | json_pp | grep '"tag_name" :' | sed -E 's/.*"v([^"]+)".*/\1/'
}
NAME="ss"
REPO_NAME="shadowsocks/shadowsocks-rust"
latest_version=$(get_latest_release $REPO_NAME)
echo start install $REPO_NAME latest v${latest_version}
cd /tmp
file_name="shadowsocks-v${latest_version}.x86_64-unknown-linux-gnu"
url="https://sslocal.owenyoung.com/proxy/github.com/$REPO_NAME/releases/download/v${latest_version}/${file_name}.tar.xz"
echo "$url"
wget "$url"
mkdir -p ${NAME}
tar -xf ${file_name}.tar.xz --directory ${NAME}
sudo mkdir -p /opt/ss/bin

# try to stop sslocal service first if exists
sudo systemctl stop sslocal || true
sudo systemctl disable sslocal || true

sudo cp -R ${NAME}/* /opt/ss/bin/
sudo ln -sf /opt/ss/bin/sslocal /usr/bin/sslocal

sudo tee /etc/systemd/system/sslocal.service >/dev/null <<EOF
[Unit]
Description=sslocal service
After=network.target

[Service]
Type=simple
Environment=RUST_LOG=error
ExecStart=/opt/ss/bin/sslocal -c /etc/ss/config.json --server-url $SS_SERVER_URL -U
Restart=on-failure
WorkingDirectory=/etc/ss
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
StandardOutput=null
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable sslocal
sudo systemctl restart sslocal
sudo systemctl status sslocal | head -n 100
export http_proxy=http://127.0.0.1:$SS_LOCAL_PORT
export https_proxy=http://127.0.0.1:$SS_LOCAL_PORT
