#!/bin/bash

PROXY_BYPASS_CGROUP="0x16200000"
PROXY_FWMARK="0x162"
PROXY_ROUTE_TABLE="0x162"
PROXY_TUN_DEVICE_NAME="utun"

/usr/lib/clash/clean-tun.sh

sleep 0.5

ip route replace default dev "$PROXY_TUN_DEVICE_NAME" table "$PROXY_ROUTE_TABLE"

ip rule add fwmark "$PROXY_FWMARK" lookup "$PROXY_ROUTE_TABLE"

iptables -t mangle -N CLASH
iptables -t mangle -F CLASH
iptables -t mangle -A CLASH -m cgroup --cgroup "$PROXY_BYPASS_CGROUP" -j RETURN
iptables -t mangle -A CLASH -p tcp --dport 53 -j MARK --set-mark "$PROXY_FWMARK"
iptables -t mangle -A CLASH -p udp --dport 53 -j MARK --set-mark "$PROXY_FWMARK"
iptables -t mangle -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A CLASH -j MARK --set-mark "$PROXY_FWMARK"

iptables -t mangle -N CLASH_FORWARD
iptables -t mangle -F CLASH_FORWARD
iptables -t mangle -A CLASH_FORWARD -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_FORWARD -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_FORWARD -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH_FORWARD -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH_FORWARD -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A CLASH_FORWARD -j MARK --set-mark "$PROXY_FWMARK"

iptables -t mangle -I OUTPUT -j CLASH
iptables -t mangle -I PREROUTING -j CLASH_FORWARD

sysctl -w net/ipv4/ip_forward=1

exit 0
