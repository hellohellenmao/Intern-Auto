#!/bin/bash

echo "Case RHEL7-6920 begin!"

losetup -D

qemu-img create output1.img 100M > /dev/null 2>&1
qemu-img create output2.img 20M > /dev/null 2>&1

losetup -f output1.img
losetup -f output2.img

qemu-img create -f qcow2 /dev/loop1 20M > /dev/null 2>&1
dd if=/dev/urandom of=/dev/loop0 bs=1M > /dev/null 2>&1

qemu-img convert -t none -f raw -O qcow2 /dev/loop0 /dev/loop1 > convert_nospace.log 2>&1
grep "No space left on device" convert_nospace.log
if [ $? -ne 0 ]; then
    echo "The error info is not matched, check please."
    exit 1
fi

echo "IO-error for convert test(RHEL7-6920) done, and passed!"
