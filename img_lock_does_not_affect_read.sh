#!/bin/bash

echo "Case RHEL7-86744 begin!"

qemu-img create -f qcow2 base.qcow2 10G > /dev/null 2>&1
qemu-img create -f qcow2 chain1_sn1.qcow2 -b base.qcow2 > /dev/null 2>&1
qemu-img create -f qcow2 chain2_sn1.qcow2 -b base.qcow2 > /dev/null 2>&1
qemu-img create -f qcow2 chain2_sn2.qcow2 -b chain2_sn1.qcow2 > /dev/null 2>&1

/usr/libexec/qemu-kvm -hda chain1_sn1.qcow2 &

qemu-img commit -f qcow2 chain2_sn2.qcow2 > /dev/null
if [ $? -ne 0 ]; then
    echo "Commit in another chain failed, check please."
    exit 1
fi

kill -9 `pidof qemu-kvm`

echo "Image lock does not affect read test(RHEL7-86744) done, and passed!"
