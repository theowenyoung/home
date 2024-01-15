#!/bin/bash

# service for user service
# we alread has ss service on ~/.config/systemd/user/ss.service

UNIT=sslocal

systemctl --user enable $UNIT

systemctl --user daemon-reload
systemctl --user restart $UNIT
systemctl --user status $UNIT
