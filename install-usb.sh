#!/bin/bash

set -e

disk="$1"
target="$2"

if [ ! -b "$disk" ]; then
    echo "File $disk is not a block device!" >&2
    exit 1
fi

if [ ! -d "$target" ]; then
    echo "Target path $target must exist!" >&2
    exit 1
fi

set -x

grub-install \
    --target=i386-pc \
    --boot-directory="$target"/boot \
    --recheck \
    "$disk"

mkdir -p "${target}/boot/grub"
mkdir -p "${target}/live"

cp -r image/* "${target}/"
cp grub.cfg "${target}/boot/grub/"
