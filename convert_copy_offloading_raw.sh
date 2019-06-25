#!/bin/bash

echo "qemu-img convert with copy_offloading test(RHEL-144428(raw)) begin!"

qemu-img create -f raw src.img 1G > /dev/null 2>&1
qemu-io -c 'write -P 1 0 512M' src.img > /dev/null 2>&1

# Convert to raw 
strace -e trace=copy_file_range -o convert_offload.log -f qemu-img convert -f raw -O raw src.img target.img -C
if [ $? -ne 0 ]; then
        echo "Trace copy_file_range system call of convert with offloading failed, check please."
        exit 1
fi
qemu-img compare -f raw -F raw src.img target.img > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi

# Convert to qcow2
strace -e trace=copy_file_range -o convert_offload.log -f qemu-img convert -f raw -O qcow2 src.img target.qcow2 -C
if [ $? -ne 0 ]; then
        echo "Trace copy_file_range system call of convert with offloading failed, check please."
        exit 1
fi
qemu-img compare -f raw -F qcow2 src.img target.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi

# Convert to qcow2: external data file
strace -e trace=copy_file_range -o convert_offload.log -f qemu-img convert -f raw -O qcow2 -o data_file=target_ETD.img src.img target_ETD.qcow2 -C
if [ $? -ne 0 ]; then
        echo "Trace copy_file_range system call of convert with offloading failed, check please."
        exit 1
fi
qemu-img compare -f raw -F raw src.img target_ETD.img > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi
qemu-img compare -f raw -F qcow2 src.img target_ETD.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Compare the src and target images failed, check please."
        exit 1
fi

echo "qemu-img convert with copy_offloading test(RHEL-144428(raw) is done, and passed!"
