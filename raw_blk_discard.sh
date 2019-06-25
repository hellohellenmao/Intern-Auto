#!/bin/bash

echo "discard raw block test(RHEL7-6917) begin!"

dd if=/dev/zero of=data1.img bs=1M count=1024 > /dev/null 2>&1

modprobe scsi_debug dev_size_mb=1024 lbpws=1
if [ $? -ne 0 ]; then
    echo "madprove scsi_debug failed! Check please."
    exit 1
fi

lsscsi | grep scsi_debug > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "There is no scsi_debug device! Check please."
    exit 1
fi

debug_device=$(lsscsi | grep scsi_debug | awk '{print $NF}')

strace -o discard_raw.log -e trace=fallocate -f qemu-img convert -f raw -O raw -t none data1.img $debug_device
if [ $? -ne 0 ]; then
    echo "Trace the system call fallocate failed! Check please."
    exit 1
fi

grep "FALLOC_FL_PUNCH_HOLE, 0, 1073741824) = 0" discard_raw.log > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "The result for system call fallocate is wrong! Check please."
    exit 1
fi

echo "discard raw block test(RHEL7-6917) is done, and passed!"
