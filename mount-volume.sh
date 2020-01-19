#!/bin/sh

set -eEx

sudo mkfs -t xfs /dev/xvdb

MOUNT_DIR=$HOME/work
mkdir -p $MOUNT_DIR
sudo mount /dev/xvdb $MOUNT_DIR
uid=$(id -u)
gid=$(id -g)

sudo chown $uid:$gid -R $MOUNT_DIR
