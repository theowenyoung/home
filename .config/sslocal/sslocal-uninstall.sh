#!/bin/bash
sudo systemctl stop snap.shadowsocks-rust.sslocal-daemon
sudo systemctl disable snap.shadowsocks-rust.sslocal-daemon

# remove http proxy and socks5 proxy
unset https_proxy
unset http_proxy
