#!/bin/bash

echo "Case RHEL7-6971 begin!"

losetup -D

qemu-img create input.img 2G > /dev/null 2>&1
qemu-img create output.img 2G > /dev/null 2>&1

losetup -f output.img

qemu-img convert -f raw -O raw -t none input.img /dev/loop0
if [ $? -ne 0 ]; then
    echo "Convert to virtual disk failed, check please."
    exit 1
fi

echo "Convert image on a virtual disk test(RHEL7-6971) done, and passed!"
