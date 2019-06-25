#!/bin/bash

echo "qemu-img convert with copy_offloading test(RHEL-144417(qcow2)) begin!"

qemu-img create -f qcow2 src.qcow2 1G > /dev/null 2>&1
qemu-io -c 'write -P 1 0 512M' src.qcow2 > /dev/null 2>&1

# Convert to raw 
strace -e trace=copy_file_range -o convert_offload.log -f qemu-img convert -f qcow2 -O raw src.qcow2 target.img -C
if [ $? -ne 0 ]; then
        echo "Trace copy_file_range system call of convert with offloading failed, check please."
        exit 1
fi
qemu-img compare -f qcow2 -F raw src.qcow2 target.img > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi

# Convert to qcow2
strace -e trace=copy_file_range -o convert_offload.log -f qemu-img convert -f qcow2 -O qcow2 src.qcow2 target.qcow2 -C
if [ $? -ne 0 ]; then
        echo "Trace copy_file_range system call of convert with offloading failed, check please."
        exit 1
fi
qemu-img compare -f qcow2 -F qcow2 src.qcow2 target.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi

# Convert to qcow2: external data file
strace -e trace=copy_file_range -o convert_offload.log -f qemu-img convert -f qcow2 -O qcow2 -o data_file=target_ETD.img src.qcow2 target_ETD.qcow2 -C
if [ $? -ne 0 ]; then
        echo "Trace copy_file_range system call of convert with offloading failed, check please."
        exit 1
fi
qemu-img compare -f qcow2 -F raw src.qcow2 target_ETD.img > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi
qemu-img compare -f qcow2 -F qcow2 src.qcow2 target_ETD.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi

echo "qemu-img convert with copy_offloading test(RHEL-144417(qcow2) is done, and passed!"
