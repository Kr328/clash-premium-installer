#!/bin/bash

exec 1> /dev/null
exec 2> /dev/null

PROXY_BYPASS_CGROUP="0x16200000"
PROXY_FWMARK="0x162"
PROXY_ROUTE_TABLE="0x162"
PROXY_TUN_DEVICE_NAME="utun"

ip route del default dev "$PROXY_TUN_DEVICE_NAME" table "$PROXY_ROUTE_TABLE"
ip rule del fwmark "$PROXY_FWMARK" lookup "$PROXY_ROUTE_TABLE"

iptables -t mangle -D OUTPUT -j CLASH
iptables -t mangle -D PREROUTING -j CLASH_FORWARD

iptables -t mangle -F CLASH
iptables -t mangle -X CLASH

iptables -t mangle -F CLASH_FORWARD
iptables -t mangle -X CLASH_FORWARD

exit 0
