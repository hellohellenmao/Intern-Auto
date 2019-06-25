#!/bin/bash

echo "--image-opts test(RHEL7-55334) begin!"

function confirmImageInfo() {
    local info_file="$1"
    local info_from_opts_file="$2"
    while read line
    do
        grep "$line" $info_file > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Test failed! There is no $line in the $info_file."
            return 1
        fi
    done < $info_from_opts_file
    return 0
}

qemu-img create -f qcow2 test.qcow2 10G > /dev/null 2>&1

# Confirm the output from info
qemu-img info test.qcow2 > image_info.txt
qemu-img info --image-opts driver=qcow2,file.driver=file,file.filename=test.qcow2 > image_info_from_opts.txt
confirmImageInfo image_info.txt image_info_from_opts.txt
if [ $? -ne 0 ]; then
    echo "Test failed! Check please."
    exit 1
fi

# Confirm the outpu from check
qemu-img check test.qcow2 > check_info.txt
qemu-img check --image-opts driver=qcow2,file.driver=file,file.filename=test.qcow2 > check_info_from_opts.txt
confirmImageInfo check_info.txt check_info_from_opts.txt
if [ $? -ne 0 ]; then
    echo "Test failed! Check please."
    exit 1
fi

echo "--image-opts test(RHEL7-55334) over, and passed!"
