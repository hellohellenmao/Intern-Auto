#!/bin/bash

echo "Case RHEL7-6968 begin!"

qemu-img create -f qcow2 base.qcow2 20G > /dev/null 2>&1

#check defaultly
qemu-img check base.qcow2 > check.log
grep "Image end offset" check.log > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "There is no offset info in the check log file, check please."
    exit 1
fi

#Check info with json
qemu-img check base.qcow2 --output=json > check_json.log
grep "image-end-offset" check_json.log > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "There is no offset info in the check log file, check please."
    exit 1
fi

echo "Check reports image end offset test(RHEL7-6968) done, and passed!"
