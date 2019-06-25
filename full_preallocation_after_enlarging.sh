#!/bin/bash

echo "full preallocation works after enlarging more than once test(RHEL7-86742) begin!"

# full before off preallocation
qemu-img create -f raw test.img 1G > /dev/null 2>&1
qemu-img resize --preallocation=off test.img +1G > /dev/null 2>&1
qemu-img resize --preallocation=full test.img +1G > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Resize the image with preallocation=full after preallocation=off failed, check please."
        exit 1
fi
qemu-img map --output=json test.img > full_after_off_map.info
cat full_after_off_map.info | tail -n 1 | grep '"length": 1073741824, "depth": 0, "zero": false, "data": true, "offset": [0-9]*' > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Grep the dump info from the full_after_off_map.info failed, check please."
        exit 1
fi


# full before falloc preallocation
qemu-img create -f raw test.img 1G > /dev/null 2>&1
qemu-img resize --preallocation=falloc test.img +1G > /dev/null 2>&1
qemu-img resize --preallocation=full test.img +1G > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Resize the image with preallocation=full after preallocation=falloc failed, check please."
        exit 1
fi
qemu-img map --output=json test.img > full_after_falloc_map.info
cat full_after_falloc_map.info | tail -n 1 | grep '"length": 1073741824, "depth": 0, "zero": false, "data": true, "offset": [0-9]*' > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Grep the dump info from the full_after_falloc_map.info failed, check please."
        exit 1
fi

# full before full preallocation
qemu-img create -f raw test.img 1G > /dev/null 2>&1
qemu-img resize --preallocation=full test.img +1G > /dev/null 2>&1
qemu-img resize --preallocation=full test.img +1G > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Resize the image with preallocation=full after preallocation=full failed, check please."
        exit 1
fi
qemu-img map --output=json test.img > full_after_full_map.info
cat full_after_full_map.info | tail -n 1 | grep '"length": 2147483648, "depth": 0, "zero": false, "data": true, "offset": [0-9]*' > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Grep the dump info from the full_after_full_map.info failed, check please."
        exit 1
fi

echo "full preallocation works after enlarging more than once test(RHEL7-86742) is done, and passed!"
