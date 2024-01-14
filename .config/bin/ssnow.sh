#!/bin/bash

# install

sudo apt-get -y update
sudo apt -y install snapd
sudo apt -y install sudo
snap install shadowsocks-rust

export SERVER_URL=
shadowsocks-rust.sslocal -b 127.0.0.1:1080 --server-url $SERVER_URL &
shadowsocks-rust.sslocal --protocol http -b 127.0.0.1:8080 --server-url $SERVER_URL &
# sslocal -b 127.0.0.1:1080 --server-url ss://xxxx@xxxx:333 &

# add http proxy and socks5 proxy
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
export all_proxy=socks5://127.0.0.1:1080

# remove http proxy and socks5 proxy
# unset https_proxy
# unset http_proxy
# unset all_proxy
