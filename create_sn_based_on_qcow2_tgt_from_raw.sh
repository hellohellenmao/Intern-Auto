#!/bin/bash

echo "Case RHEL7-6934 begin!"

qemu-img create -f raw test.img 5G > /dev/null 2>&1
qemu-io -f raw -c 'write -P 1 0 1G' test.img > /dev/null 2>&1

qemu-img convert -f raw -O qcow2 test.img tgt.qcow2
if [ $? -ne 0 ]; then
    echo "Convert raw image to qcow2 failed, check please."
    exit 1
fi

qemu-img create -f qcow2 -F qcow2 -b tgt.qcow2 sn.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Create snapshot based on the target qcow2 file failed, check please."
    exit 1
fi

qemu-img compare -f raw -F qcow2 test.img sn.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "The snapshot file and the source raw image are not identical, check please."
    exit 1
fi

echo "Create sn based on target qcow2 from raw image test(RHEL7-6934) done, and passed!"
