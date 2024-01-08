#!/bin/bash

set -e

# Must use root
# if [ "$(whoami)" != "root" ]; then
# 	echo "Must run as root"
# 	exit 1
# fi

SS_PORT="36000"
TEMP_SS_START_PORT="35000"
TEMP_SS_END_PORT="35999"

# Create directory for iptables rules
mkdir -p /etc/iptables

# Function to check and add iptables rule if not exists
add_iptables_rule() {
	local table=$1
	local chain=$2
	local protocol=$3
	local dport_start=$4
	local dport_end=$5
	local to_port=$6

	# Check if the rule exists
	if ! iptables -t "$table" -C "$chain" -p "$protocol" --dport "$dport_start":"$dport_end" -j REDIRECT --to-port "$to_port" &>/dev/null; then
		sudo iptables -t "$table" -A "$chain" -p "$protocol" --dport "$dport_start":"$dport_end" -j REDIRECT --to-port "$to_port"
	fi
}

# Add iptables rules for IPv4
add_iptables_rule nat PREROUTING tcp $TEMP_SS_START_PORT $TEMP_SS_END_PORT $SS_PORT
add_iptables_rule nat PREROUTING udp $TEMP_SS_START_PORT $TEMP_SS_END_PORT $SS_PORT

# Save IPv4 rules
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

# Function to check and add ip6tables rule if not exists
add_ip6tables_rule() {
	local table=$1
	local chain=$2
	local protocol=$3
	local dport_start=$4
	local dport_end=$5
	local to_port=$6

	# Check if the rule exists
	if ! ip6tables -t "$table" -C "$chain" -p "$protocol" --dport "$dport_start":"$dport_end" -j REDIRECT --to-port "$to_port" &>/dev/null; then
		sudo ip6tables -t "$table" -A "$chain" -p "$protocol" --dport "$dport_start":"$dport_end" -j REDIRECT --to-port "$to_port"
	fi
}

# Add ip6tables rules for IPv6
add_ip6tables_rule nat PREROUTING tcp $TEMP_SS_START_PORT $TEMP_SS_END_PORT $SS_PORT
add_ip6tables_rule nat PREROUTING udp $TEMP_SS_START_PORT $TEMP_SS_END_PORT $SS_PORT

# Save IPv6 rules
sudo sh -c 'ip6tables-save > /etc/iptables/rules.v6'

# service for user service
# we alread has ss service on ~/.config/systemd/user/ss.service

UNIT=ss

systemctl --user enable $UNIT

systemctl --user daemon-reload
systemctl --user restart $UNIT
systemctl --user status $UNIT
