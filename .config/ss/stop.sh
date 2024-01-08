#!/bin/sh

UNIT=ss
systemctl --user stop $UNIT
systemctl --user status $UNIT
