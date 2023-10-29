#!/bin/bash

set -e

# must use root
if [ "$(whoami)" != "root" ]; then
	echo "must use root"
	exit 1
fi

SS_PORT="36000"
TEMP_SS_START_PORT="35000"
TEMP_SS_END_PORT="35999"

# Write config.json to /etc/opt/ss/config.json
mkdir -p /etc/iptables

# change iptables for multiple ports
iptables -t nat -A PREROUTING -p tcp --dport $TEMP_SS_START_PORT:$TEMP_SS_END_PORT -j REDIRECT --to-port $SS_PORT
iptables -t nat -A PREROUTING -p udp --dport $TEMP_SS_START_PORT:$TEMP_SS_END_PORT -j REDIRECT --to-port $SS_PORT
iptables-save >/etc/iptables/rules.v4

# change iptables for multiple ports ipv6
ip6tables -t nat -A PREROUTING -p tcp --dport $TEMP_SS_START_PORT:$TEMP_SS_END_PORT -j REDIRECT --to-port $SS_PORT
ip6tables -t nat -A PREROUTING -p udp --dport $TEMP_SS_START_PORT:$TEMP_SS_END_PORT -j REDIRECT --to-port $SS_PORT

# save iptables when restart

ip6tables-save >/etc/iptables/rules.v6
