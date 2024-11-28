#!/bin/bash

set -e

echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.conf
sudo sysctl -p
sudo sysctl net.ipv4.tcp_available_congestion_control

SS_PORT=36000
# set method
SS_METHOD="chacha20-ietf-poly1305"

# SS_PASSWORD="Ss#12345678"
SS_PASSWORD=${P:="Ss#12345678"}

# export env
export SS_PASSWORD=$SS_PASSWORD

# get public ip first
PUBLIC_IP_V4=$(curl -s https://api.ipify.org)
# PUBLIC_IP="[$(curl -6 -s https://api64.ipify.org)]"
# COUNTRY=$(curl -s "https://ipapi.co/$PUBLIC_IP/country_name")
# replace space with -
# COUNTRY=${COUNTRY// /-}

THE_DATE=$(date "+%Y%m%d")
# get ss uri
# SS_SERVER_URL="ss://$(printf "%s" "$SS_METHOD:$SS_PASSWORD" | base64)@$PUBLIC_IP:$SS_PORT#ss$THE_DATE"
SS_SERVER_URL_V4="ss://$(printf "%s" "$SS_METHOD:$SS_PASSWORD" | base64)@$PUBLIC_IP_V4:$SS_PORT#ss$THE_DATE"

sudo apt-get -y update
sudo apt -y install qrencode
sudo apt -y install sudo
sudo apt -y install sudo perl
get_latest_release() {
	api_url="https://api.github.com/repos/$1/releases/latest"
	curl --silent "$api_url" | json_pp | grep '"tag_name" :' | sed -E 's/.*"v([^"]+)".*/\1/'
}
NAME="ss"
REPO_NAME="shadowsocks/shadowsocks-rust"
latest_version=$(get_latest_release $REPO_NAME)
echo start install $REPO_NAME latest v${latest_version}
cd /tmp
file_name="shadowsocks-v${latest_version}.x86_64-unknown-linux-gnu"
url="https://github.com/$REPO_NAME/releases/download/v${latest_version}/${file_name}.tar.xz"
echo "$url"
wget "$url"
mkdir -p ${NAME}
mkdir -p /etc/ss
tar -xf ${file_name}.tar.xz --directory ${NAME}
sudo mkdir -p /opt/ss/bin

# try to stop sslocal service first if exists
sudo systemctl stop ss || true
sudo systemctl disable ss || true

sudo cp -R ${NAME}/* /opt/ss/bin/
sudo ln -sf /opt/ss/bin/ssserver /usr/bin/ssserver

sudo tee /etc/systemd/system/ss.service >/dev/null <<EOF
[Unit]
Description=ssserver service
After=network.target

[Service]
Type=simple
Environment=RUST_LOG=error
ExecStart=/opt/ss/bin/ssserver  -s "[::]:$SS_PORT" -m "$SS_METHOD" -k "$SS_PASSWORD" -U 
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
sudo systemctl enable ss
sudo systemctl restart ss
sudo systemctl status ss | head -n 100

# then print ss://link

echo "You can copy the bash script below to install sslocal on your linux machine."
echo " "

# temp start ss server
# echo "ss://$(printf "chacha20-ietf-poly1305:123456" | base64)@$(curl -s https://api.ipify.org):36000" &&  /usr/bin/snap run shadowsocks-rust.ssserver-daemon -s "[::]:36000" -m "chacha20-ietf-poly1305" -k "123456"

# output sh

# echo "$SS_SERVER_URL"

# qrencode -o - -t UTF8 "$SS_SERVER_URL"

echo "$SS_SERVER_URL_V4"

qrencode -o - -t UTF8 "$SS_SERVER_URL_V4"
echo "!!! Please remember to open ports at console"

# print one key command
#

printf "curl -sSL sslocal.owenyoung.com | bash -s -- %s && export http_proxy=http://127.0.0.1:8080 && export https_proxy=http://127.0.0.1:8080\n\n" "$SS_SERVER_URL_V4"

# url encode ss url

urlencode() {
	local length="${#1}"
	for ((i = 0; i < length; i++)); do
		local c="${1:i:1}"
		case $c in
		[a-zA-Z0-9.~_-]) printf "$c" ;;
		*) printf '%%%02X' "'$c" ;;
		esac
	done
}

encoded_ss_url=$(urlencode "$SS_SERVER_URL_V4")

printf "<https://sslocal.owenyoung.com?ss=%s>" "$encoded_ss_url"
