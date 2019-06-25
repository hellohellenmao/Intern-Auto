#!/bin/bash

echo "Case RHEL7-6876 begin!"

image_name=test.img
image_size=1.0G
write_data=1.0M

function checkImageInfo() {
    local image_info="$1"
    local origin_info="$2"
    disk_info=$(qemu-img info $image_name | grep "$image_info" | awk -F ":" '{print $2}' | awk -F " " '{print $1}')
    if [ $disk_info != $origin_info ]; then
        echo "The image info - $disk_info does not match original info - $origin_info, check please."
        return 1
    fi
    return 0
}

qemu-img create -f raw $image_name $image_size > /dev/null 2>&1
qemu-io -c "write -P 0 0 ${write_data}" -f raw $image_name > /dev/null 2>&1

# Check image name
checkImageInfo image $image_name
if [ $? -ne 0 ]; then
    echo "Create raw image test(RHEL7-6876) failed! The image info does not match you writed, check please."
    exit 1
fi

#Check image virtual size
checkImageInfo "virtual size" $image_size
if [ $? -ne 0 ]; then
    echo "Create raw image test(RHEL7-6876) failed! The image info does not match you writed, check please."
    exit 1
fi

# Check disk size
checkImageInfo "disk size" $write_data
if [ $? -ne 0 ]; then
    echo "Create raw image test(RHEL7-6876) failed! The image info does not match you writed, check please."
    exit 1
fi

echo "Create raw image test(RHEL7-6876) done, and passed!"
