#!/bin/bash

set -e

# shellcheck disable=SC2016
# netways
ROOT_PASSWD='$6$PjJzhr11EcSD0z3D$Y0CKFe4fEVCHIAprLZ1iCorsfflfwOY2ZjsvvuaUml8aOpzCiO8sqQzz.MhVqu7R7aZwZ4sFbi2YzUD84YhgJ1'

sudo chroot "$1" bash -ex <<EOF
  echo debian-live > /etc/hostname
  echo "127.0.0.1 localhost" > /etc/hosts
  echo "127.0.1.1 debian-live" >> /etc/hosts
  usermod -p '${ROOT_PASSWD}' root
  apt-get update
  apt-get install -y --no-install-recommends linux-image-amd64 live-boot systemd systemd-sysv
  apt-get install -y --no-install-recommends nano vim bash-completion
  apt-get clean
  rm -rf /var/lib/apt/lists/*
EOF
