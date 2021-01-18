#!/bin/bash

. /etc/default/clash

if [ -d "/sys/fs/cgroup/net_cls/bypass_proxy" ];then
    exit 0
fi

if [ ! -d "/sys/fs/cgroup/net_cls" ];then
    mkdir -p /sys/fs/cgroup/net_cls
    
    mount -onet_cls -t cgroup net_cls /sys/fs/cgroup/net_cls
fi

mkdir -p /sys/fs/cgroup/net_cls/bypass_proxy
echo "$BYPASS_CGROUP_CLASSID" > /sys/fs/cgroup/net_cls/bypass_proxy/net_cls.classid
chmod 666 /sys/fs/cgroup/net_cls/bypass_proxy/tasks
