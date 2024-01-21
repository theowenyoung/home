#!/bin/bash

set -e

sudo apt-get -y update
sudo apt -y install snapd
sudo apt -y install qrencode
sudo apt -y install sudo
sudo snap install shadowsocks-rust

SS_PORT=36000
# set method
SS_METHOD="chacha20-ietf-poly1305"
SS_PASSWORD="$(openssl rand -base64 12)"

# export env
export SS_PASSWORD=$SS_PASSWORD

# get public ip first
PUBLIC_IP=$(curl -s https://api.ipify.org)
# get country
COUNTRY=$(curl -s "https://ipapi.co/$PUBLIC_IP/country_name")
# replace space with -
COUNTRY=${COUNTRY// /-}

# get ss uri
SS_SERVER_URL="ss://$(printf "%s" "$SS_METHOD:$SS_PASSWORD" | base64)@$PUBLIC_IP:$SS_PORT#$COUNTRY"

# write config to service
sudo mkdir -p /etc/systemd/system/snap.shadowsocks-rust.ssserver-daemon.service.d/
sudo tee /etc/systemd/system/snap.shadowsocks-rust.ssserver-daemon.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStartPre=/bin/logger "$SS_SERVER_URL"
ExecStart=
ExecStart=/usr/bin/snap run shadowsocks-rust.ssserver-daemon -s "[::]:$SS_PORT" -m "$SS_METHOD" -k "$SS_PASSWORD" -U
EOF

sudo systemctl daemon-reload
sudo systemctl enable snap.shadowsocks-rust.ssserver-daemon
sudo systemctl restart snap.shadowsocks-rust.ssserver-daemon
sudo systemctl status snap.shadowsocks-rust.ssserver-daemon | head -n 100

# then print ss://link

echo "You can copy the bash script below to install sslocal on your linux machine."
echo " "

# temp start ss server
# echo "ss://$(printf "chacha20-ietf-poly1305:123456" | base64)@$(curl -s https://api.ipify.org):36000" &&  /usr/bin/snap run shadowsocks-rust.ssserver-daemon -s "[::]:36000" -m "chacha20-ietf-poly1305" -k "123456"

# output sh

cat <<EOYY
sudo apt-get -y update
sudo apt -y install snapd
sudo apt -y install sudo
sudo snap install shadowsocks-rust
export SS_SERVER_URL=$SS_SERVER_URL
sudo mkdir -p /etc/systemd/system/snap.shadowsocks-rust.sslocal-daemon.service.d/
sudo tee /etc/systemd/system/snap.shadowsocks-rust.sslocal-daemon.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/snap run shadowsocks-rust.sslocal-daemon -b "127.0.0.1:8080" --protocol http --server-url $SS_SERVER_URL -U
EOF
sudo systemctl daemon-reload
sudo systemctl enable snap.shadowsocks-rust.sslocal-daemon
sudo systemctl restart snap.shadowsocks-rust.sslocal-daemon
sudo systemctl status snap.shadowsocks-rust.sslocal-daemon | head -n 100
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
EOYY

printf "\n\nEND\n\n"

echo "$SS_SERVER_URL"

qrencode -o - -t UTF8 "$SS_SERVER_URL"

echo "$SS_SERVER_URL"

# print one key command
#

printf "curl -sSL sslocal.owenyoung.com | bash -s -- %s && export http_proxy=http://127.0.0.1:8080 && export https_proxy=http://127.0.0.1:8080\n\n" "$SS_SERVER_URL"
