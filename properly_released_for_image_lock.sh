#!/bin/bash

echo "Case RHEL-138704 begin!"

qemu-img create -f raw -o preallocation=full foo.img 1G & sleep 0.5;qemu-io -c info -c close -r foo.img > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Image lock properly released case(RHEL7-6876) failed, check please."
    exit 1
fi

echo "Image lock properly released case(RHEL7-6876) done, and passed!"
