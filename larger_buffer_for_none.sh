#!/bin/bash

echo "Case RHEL7-6916 begin"

function isCmdExist() {
        local cmd="$1"
        which "$cmd" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                return 0
        fi
        echo "$1: command not found"
        return 1
}

# Scenaro1 (Convert)
dd if=/dev/urandom of=fbase bs=1M count=100 > /dev/null 2>&1

isCmdExist strace
if [ $? -eq 1 ]; then
        yum install -y strace
        if [ $? -ne 0 ]; then
                echo "install strace failed, check pls."
                exit 1
        fi
fi

strace -e trace=pwrite64 -o convert.log -f qemu-img convert -t none -f raw -O qcow2 fbase tgt.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "strace convert failed, check please."
        exit 1
fi

if [ -f convert.log ]; then
        grep "2097152" convert.log > /dev/null 2>&1
        if [ $? -ne 0 ]; then
                echo "Case Failed! There is no 2M size from the log. Check log convert.log please."
                exit 1
        fi
else
        echo "There is no log file convert.log, check please."
        exit 1
fi

#Scenario2 (Rebase)
qemu-img create -f qcow2 backing.qcow2 100M > /dev/null 2>&1
qemu-io -c 'write 0 100M' backing.qcow2 > /dev/null 2>&1
qemu-img create -f qcow2 backing_new.qcow2 100M > /dev/null 2>&1
qemu-img create -f qcow2 -b backing.qcow2 sn.qcow2 100M > /dev/null 2>&1
strace -e trace=pwrite64 -o rebase.log -f qemu-img rebase -t none -b backing_new.qcow2 sn.qcow2 > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "strace rebase failed, check please."
        exit 1
fi

if [ -f rebase.log ]; then
        grep "2097152" rebase.log > /dev/null 2>&1
        if [ $? -ne 0 ]; then
                echo "Case Failed! There is no 2M size from the log. Check log rebase.log please."
                exit 1
        fi
else
        echo "There is no log file rebase.log, check please."
        exit 1
fi

echo "Larger output for "none" cache mode test(RHEL7-6916) done, and passed!"
