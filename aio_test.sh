#!/bin/bash

echo "Case RHEL-133900 begin"

qemu_ver=$(qemu-img --version | head -1 | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')
qemu_x_ver=$(echo $qemu_ver | cut -d '-' -f3)

function isCmdExist() {
        local cmd="$1"
        which "$cmd" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                return 0
        fi
        echo "$1: command not found"
        return 1
}

isCmdExist brew
if [ $? -eq 1 ]; then
        curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-8-baseos.repo' -o /etc/yum.repos.d/rcm-tools-rhel-8.repo
        dnf install brewkoji -y > /dev/null 2>&1
        if [ $? -ne 0 ]; then
                echo "install brewkoji failed, check pls."
                exit 1
        fi
fi

# Download qemu source package
brew download-build --rpm --arch=$(arch) ${qemu_ver}.src.rpm > /dev/null 2>&1
rpm -ivhf ${qemu_ver}.src.rpm > /dev/null 2>&1

isCmdExist rpmbuild
if [ $? -eq 1 ]; then
        yum install -y rpm-build > /dev/null 2>&1
        if [ $? -ne 0 ]; then
                echo "install rpm-build failed, check pls."
                exit 1
        fi
fi

# Build the source rpm package
rpmbuild -bp /root/rpmbuild/SPECS/qemu-kvm.spec --nodeps > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "rpmbuild failed, check please."
        exit 1
fi

cd /root/rpmbuild/BUILD/qemu-${qemu_x_ver}/
if [ $? -ne 0 ]; then
        echo "cd to qemu rpmbuild directory failed, check please."
        exit 1
fi

#Get python version
if [ -f /usr/bin/python3 ]; then
        python_ver=python3
elif [ -f /usr/bin/python ]; then
        python_ver=python
fi

./configure --python=/usr/bin/${python_ver} > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "exec configure failed, check please."
        exit 1
fi

make tests/test-aio > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "make test-aio failed, check please."
        exit 1
fi

# Test the aio suite
tests/test-aio > test_aio.log
if [ -f test_aio.log ]; then
        while read line
        do
                line_result=$(echo $line | awk -F ":" '{print $2}')
                if [ $line_result != "OK" ]; then
                        echo "Aiotest(RHEL-133900) failed! The case failed! Check log file, please."
                        exit 1
                fi
        done < test_aio.log
else
        echo "There is no result file test_aio.log, check pls."
        exit 1
fi

echo "Aiotest(RHEL-133900) done, and passed!"
