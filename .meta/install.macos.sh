#!/bin/sh
# shellcheck disable=SC2024

set -e

main() {
        echo "Running macOS configuration"
        augment_sudoers
        set_power_schedule
        enable_remote_login
        fix_dns
        fix_hosts
        # augment_pamd_sudo
        echo "macOS configuration good"
}

set_power_schedule() {
        # only for work
        # we want to power it on so we can SSH into it

        if ! [ -r ~/.config/sh/env.work ]; then return; fi

        output="$(pmset -g sched)"
        expected='Repeating power events:
  wakepoweron at 8:00AM weekdays only
  sleep at 6:00PM weekdays only'

        if [ "$output" = "$expected" ]; then return; fi

        echo "Adjusting work power/sleep schedule"

        sudo pmset repeat \
                wakeorpoweron MTWRF 08:00:00 \
                sleep MTWRF 18:00:00

        pmset -g sched
}

enable_remote_login() {
        if [ -z "$FORCE_REINSTALL" ] &&
                nc -z localhost 22 >/dev/null; then return; fi

        sudo systemsetup -getremotelogin
        sudo systemsetup -setremotelogin on || {
                echo >&2 "You have to go to Security & Privacy and grant iTerm (or whatever you're using) full disk access"
        }
}

fix_dns() {
        if [ -z "$FORCE_REINSTALL" ] &&
                [ "$(scutil --dns | grep -E '1.1.1.1|8.8.8.8' | sort | uniq | wc -l)" -eq 2 ]; then
                return
        fi

        # networksetup -listallnetworkservices
        sudo networksetup -setsearchdomains Wi-Fi empty
        sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
}

fix_hosts() {
        if [ -z "$FORCE_REINSTALL" ] &&
                grep -q '# added by install.macos.sh' /etc/hosts; then return; fi

        sudo tee /etc/hosts >/dev/null <<EOF
# added by install.macos.sh

# localhost
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost

# Docker desktop
127.0.0.1 kubernetes.docker.internal
EOF
}

augment_sudoers() {
        if [ -z "$FORCE_REINSTALL" ] &&
                [ -r /etc/sudoers.d/extra ]; then return; fi

        tee /tmp/sudoers.augment >/dev/null <<EOF
# added by install.macos.sh

$(if [ -r ~/.config/sh/env.work ]; then echo '
%admin ALL=(ALL:ALL) NOPASSWD: ALL'; else echo "
%admin ALL=(ALL:ALL) NOPASSWD: \\
                               $(command -v pmset) ,\\
                               $(command -v cat)   ,\\
                               $(command -v grep)  ,\\
                               $(command -v rm) -rf $HOME/Applications/Nix Apps/*
"; fi)
EOF
        visudo -cf /tmp/sudoers.augment || exit 1

        # check if no conflicts with existing sudoers file
        sudo cat /etc/sudoers /tmp/sudoers.augment >/tmp/sudoers.full
        visudo -cf /tmp/sudoers.full || exit 1

        sudo mv /tmp/sudoers.augment /etc/sudoers.d/extra
        sudo chown root /etc/sudoers.d/extra
}

# not used
augment_pamd_sudo() {
        if grep -q '# added by install.macos.sh' /etc/pam.d/sudo; then return; fi

        sudo tee -a /etc/pam.d/sudo >/dev/null <<EOF
# added by install.macos.sh
# use touch ID for sudo
auth sufficient pam_tid.so
EOF
}

main "$@"
